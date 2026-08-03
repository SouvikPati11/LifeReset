/**
 * Notification sending core — shared by the deployable Cloud Functions
 * (functions/index.js, for Blaze) and the local development CLI
 * (functions/scripts/dev-notify.mjs, which runs on Spark via the Admin SDK).
 *
 * Keeping the logic here means the exact same code path is exercised during
 * Spark development and after a Blaze deployment — nothing changes on the
 * server side except *where* it runs, and the Flutter app never changes.
 */

import { FieldValue, Timestamp } from "firebase-admin/firestore";

/** Default reminder copy, shared by the schedules and the dev CLI. */
export const REMINDERS = {
  daily: {
    settingKey: "dailyReminder",
    type: "daily_reminder",
    title: "Time for your daily check-in",
    body: "Take a moment for your recovery today. Small steps count.",
  },
  journal: {
    settingKey: "journalReminder",
    type: "journal_reminder",
    title: "Journal reminder",
    body: "Write down how today felt — a few words is enough.",
  },
  mood: {
    settingKey: "moodReminder",
    type: "mood_reminder",
    title: "How are you feeling?",
    body: "Log your mood to keep tracking your recovery.",
  },
};

/**
 * Builds the notification operations against an injected Firestore [db] and
 * Messaging [messaging] instance.
 */
export function createNotifier(db, messaging, log = console) {
  function stringifyData(data) {
    const out = {};
    for (const [k, v] of Object.entries(data || {})) {
      out[k] = typeof v === "string" ? v : JSON.stringify(v);
    }
    return out;
  }

  /** Writes an inbox history doc and pushes to all of the user's devices. */
  async function pushToUser(uid, { title, body, type, data = {} }) {
    const inboxRef = db.collection(`users/${uid}/notifications`).doc();
    await inboxRef.set({
      title,
      body,
      type,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
      data,
    });

    const tokensSnap = await db.collection(`users/${uid}/fcm_tokens`).get();
    if (tokensSnap.empty) return { inboxId: inboxRef.id, sent: 0 };
    const tokens = tokensSnap.docs.map((d) => d.id);

    let resp;
    try {
      resp = await messaging.sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: { type, notificationId: inboxRef.id, ...stringifyData(data) },
        android: {
          priority: "high",
          notification: { channelId: "lifereset_default" },
        },
        apns: { headers: { "apns-priority": "10" } },
      });
    } catch (e) {
      log.error("FCM multicast failed", e);
      return { inboxId: inboxRef.id, sent: 0 };
    }

    // Prune tokens the gateway reports as permanently invalid.
    const deletions = [];
    resp.responses.forEach((r, i) => {
      if (r.success) return;
      const code = r.error?.code || "";
      if (
        code.includes("registration-token-not-registered") ||
        code.includes("invalid-registration-token") ||
        code.includes("invalid-argument")
      ) {
        deletions.push(tokensSnap.docs[i].ref.delete());
      }
    });
    if (deletions.length) await Promise.all(deletions);
    return { inboxId: inboxRef.id, sent: resp.successCount };
  }

  /**
   * Records that a reminder was sent for a given value (a day string, or a
   * period-end timestamp) so it is never sent twice. Returns true when the
   * caller should send.
   */
  async function shouldSendReminder(uid, key, value) {
    const ref = db.doc(`users/${uid}/private/reminder_state`);
    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const data = snap.exists ? snap.data() : {};
      if (data[key] === value) return false;
      tx.set(
        ref,
        { [key]: value, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      return true;
    });
  }

  /** Pages through the users collection applying [handler] to each doc. */
  async function forEachUserPaged(handler, pageSize = 500) {
    let last = null;
    for (;;) {
      let q = db.collection("users").orderBy("__name__").limit(pageSize);
      if (last) q = q.startAfter(last);
      const snap = await q.get();
      if (snap.empty) break;
      for (const doc of snap.docs) await handler(doc);
      if (snap.size < pageSize) break;
      last = snap.docs[snap.docs.length - 1];
    }
  }

  async function hasDevice(uid) {
    const snap = await db.collection(`users/${uid}/fcm_tokens`).limit(1).get();
    return !snap.empty;
  }

  function todayKey() {
    return new Date().toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
  }

  /** Daily reminder runner (daily / journal / mood), honouring settings. */
  async function runDailyReminder({ settingKey, type, title, body }) {
    await forEachUserPaged(async (doc) => {
      const d = doc.data();
      if ((d.notificationSettings ?? {})[settingKey] === false) return;
      if (!(await hasDevice(doc.id))) return;
      if (!(await shouldSendReminder(doc.id, `${settingKey}_day`, todayKey()))) {
        return;
      }
      await pushToUser(doc.id, { title, body, type });
    });
  }

  async function pushRespectingMarketing(uid, payload, respectMarketing, userData) {
    if (respectMarketing) {
      const d = userData ?? (await db.doc(`users/${uid}`).get()).data() ?? {};
      if ((d.notificationSettings ?? {}).marketing === false) return;
    }
    await pushToUser(uid, payload);
  }

  async function fanOutToAudience(audience, userIds, payload, respectMarketing) {
    if (audience === "specific" && Array.isArray(userIds)) {
      for (const uid of userIds) {
        await pushRespectingMarketing(uid, payload, respectMarketing);
      }
      return;
    }
    await forEachUserPaged(async (doc) => {
      const d = doc.data();
      const tier = d.subscription ?? "free";
      if (audience === "premium" && tier !== "premium") return;
      if (audience === "free" && tier === "premium") return;
      await pushRespectingMarketing(doc.id, payload, respectMarketing, d);
    });
  }

  /**
   * Dispatches admin-authored notifications from the existing `notifications`
   * collection once due. Each doc is claimed (status → "sending") in a
   * transaction so concurrent runs never double-send, then marked "sent".
   */
  async function dispatchDueAdminNotifications() {
    const now = Timestamp.now();
    const snap = await db
      .collection("notifications")
      .where("status", "==", "scheduled")
      .limit(20)
      .get();

    for (const doc of snap.docs) {
      const n = doc.data();
      if (n.scheduleAt && n.scheduleAt.toMillis() > now.toMillis()) continue;

      const claimed = await db.runTransaction(async (tx) => {
        const s = await tx.get(doc.ref);
        if (s.data()?.status !== "scheduled") return false;
        tx.set(
          doc.ref,
          { status: "sending", updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
        return true;
      });
      if (!claimed) continue;

      const type = n.type || "announcement";
      const payload = {
        title: n.title || "LifeReset",
        body: n.message || "",
        type,
        data: { source: "admin", adminNotificationId: doc.id },
      };
      const respectMarketing = type === "announcement";
      try {
        await fanOutToAudience(n.audience || "all", n.userIds, payload, respectMarketing);
        await doc.ref.set(
          { status: "sent", sentAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
      } catch (e) {
        log.error(`dispatch failed for ${doc.id}`, e);
        await doc.ref.set({ status: "scheduled" }, { merge: true }); // release
      }
    }
  }

  async function sendTrialEndingReminders() {
    const now = Date.now();
    const soon = now + 24 * 3600 * 1000;
    const snap = await db
      .collection("users")
      .where("trialStatus", "==", "active")
      .limit(500)
      .get();
    for (const doc of snap.docs) {
      const end = doc.data().renewalDate?.toMillis?.();
      if (!end || end < now || end > soon) continue; // ends within 24h
      if (!(await shouldSendReminder(doc.id, "trialEndingReminded", end))) continue;
      await pushToUser(doc.id, {
        title: "Your free trial is ending soon",
        body: "Your 7-day free trial ends within 24 hours. Keep your premium benefits going.",
        type: "trial_ending",
      });
    }
  }

  async function sendSubscriptionReminders() {
    const now = Date.now();
    const soon = now + 3 * 24 * 3600 * 1000;
    const snap = await db
      .collection("users")
      .where("subscription", "==", "premium")
      .limit(500)
      .get();
    for (const doc of snap.docs) {
      const d = doc.data();
      if (d.autoRenew !== false) continue; // only those who won't auto-renew
      const end = d.renewalDate?.toMillis?.();
      if (!end || end < now || end > soon) continue; // ends within 3 days
      if (!(await shouldSendReminder(doc.id, "subscriptionReminded", end))) continue;
      await pushToUser(doc.id, {
        title: "Your subscription is ending",
        body: "Your LifeReset Premium ends soon. Renew to keep your benefits.",
        type: "subscription_reminder",
      });
    }
  }

  return {
    pushToUser,
    runDailyReminder,
    dispatchDueAdminNotifications,
    sendTrialEndingReminders,
    sendSubscriptionReminders,
  };
}
