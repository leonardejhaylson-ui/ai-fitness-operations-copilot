-- Database Contract v0.1: M03.
CREATE TABLE public.gym_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(150) NOT NULL CHECK (btrim(name) <> ''),
  code varchar(40) NOT NULL UNIQUE CHECK (btrim(code) <> ''),
  timezone varchar(64) NOT NULL CHECK (btrim(timezone) <> ''),
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at timestamptz,
  CHECK (deleted_at IS NULL OR status = 'INACTIVE'),
  CHECK (updated_at >= created_at)
);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.gym_units
FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();
