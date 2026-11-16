BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "digigym_user" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "email" text NOT NULL,
    "passwordHash" text NOT NULL,
    "age" bigint NOT NULL,
    "height" double precision NOT NULL,
    "weight" double precision NOT NULL,
    "fitnessLevel" text NOT NULL,
    "fitnessGoal" text NOT NULL,
    "workoutTime" bigint NOT NULL,
    "dietaryPreference" text NOT NULL,
    "bodyType" text NOT NULL
);


--
-- MIGRATION VERSION FOR digigym_backend
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('digigym_backend', '20260928093701681', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260928093701681', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
