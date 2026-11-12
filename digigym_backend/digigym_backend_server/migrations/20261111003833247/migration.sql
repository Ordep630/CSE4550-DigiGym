BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "workout_streak" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "currentStreak" bigint NOT NULL,
    "lastCompletedDate" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "workout_streak_auth_user_idx" ON "workout_streak" USING btree ("authUserId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "workout_streak"
    ADD CONSTRAINT "workout_streak_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR digigym_backend
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('digigym_backend', '20261111003833247', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261111003833247', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();


COMMIT;
