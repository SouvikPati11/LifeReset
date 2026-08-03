# Notifications — Spark development vs. Blaze deployment

The Push Notification module is designed to run on the **Spark (free) plan
during development without deploying any Cloud Functions**, and to move to
**Blaze** later **with zero changes to the Flutter app**.

## Why the Flutter app already works on Spark

The Flutter client never calls a Cloud Function. It only:

- registers its FCM token at `users/{uid}/fcm_tokens/{token}` (Firestore write),
- reads its inbox from `users/{uid}/notifications` (Firestore read),
- saves preferences on `users/{uid}.notificationSettings` (Firestore write).

All of that works on Spark. The only server-only job is **sending** — writing
inbox docs and pushing via FCM — which is what this folder provides for
development.

## Where the sending logic lives

`functions/notifications_core.js` holds the entire sending implementation
(`pushToUser`, the admin dispatcher, and the reminder sweeps). It is imported by:

- `functions/index.js` — wraps it in scheduled Cloud Functions for **Blaze**.
- `functions/scripts/dev-notify.mjs` — runs it locally via the Admin SDK for
  **Spark** development.

Because both use the same code, behaviour is identical before and after
deployment.

## Spark development workflow (no Functions deploy)

1. Firebase console → **Project settings → Service accounts → Generate new
   private key**. Save the JSON privately (it is git-ignored; never commit it).
2. Point the Admin SDK at it:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/serviceAccount.json
   ```
3. From `functions/`, install deps once (`npm install`) and send:
   ```bash
   npm run notify -- test <uid>            # write an inbox doc + push to devices
   npm run notify -- dispatch              # send due admin-created notifications
   npm run notify -- daily|journal|mood    # run a reminder sweep
   npm run notify -- trial|subscription    # run a lifecycle reminder sweep
   ```
   FCM sending is free on Spark, so real pushes are delivered and the in-app
   inbox updates live.

### Optional: local emulator

`firebase.json` includes an emulator config. `firebase emulators:start` runs the
functions locally on Spark; note that scheduled (`onSchedule`) functions do not
fire automatically in the emulator — use the CLI above to trigger a run.

## Moving to Blaze (later)

```bash
firebase deploy --only functions,firestore:rules
```

The six scheduled functions (`dispatchScheduledNotifications`,
`sendDailyReminders`, `sendJournalReminders`, `sendMoodReminders`,
`sendTrialEndingReminders`, `sendSubscriptionReminders`) then run on their
cron schedules. **No Flutter change is required** — the app was reading the same
Firestore inbox all along.
