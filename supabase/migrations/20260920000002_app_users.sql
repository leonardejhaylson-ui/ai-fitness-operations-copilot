-- Database Contract v0.1: M02.
CREATE TABLE public.app_users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
  display_name varchar(120) NOT NULL CHECK (btrim(display_name) <> ''),
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at timestamptz,
  CHECK (deleted_at IS NULL OR status = 'INACTIVE'),
  CHECK (updated_at >= created_at)
);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.app_users
FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();
