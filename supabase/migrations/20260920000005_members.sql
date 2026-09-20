-- Database Contract v0.1: M05.
CREATE TABLE public.members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_unit_id uuid NOT NULL REFERENCES public.gym_units(id) ON DELETE RESTRICT,
  member_code varchar(32) NOT NULL CHECK (btrim(member_code) <> ''),
  display_name varchar(120) NOT NULL CHECK (btrim(display_name) <> ''),
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
  joined_at timestamptz NOT NULL,
  deactivated_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at timestamptz,
  UNIQUE (gym_unit_id, member_code),
  UNIQUE (id, gym_unit_id),
  CHECK (deactivated_at IS NULL OR deactivated_at >= joined_at),
  CHECK (status <> 'ACTIVE' OR deactivated_at IS NULL),
  CHECK (deactivated_at IS NULL OR status = 'INACTIVE'),
  CHECK (deleted_at IS NULL OR status = 'INACTIVE'),
  CHECK (updated_at >= created_at)
);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.members
FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();
