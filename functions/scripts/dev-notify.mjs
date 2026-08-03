#!/usr/bin/env node
/**
 * Local notification sender for DEVELOPMENT on the Spark plan.
 *
 * Cloud Functions can't be deployed on Spark, but the Admin SDK works from any
 * machine and FCM sending is free. This CLI runs the SAME logic as the
 * deployable functions (functions/notifications_core.js) so you can populate a
 * user's inbox and fire real pushes during development — no Functions
 * deployment, and no change to the Flutter app now or when you move to Blaze.
 *
 * Setup (once):
 *   1. Firebase console → Project settings → Service accounts → Generate new
 *      private key. Save the JSON somewhere private (do NOT commit it).
 *   2. export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/serviceAccount.json
 *
 * Usage (run from the functions/ directory):
 *   node scripts/dev-notify.mjs test <uid> [title] [body]
 *   node scripts/dev-notify.mjs dispatch          # send due admin notifications
 *   node scripts/dev-notify.mjs daily|journal|mood # run a reminder sweep
 *   node scripts/dev-notify.mjs trial|subscription # run a lifecycle reminder
 *
 * Or via npm:  npm run notify -- test <uid>
 */

import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

import { createNotifier, REMINDERS } from "../notifications_core.js";

function fail(message) {
  console.error(`\n✖ ${message}\n`);
  process.exit(1);
}

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  fail(
    "GOOGLE_APPLICATION_CREDENTIALS is not set.\n" +
      "  export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json",
  );
}

initializeApp({ credential: applicationDefault() });
const db = getFirestore();
const notifier = createNotifier(db, getMessaging());

const [command, ...args] = process.argv.slice(2);

async function main() {
  switch (command) {
    case "test": {
      const uid = args[0];
      if (!uid) fail("Usage: dev-notify.mjs test <uid> [title] [body]");
      const title = args[1] || "Test notification 🔔";
      const body = args[2] || "This is a local test from dev-notify.";
      const result = await notifier.pushToUser(uid, {
        title,
        body,
        type: "announcement",
        data: { source: "dev-cli" },
      });
      console.log(
        `✔ Inbox doc ${result.inboxId} written; pushed to ${result.sent} device(s).`,
      );
      break;
    }
    case "dispatch":
      await notifier.dispatchDueAdminNotifications();
      console.log("✔ Dispatched due admin notifications.");
      break;
    case "daily":
    case "journal":
    case "mood":
      await notifier.runDailyReminder(REMINDERS[command]);
      console.log(`✔ Ran ${command} reminder sweep.`);
      break;
    case "trial":
      await notifier.sendTrialEndingReminders();
      console.log("✔ Ran trial-ending reminder sweep.");
      break;
    case "subscription":
      await notifier.sendSubscriptionReminders();
      console.log("✔ Ran subscription reminder sweep.");
      break;
    default:
      fail(
        "Unknown command. One of: test <uid> | dispatch | daily | journal | " +
          "mood | trial | subscription",
      );
  }
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
