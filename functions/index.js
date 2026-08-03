/**
 * LifeReset — AI Coach Cloud Functions.
 *
 * The Gemini API key lives ONLY here (as a Functions secret). The Flutter app
 * never sees it and never calls Gemini directly — it invokes the `coachChat`
 * callable, which:
 *   - authenticates the caller,
 *   - enforces the per-day free-tier message limit (server-authoritative),
 *   - screens for crisis/self-harm content and returns a safe support message
 *     instead of a generated reply,
 *   - injects the user's recovery context into the prompt,
 *   - calls Gemini and returns the reply.
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";
import { createHmac } from "node:crypto";

initializeApp();
const db = getFirestore();

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

// Razorpay credentials. The SECRET never leaves the server — the client only
// ever receives the publishable key id (returned by createSubscriptionOrder).
const RAZORPAY_KEY_ID = defineSecret("RAZORPAY_KEY_ID");
const RAZORPAY_KEY_SECRET = defineSecret("RAZORPAY_KEY_SECRET");

// Premium Monthly pricing / plan constants (must match the Flutter client).
const PREMIUM_MONTHLY_PAISE = 29900; // ₹299.00
const SUBSCRIPTION_CURRENCY = "INR";
const PLAN_ID = "premium_monthly";
const RENEWAL_DAYS = 30;
const TRIAL_DAYS = 7;

const FREE_DAILY_LIMIT = 30;
const GEMINI_MODEL = "gemini-1.5-flash";

const SYSTEM_PROMPT = `You are the LifeReset AI Coach, a warm, encouraging companion helping someone through breakup recovery.
- You provide emotional support and gentle, practical suggestions.
- You are NOT a licensed therapist and must never claim to be one; do not diagnose or give medical/legal advice.
- Keep replies concise, compassionate and hopeful. Use light Markdown (short paragraphs, occasional bold, simple bullet lists).
- Encourage healthy coping (breathing, journaling, walks, small wins) aligned with the user's recovery plan.
- If the user expresses intent to harm themselves or others, gently urge them to seek immediate professional help and contact local emergency services; do not attempt therapy.`;

// Phrases that trigger the crisis safety path (no model generation).
const CRISIS_PATTERNS = [
  "kill myself",
  "want to die",
  "end my life",
  "suicide",
  "suicidal",
  "self harm",
  "self-harm",
  "hurt myself",
  "cut myself",
  "no reason to live",
  "better off dead",
  "can't go on",
  "cant go on",
];

const CRISIS_REPLY = `I'm really glad you reached out, and I'm concerned about what you're going through. I'm an AI and not able to help in a crisis, but you deserve immediate support from a real person.

Please contact your local emergency number right now, or reach a crisis line:
- **US:** call or text **988** (Suicide & Crisis Lifeline)
- **UK & ROI:** call **116 123** (Samaritans)
- **International:** find a helpline at **findahelpline.com**

You matter, and you don't have to face this alone. 💜`;

function isCrisis(text) {
  const lower = text.toLowerCase();
  return CRISIS_PATTERNS.some((p) => lower.includes(p));
}

function startOfTomorrow() {
  const now = new Date();
  const tomorrow = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate() + 1,
    0,
    0,
    0,
    0,
  );
  return Timestamp.fromDate(tomorrow);
}

/**
 * Reads and enforces the daily quota inside a transaction.
 * Returns { used, remaining, limit } AFTER reserving one message.
 */
async function reserveMessage(uid, isPremium) {
  const usageRef = db.doc(`users/${uid}/private/ai_usage`);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(usageRef);
    const now = Timestamp.now();
    let used = 0;
    let resetsAt = startOfTomorrow();

    if (snap.exists) {
      const data = snap.data();
      resetsAt = data.resetsAt ?? resetsAt;
      // Reset the counter if we've passed the reset time.
      used = resetsAt.toMillis() <= now.toMillis() ? 0 : data.used ?? 0;
      if (resetsAt.toMillis() <= now.toMillis()) resetsAt = startOfTomorrow();
    }

    const limit = isPremium ? null : FREE_DAILY_LIMIT;
    if (limit !== null && used >= limit) {
      return { limitReached: true, used, remaining: 0, limit, resetsAt };
    }

    tx.set(usageRef, { used: used + 1, resetsAt }, { merge: true });
    return {
      limitReached: false,
      used: used + 1,
      remaining: limit === null ? null : limit - (used + 1),
      limit,
      resetsAt,
    };
  });
}

function buildContents(context, history, message) {
  const ctx = context ?? {};
  const contextLine = [
    `Recovery day: ${ctx.recoveryDay ?? "?"} of ${ctx.totalDays ?? 30}`,
    `Recovery score: ${ctx.recoveryScore ?? "n/a"}/100`,
    `Problem: ${ctx.problemType ?? "breakup_recovery"}`,
    ctx.todayTaskTitle ? `Today's task: ${ctx.todayTaskTitle}` : null,
    ctx.moodLabel ? `Current mood: ${ctx.moodLabel} (${ctx.moodScore ?? "?"}/10)` : null,
    `Journal entries today: ${ctx.journalEntriesToday ?? 0}`,
    ctx.previousSummary ? `Earlier conversation: ${ctx.previousSummary}` : null,
  ]
    .filter(Boolean)
    .join("\n");

  const contents = [
    {
      role: "user",
      parts: [{ text: `${SYSTEM_PROMPT}\n\n[User recovery context]\n${contextLine}` }],
    },
    {
      role: "model",
      parts: [{ text: "Understood. I'll keep this context in mind and respond with warmth and care." }],
    },
  ];

  for (const turn of history ?? []) {
    contents.push({
      role: turn.sender === "ai" ? "model" : "user",
      parts: [{ text: String(turn.message ?? "") }],
    });
  }
  contents.push({ role: "user", parts: [{ text: message }] });
  return contents;
}

async function callGemini(apiKey, contents) {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${apiKey}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents,
      generationConfig: { temperature: 0.8, maxOutputTokens: 800 },
      safetySettings: [
        { category: "HARM_CATEGORY_SELF_HARM", threshold: "BLOCK_LOW_AND_ABOVE" },
      ],
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    logger.error("Gemini request failed", { status: res.status, body });
    throw new HttpsError("internal", "The coach is unavailable right now.");
  }

  const data = await res.json();
  const reply = data?.candidates?.[0]?.content?.parts
    ?.map((p) => p.text)
    .filter(Boolean)
    .join("")
    .trim();

  if (!reply) {
    throw new HttpsError("internal", "The coach could not respond. Please try again.");
  }
  return reply;
}

export const coachChat = onCall(
  { secrets: [GEMINI_API_KEY], region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }

    const message = String(request.data?.message ?? "").trim();
    if (!message) {
      throw new HttpsError("invalid-argument", "Message is required.");
    }

    const context = request.data?.context ?? {};
    const history = Array.isArray(request.data?.history) ? request.data.history : [];

    // Crisis path: never generate — return a fixed safe support message.
    if (isCrisis(message)) {
      return { reply: CRISIS_REPLY, isCrisis: true, used: null, remaining: null, limit: null };
    }

    // Determine plan from the user document (server-authoritative).
    const userSnap = await db.doc(`users/${uid}`).get();
    const isPremium = (userSnap.data()?.subscription ?? "free") === "premium";

    const quota = await reserveMessage(uid, isPremium);
    if (quota.limitReached) {
      throw new HttpsError(
        "resource-exhausted",
        "You've reached today's message limit. Upgrade to Premium for unlimited chats.",
      );
    }

    const contents = buildContents(context, history, message);
    const reply = await callGemini(GEMINI_API_KEY.value(), contents);

    return {
      reply,
      isCrisis: false,
      used: quota.used,
      remaining: quota.remaining,
      limit: quota.limit,
    };
  },
);

/* ────────────────────────────────────────────────────────────────────────────
 * Razorpay Subscription
 *
 * The Razorpay secret key lives ONLY in these functions. The client can never
 * grant itself premium: Firestore rules forbid the owner from changing
 * `users/{uid}.subscription`, and the Admin SDK (which bypasses rules) writes
 * entitlement only after a payment signature is verified here.
 *
 * Collections:
 *   payments/{orderId}      — one doc per created order (idempotency anchor)
 *   subscriptions/{uid}     — the user's current subscription record
 *   transactions/{id}       — billing history (id = paymentId, so duplicate
 *                             gateway callbacks never create a second row)
 * ──────────────────────────────────────────────────────────────────────────── */

function addDaysTs(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return Timestamp.fromDate(d);
}

/**
 * Creates a Razorpay order for Premium Monthly and records a pending payment.
 * Returns the order id + publishable key id for the native checkout.
 */
export const createSubscriptionOrder = onCall(
  { secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET], region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "You must be signed in.");

    const keyId = RAZORPAY_KEY_ID.value();
    const auth = Buffer.from(`${keyId}:${RAZORPAY_KEY_SECRET.value()}`).toString(
      "base64",
    );

    let order;
    try {
      const res = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Basic ${auth}`,
        },
        body: JSON.stringify({
          amount: PREMIUM_MONTHLY_PAISE,
          currency: SUBSCRIPTION_CURRENCY,
          receipt: `sub_${uid}_${Date.now()}`,
          notes: { uid, plan: PLAN_ID },
        }),
      });
      if (!res.ok) {
        const body = await res.text();
        logger.error("Razorpay order creation failed", { status: res.status, body });
        throw new HttpsError("internal", "Could not start checkout. Please try again.");
      }
      order = await res.json();
    } catch (e) {
      if (e instanceof HttpsError) throw e;
      logger.error("Razorpay order error", e);
      throw new HttpsError("internal", "Could not start checkout. Please try again.");
    }

    await db.doc(`payments/${order.id}`).set({
      uid,
      orderId: order.id,
      amount: PREMIUM_MONTHLY_PAISE,
      currency: SUBSCRIPTION_CURRENCY,
      plan: PLAN_ID,
      provider: "razorpay",
      status: "created",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {
      orderId: order.id,
      amount: PREMIUM_MONTHLY_PAISE,
      currency: SUBSCRIPTION_CURRENCY,
      keyId,
    };
  },
);

/**
 * Verifies a completed payment and activates premium. Idempotent: the
 * activation runs inside a transaction keyed on payments/{orderId}, so
 * duplicate gateway callbacks never double-activate or double-charge history.
 */
export const verifySubscriptionPayment = onCall(
  { secrets: [RAZORPAY_KEY_SECRET], region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "You must be signed in.");

    const orderId = String(request.data?.orderId ?? "");
    const paymentId = String(request.data?.paymentId ?? "");
    const signature = String(request.data?.signature ?? "");
    if (!orderId || !paymentId || !signature) {
      throw new HttpsError("invalid-argument", "Missing payment details.");
    }

    // 1) Verify the signature with the server-only secret.
    const expected = createHmac("sha256", RAZORPAY_KEY_SECRET.value())
      .update(`${orderId}|${paymentId}`)
      .digest("hex");
    if (expected !== signature) {
      await db
        .doc(`payments/${orderId}`)
        .set(
          {
            status: "failed",
            paymentId,
            failedReason: "signature_mismatch",
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        )
        .catch(() => {});
      throw new HttpsError("failed-precondition", "Invalid payment signature.");
    }

    // 2) Idempotent activation.
    const paymentRef = db.doc(`payments/${orderId}`);
    const userRef = db.doc(`users/${uid}`);
    const subRef = db.doc(`subscriptions/${uid}`);
    const renewalTs = addDaysTs(RENEWAL_DAYS);

    const outcome = await db.runTransaction(async (tx) => {
      const paySnap = await tx.get(paymentRef);
      if (!paySnap.exists) throw new HttpsError("not-found", "Order not found.");
      const pay = paySnap.data();
      if (pay.uid !== uid) {
        throw new HttpsError("permission-denied", "This order is not yours.");
      }
      if (pay.status === "paid") {
        return { alreadyActivated: true }; // duplicate callback — no-op
      }

      const amount = pay.amount ?? PREMIUM_MONTHLY_PAISE;
      const currency = pay.currency ?? SUBSCRIPTION_CURRENCY;

      tx.set(
        paymentRef,
        {
          status: "paid",
          paymentId,
          signature,
          paidAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.set(
        userRef,
        {
          subscription: "premium",
          subscriptionStatus: "active",
          paymentStatus: "paid",
          trialStatus: "none",
          // A paid activation also consumes the one-time intro trial, so a
          // churned payer can't later claim a "first-time" free trial.
          trialConsumed: true,
          autoRenew: true,
          subscriptionStartedAt: FieldValue.serverTimestamp(),
          renewalDate: renewalTs,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.set(
        subRef,
        {
          uid,
          plan: PLAN_ID,
          status: "active",
          autoRenew: true,
          amount,
          currency,
          provider: "razorpay",
          startedAt: FieldValue.serverTimestamp(),
          currentPeriodEnd: renewalTs,
          lastOrderId: orderId,
          lastPaymentId: paymentId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      // Server-authoritative trial flag (private, client can't write it) so
      // startFreeTrial is blocked even after this subscription later lapses.
      tx.set(
        db.doc(`users/${uid}/private/subscription_meta`),
        { trialConsumed: true, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      // id = paymentId → a repeated callback overwrites the same row.
      tx.set(db.doc(`transactions/${paymentId}`), {
        uid,
        type: "subscription",
        plan: PLAN_ID,
        status: "success",
        amount,
        currency,
        orderId,
        paymentId,
        provider: "razorpay",
        createdAt: FieldValue.serverTimestamp(),
      });
      return { alreadyActivated: false };
    });

    return { status: "ok", activated: !outcome.alreadyActivated, plan: PLAN_ID };
  },
);

/**
 * Grants the one-time 7-day free trial. Server-enforced so it can never be
 * claimed twice (the flag lives in server-only `users/{uid}/private`).
 */
export const startFreeTrial = onCall(
  { region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "You must be signed in.");

    const userRef = db.doc(`users/${uid}`);
    const metaRef = db.doc(`users/${uid}/private/subscription_meta`);
    const subRef = db.doc(`subscriptions/${uid}`);
    const trialEndTs = addDaysTs(TRIAL_DAYS);

    await db.runTransaction(async (tx) => {
      const metaSnap = await tx.get(metaRef);
      const userSnap = await tx.get(userRef);
      if (metaSnap.exists && metaSnap.data().trialConsumed === true) {
        throw new HttpsError(
          "failed-precondition",
          "Your free trial has already been used.",
        );
      }
      if ((userSnap.data()?.subscription ?? "free") === "premium") {
        throw new HttpsError("failed-precondition", "You already have premium.");
      }

      tx.set(
        userRef,
        {
          subscription: "premium",
          subscriptionStatus: "trialing",
          paymentStatus: "trial",
          trialStatus: "active",
          trialConsumed: true,
          autoRenew: true,
          subscriptionStartedAt: FieldValue.serverTimestamp(),
          renewalDate: trialEndTs,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.set(
        metaRef,
        {
          trialConsumed: true,
          trialStartedAt: FieldValue.serverTimestamp(),
          trialEndAt: trialEndTs,
        },
        { merge: true },
      );
      tx.set(
        subRef,
        {
          uid,
          plan: PLAN_ID,
          status: "trialing",
          autoRenew: true,
          amount: 0,
          currency: SUBSCRIPTION_CURRENCY,
          provider: "razorpay",
          trial: true,
          startedAt: FieldValue.serverTimestamp(),
          currentPeriodEnd: trialEndTs,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      // One trial row per user (fixed id) — never duplicated.
      tx.set(db.doc(`transactions/trial_${uid}`), {
        uid,
        type: "trial",
        plan: PLAN_ID,
        status: "success",
        amount: 0,
        currency: SUBSCRIPTION_CURRENCY,
        provider: "razorpay",
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    return { status: "ok", trialEnd: trialEndTs.toMillis() };
  },
);

/** Turns off auto-renewal but keeps premium until the current period ends. */
export const cancelSubscription = onCall(
  { region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "You must be signed in.");

    await db.doc(`users/${uid}`).set(
      {
        subscriptionStatus: "cancelled",
        autoRenew: false,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await db.doc(`subscriptions/${uid}`).set(
      {
        status: "cancelled",
        autoRenew: false,
        cancelledAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return { status: "ok" };
  },
);

/** Re-enables auto-renewal for a still-active subscription. */
export const resumeSubscription = onCall(
  { region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "You must be signed in.");

    const userRef = db.doc(`users/${uid}`);
    const snap = await userRef.get();
    const data = snap.data() ?? {};
    if ((data.subscription ?? "free") !== "premium") {
      throw new HttpsError("failed-precondition", "No active subscription to resume.");
    }
    const status = data.trialStatus === "active" ? "trialing" : "active";
    await userRef.set(
      { subscriptionStatus: status, autoRenew: true, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    await db.doc(`subscriptions/${uid}`).set(
      { status, autoRenew: true, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    return { status: "ok" };
  },
);

/** Returns the server-authoritative subscription snapshot (used by Restore). */
export const getSubscription = onCall(
  { region: "us-central1" },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "You must be signed in.");
    const d = (await db.doc(`users/${uid}`).get()).data() ?? {};
    return {
      subscription: d.subscription ?? "free",
      subscriptionStatus: d.subscriptionStatus ?? "none",
      paymentStatus: d.paymentStatus ?? "none",
      trialStatus: d.trialStatus ?? "none",
      autoRenew: d.autoRenew ?? false,
      renewalDate: d.renewalDate ? d.renewalDate.toMillis() : null,
    };
  },
);

/**
 * Daily job: downgrade premium users whose period has ended (cancelled or
 * lapsed). This is what enforces "keep premium until expiry, then revert to
 * free". Filters on a single-field range (renewalDate) to avoid a composite
 * index, then checks the tier in code.
 */
export const expireSubscriptions = onSchedule(
  { schedule: "every 24 hours", region: "us-central1" },
  async () => {
    const now = Timestamp.now();
    const snap = await db
      .collection("users")
      .where("renewalDate", "<", now)
      .limit(400)
      .get();

    const batch = db.batch();
    let count = 0;
    snap.forEach((doc) => {
      const d = doc.data();
      if ((d.subscription ?? "free") !== "premium") return;
      batch.set(
        doc.ref,
        {
          subscription: "free",
          subscriptionStatus: "expired",
          paymentStatus: "expired",
          trialStatus: d.trialStatus === "active" ? "expired" : d.trialStatus ?? "none",
          autoRenew: false,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      count += 1;
    });
    if (count > 0) await batch.commit();
    logger.info(`expireSubscriptions: downgraded ${count} user(s).`);
  },
);
