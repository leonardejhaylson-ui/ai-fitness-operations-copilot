-- Database Contract v0.1: M09.
CREATE TABLE public.ai_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL,
  gym_unit_id uuid NOT NULL,
  role text NOT NULL CHECK (role IN ('USER', 'ASSISTANT')),
  content text NOT NULL CHECK (btrim(content) <> ''),
  ai_run_id uuid,
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id, conversation_id, gym_unit_id),
  FOREIGN KEY (conversation_id, gym_unit_id) REFERENCES public.ai_conversations(id, gym_unit_id) ON DELETE RESTRICT,
  CHECK (role <> 'USER' OR ai_run_id IS NULL)
  -- ASSISTANT association is normally present; contract does not require NOT NULL.
);

CREATE FUNCTION private.reject_message_update() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  RAISE EXCEPTION 'Messages are append-only' USING ERRCODE = '23514';
END;
$$;
REVOKE ALL ON FUNCTION private.reject_message_update() FROM PUBLIC;
CREATE TRIGGER guard_history BEFORE UPDATE ON public.ai_messages
FOR EACH ROW EXECUTE FUNCTION private.reject_message_update();
