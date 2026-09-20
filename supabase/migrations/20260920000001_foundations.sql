-- Database Contract v0.1: M01.
-- gen_random_uuid() is built into PostgreSQL >= 13; no extension is required.
-- Only this empty schema is exposed by the local Data API.
CREATE SCHEMA api;
CREATE SCHEMA private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;

CREATE FUNCTION private.set_updated_at() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  NEW.updated_at := clock_timestamp();
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.set_updated_at() FROM PUBLIC;
