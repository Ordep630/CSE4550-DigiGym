BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "completed_workout" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "workoutName" text NOT NULL,
    "durationMinutes" bigint NOT NULL,
    "details" text NOT NULL,
    "completedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "completed_workout_auth_user_completed_at_idx" ON "completed_workout" USING btree ("authUserId", "completedAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "completed_workout"
    ADD CONSTRAINT "completed_workout_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR digigym_backend
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('digigym_backend', '20261109005356341', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261109005356341', "timestamp" = now();

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
