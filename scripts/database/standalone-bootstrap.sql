-- TEST HARNESS ONLY. Never apply to Supabase or a remote database.
-- Minimal external identity boundary; authentication/JWT verification is NOT tested.
CREATE ROLE anon NOLOGIN NOBYPASSRLS;
CREATE ROLE authenticated NOLOGIN NOBYPASSRLS;
CREATE ROLE service_role NOLOGIN BYPASSRLS;
CREATE SCHEMA auth;
CREATE TABLE auth.users (id uuid PRIMARY KEY);
-- Supabase Auth helper semantics:
-- https://github.com/supabase/auth/blob/master/migrations/20220224000811_update_auth_functions.up.sql
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid;
$$;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION auth.uid() TO anon, authenticated, service_role;
-- Reproduce broad platform defaults so migration revocations are tested.
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;
