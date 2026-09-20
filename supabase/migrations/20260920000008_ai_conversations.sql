-- Database Contract v0.1: M08.
CREATE TABLE public.ai_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_unit_id uuid NOT NULL REFERENCES public.gym_units(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES public.app_users(id) ON DELETE RESTRICT,
  title varchar(160) CHECK (title IS NULL OR btrim(title) <> ''),
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'ARCHIVED')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at timestamptz,
  UNIQUE (id, gym_unit_id),
  UNIQUE (id, gym_unit_id, user_id),
  FOREIGN KEY (user_id, gym_unit_id) REFERENCES public.user_gym_units(user_id, gym_unit_id) ON DELETE RESTRICT,
  CHECK (deleted_at IS NULL OR status = 'ARCHIVED'),
  CHECK (updated_at >= created_at)
);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.ai_conversations
FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();
