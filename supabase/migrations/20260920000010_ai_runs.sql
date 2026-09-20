-- Database Contract v0.1: M10.
CREATE TABLE public.ai_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL,
  gym_unit_id uuid NOT NULL,
  user_id uuid NOT NULL,
  request_message_id uuid NOT NULL,
  response_message_id uuid,
  intent varchar(80) NOT NULL CHECK (btrim(intent) <> ''),
  question text NOT NULL CHECK (btrim(question) <> ''),
  context_snapshot jsonb NOT NULL CHECK (jsonb_typeof(context_snapshot) = 'object'),
  evidence_snapshot jsonb NOT NULL CHECK (jsonb_typeof(evidence_snapshot) = 'object'),
  response_snapshot jsonb CHECK (response_snapshot IS NULL OR jsonb_typeof(response_snapshot) = 'object'),
  provider varchar(80) NOT NULL CHECK (btrim(provider) <> ''),
  model varchar(120) NOT NULL CHECK (btrim(model) <> ''),
  prompt_version varchar(40) NOT NULL CHECK (btrim(prompt_version) <> ''),
  context_schema_version varchar(40) NOT NULL CHECK (btrim(context_schema_version) <> ''),
  response_schema_version varchar(40) NOT NULL CHECK (btrim(response_schema_version) <> ''),
  status text NOT NULL DEFAULT 'STARTED' CHECK (status IN ('STARTED', 'SUCCEEDED', 'INSUFFICIENT_DATA', 'FAILED_PROVIDER', 'FAILED_TIMEOUT', 'FAILED_VALIDATION')),
  latency_ms integer CHECK (latency_ms >= 0),
  input_tokens integer CHECK (input_tokens >= 0),
  output_tokens integer CHECK (output_tokens >= 0),
  error_code varchar(80),
  error_message text,
  started_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (id, conversation_id, gym_unit_id),
  FOREIGN KEY (conversation_id, gym_unit_id, user_id) REFERENCES public.ai_conversations(id, gym_unit_id, user_id) ON DELETE RESTRICT,
  FOREIGN KEY (request_message_id, conversation_id, gym_unit_id) REFERENCES public.ai_messages(id, conversation_id, gym_unit_id) ON DELETE RESTRICT,
  FOREIGN KEY (response_message_id, conversation_id, gym_unit_id) REFERENCES public.ai_messages(id, conversation_id, gym_unit_id) ON DELETE RESTRICT,
  CHECK (coalesce(jsonb_typeof(context_snapshot -> 'schemaVersion') = 'string'
    AND context_snapshot ->> 'schemaVersion' = context_schema_version, false)),
  CHECK (coalesce(jsonb_typeof(evidence_snapshot -> 'schemaVersion') = 'string'
    AND btrim(evidence_snapshot ->> 'schemaVersion') <> '', false)),
  CHECK (response_snapshot IS NULL OR coalesce(
    jsonb_typeof(response_snapshot -> 'schemaVersion') = 'string'
    AND response_snapshot ->> 'schemaVersion' = response_schema_version, false)),
  CHECK (completed_at IS NULL OR completed_at >= started_at),
  CHECK (status <> 'STARTED' OR
    (completed_at IS NULL AND response_message_id IS NULL AND response_snapshot IS NULL AND error_code IS NULL)),
  CHECK (status <> 'SUCCEEDED' OR
    (completed_at IS NOT NULL AND response_message_id IS NOT NULL AND response_snapshot IS NOT NULL
     AND error_code IS NULL AND error_message IS NULL AND input_tokens IS NOT NULL AND output_tokens IS NOT NULL)),
  CHECK (status <> 'INSUFFICIENT_DATA' OR
    (completed_at IS NOT NULL AND response_message_id IS NOT NULL AND response_snapshot IS NOT NULL
     AND error_code IS NULL AND error_message IS NULL)),
  CHECK (status NOT IN ('FAILED_PROVIDER', 'FAILED_TIMEOUT', 'FAILED_VALIDATION') OR
    (completed_at IS NOT NULL AND error_code IS NOT NULL AND response_message_id IS NULL))
);

CREATE FUNCTION private.guard_ai_run() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF OLD.status <> 'STARTED' OR NEW.status = 'STARTED' THEN
    RAISE EXCEPTION 'Runs only allow STARTED to terminal' USING ERRCODE = '23514';
  END IF;
  IF (to_jsonb(NEW) - ARRAY['status', 'response_message_id', 'response_snapshot', 'latency_ms',
      'input_tokens', 'output_tokens', 'error_code', 'error_message', 'completed_at']) IS DISTINCT FROM
     (to_jsonb(OLD) - ARRAY['status', 'response_message_id', 'response_snapshot', 'latency_ms',
      'input_tokens', 'output_tokens', 'error_code', 'error_message', 'completed_at']) THEN
    RAISE EXCEPTION 'Run inputs and versioned snapshots are immutable' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.guard_ai_run() FROM PUBLIC;
CREATE TRIGGER guard_history BEFORE UPDATE ON public.ai_runs
FOR EACH ROW EXECUTE FUNCTION private.guard_ai_run();
