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
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";

initializeApp();
const db = getFirestore();

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

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
