-- Database Contract v0.1: M04.
CREATE TABLE public.user_gym_units (
  user_id uuid NOT NULL REFERENCES public.app_users(id) ON DELETE RESTRICT,
  gym_unit_id uuid NOT NULL REFERENCES public.gym_units(id) ON DELETE RESTRICT,
  role text NOT NULL CHECK (role IN ('MANAGER', 'COORDINATOR', 'ANALYST')),
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, gym_unit_id),
  CHECK (updated_at >= created_at)
);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_gym_units
FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();
