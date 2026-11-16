# FIT-115 Pass 1 migration plan

Pass 1 includes the two Serverpod migration directories and generated bindings. The live Sprint 3 database cutover requires separate approval.

## Schema and order

| Order | Migration | Change |
|---|---|---|
| Existing | `20261106022303786` | Workout schedules, with one row per auth user |
| 1 | `20261109005356341` | Creates `completed_workout` and an index on account UUID and completion time |
| 2 | `20261111003833247` | Creates `workout_streak` and a unique account UUID index |

Both new tables use generated IDs and require an existing auth user UUID. Their foreign keys cascade on account deletion. The migrations add tables and update migration metadata. Existing credentials, profiles, and schedules need no rewrite or backfill. Each table starts empty. Change Password requires no migration.

## Rehearsal before changing Sprint 3

1. Confirm the target is the isolated Sprint 3 instance. Stop writers and verify the current migration version. Record the expected four auth accounts, four fitness profiles, and existing schedule count and content by private checks that disclose no personal data.
2. Take a fresh private logical backup of the current Sprint 3 database. Set restrictive file permissions, keep the backup outside Git, record its checksum, and retain all older backups and rollback databases.
3. Restore the new backup to a disposable database with a separate data directory and connection settings. Verify schema, relation counts, sequences, indexes, auth-to-profile links, and schedule equality before using the restored database.
4. Apply the registered migrations in order on that clone. Check the final migration version, the two new tables, generated ID sequences, foreign keys, unique streak index, and existing data counts. Test history save, delete ownership, and same-day streak behavior using disposable accounts. Verify existing login and schedule data using an approved test method. Exercise password changes only on synthetic accounts.
5. Once the rehearsal passes and the live migration is approved, repeat the writer stop, confirm the backup and current version, apply the same migration set to Sprint 3, and verify before permitting normal writes.

## Rollback

Keep the branding checkpoint and the verified pre-integration backup available together. If cutover verification fails, keep writers stopped. Preserve the failed database for diagnosis and restore the pre-integration backup into a clean Sprint 3 database, or reconnect to the preserved pre-integration database if using database promotion. Verify accounts, profiles, schedules, and migration version before restarting the branding-checkpoint application. If writes have resumed, capture a separate private backup of that state before replacement and reconcile those writes separately.

## Pass 1 behavior

- History stores planned duration and a snapshot of exercise instructions. It has no elapsed-time measurement or server-side idempotency key. The app blocks duplicate in-flight taps and asks users to check history if it cannot confirm a save.
- A confirmed history save can outlive a failed streak write. The completion screen retries the streak alone using the confirmed completion timestamp. The server accepts local dates within one day of UTC. Retries are available while the completion screen is open.
- Deleting history leaves the streak unchanged. The dashboard progress ring and Monthly Activity calendar still use their existing data.
- Password changes update the email credential. A disposable backend test verified that the old password stops working and that a previously issued JWT and its refresh token remain usable. The UI makes no session-revocation claim.
