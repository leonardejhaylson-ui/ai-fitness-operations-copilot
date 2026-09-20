-- Expected columns transcribed from Database Contract v0.1 table definitions.
-- Compare names, PostgreSQL types and nullability; reject extra/missing columns.
BEGIN;
CREATE TEMP TABLE expected_columns (table_name text, column_name text, type_name text, not_null boolean);
INSERT INTO expected_columns VALUES
    ('app_users', 'id', 'uuid', true),
    ('app_users', 'display_name', 'character varying(120)', true),
    ('app_users', 'status', 'text', true),
    ('app_users', 'created_at', 'timestamp with time zone', true),
    ('app_users', 'updated_at', 'timestamp with time zone', true),
    ('app_users', 'deleted_at', 'timestamp with time zone', false),
    ('gym_units', 'id', 'uuid', true),
    ('gym_units', 'name', 'character varying(150)', true),
    ('gym_units', 'code', 'character varying(40)', true),
    ('gym_units', 'timezone', 'character varying(64)', true),
    ('gym_units', 'status', 'text', true),
    ('gym_units', 'created_at', 'timestamp with time zone', true),
    ('gym_units', 'updated_at', 'timestamp with time zone', true),
    ('gym_units', 'deleted_at', 'timestamp with time zone', false),
    ('user_gym_units', 'user_id', 'uuid', true),
    ('user_gym_units', 'gym_unit_id', 'uuid', true),
    ('user_gym_units', 'role', 'text', true),
    ('user_gym_units', 'status', 'text', true),
    ('user_gym_units', 'created_at', 'timestamp with time zone', true),
    ('user_gym_units', 'updated_at', 'timestamp with time zone', true),
    ('members', 'id', 'uuid', true),
    ('members', 'gym_unit_id', 'uuid', true),
    ('members', 'member_code', 'character varying(32)', true),
    ('members', 'display_name', 'character varying(120)', true),
    ('members', 'status', 'text', true),
    ('members', 'joined_at', 'timestamp with time zone', true),
    ('members', 'deactivated_at', 'timestamp with time zone', false),
    ('members', 'created_at', 'timestamp with time zone', true),
    ('members', 'updated_at', 'timestamp with time zone', true),
    ('members', 'deleted_at', 'timestamp with time zone', false),
    ('access_records', 'id', 'uuid', true),
    ('access_records', 'gym_unit_id', 'uuid', true),
    ('access_records', 'member_id', 'uuid', true),
    ('access_records', 'occurred_at', 'timestamp with time zone', true),
    ('access_records', 'status', 'text', true),
    ('access_records', 'created_at', 'timestamp with time zone', true),
    ('access_records', 'voided_at', 'timestamp with time zone', false),
    ('operational_insights', 'id', 'uuid', true),
    ('operational_insights', 'gym_unit_id', 'uuid', true),
    ('operational_insights', 'type', 'text', true),
    ('operational_insights', 'severity', 'text', true),
    ('operational_insights', 'subject_type', 'text', true),
    ('operational_insights', 'subject_id', 'uuid', false),
    ('operational_insights', 'period_start', 'timestamp with time zone', true),
    ('operational_insights', 'period_end', 'timestamp with time zone', true),
    ('operational_insights', 'comparison_start', 'timestamp with time zone', false),
    ('operational_insights', 'comparison_end', 'timestamp with time zone', false),
    ('operational_insights', 'rule_code', 'character varying(80)', true),
    ('operational_insights', 'rule_version', 'character varying(40)', true),
    ('operational_insights', 'evidence_snapshot', 'jsonb', true),
    ('operational_insights', 'detected_at', 'timestamp with time zone', true),
    ('operational_insights', 'resolved_at', 'timestamp with time zone', false),
    ('operational_insights', 'created_at', 'timestamp with time zone', true),
    ('ai_conversations', 'id', 'uuid', true),
    ('ai_conversations', 'gym_unit_id', 'uuid', true),
    ('ai_conversations', 'user_id', 'uuid', true),
    ('ai_conversations', 'title', 'character varying(160)', false),
    ('ai_conversations', 'status', 'text', true),
    ('ai_conversations', 'created_at', 'timestamp with time zone', true),
    ('ai_conversations', 'updated_at', 'timestamp with time zone', true),
    ('ai_conversations', 'deleted_at', 'timestamp with time zone', false),
    ('ai_messages', 'id', 'uuid', true),
    ('ai_messages', 'conversation_id', 'uuid', true),
    ('ai_messages', 'gym_unit_id', 'uuid', true),
    ('ai_messages', 'role', 'text', true),
    ('ai_messages', 'content', 'text', true),
    ('ai_messages', 'ai_run_id', 'uuid', false),
    ('ai_messages', 'created_at', 'timestamp with time zone', true),
    ('ai_runs', 'id', 'uuid', true),
    ('ai_runs', 'conversation_id', 'uuid', true),
    ('ai_runs', 'gym_unit_id', 'uuid', true),
    ('ai_runs', 'user_id', 'uuid', true),
    ('ai_runs', 'request_message_id', 'uuid', true),
    ('ai_runs', 'response_message_id', 'uuid', false),
    ('ai_runs', 'intent', 'character varying(80)', true),
    ('ai_runs', 'question', 'text', true),
    ('ai_runs', 'context_snapshot', 'jsonb', true),
    ('ai_runs', 'evidence_snapshot', 'jsonb', true),
    ('ai_runs', 'response_snapshot', 'jsonb', false),
    ('ai_runs', 'provider', 'character varying(80)', true),
    ('ai_runs', 'model', 'character varying(120)', true),
    ('ai_runs', 'prompt_version', 'character varying(40)', true),
    ('ai_runs', 'context_schema_version', 'character varying(40)', true),
    ('ai_runs', 'response_schema_version', 'character varying(40)', true),
    ('ai_runs', 'status', 'text', true),
    ('ai_runs', 'latency_ms', 'integer', false),
    ('ai_runs', 'input_tokens', 'integer', false),
    ('ai_runs', 'output_tokens', 'integer', false),
    ('ai_runs', 'error_code', 'character varying(80)', false),
    ('ai_runs', 'error_message', 'text', false),
    ('ai_runs', 'started_at', 'timestamp with time zone', true),
    ('ai_runs', 'completed_at', 'timestamp with time zone', false),
    ('ai_runs', 'created_at', 'timestamp with time zone', true);
DO $$
DECLARE differences text;
BEGIN
  WITH actual AS (
    SELECT c.relname::text AS table_name, a.attname::text AS column_name,
      format_type(a.atttypid, a.atttypmod) AS type_name, a.attnotnull AS not_null
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    JOIN pg_attribute a ON a.attrelid=c.oid
    WHERE n.nspname='public' AND c.relkind='r' AND a.attnum > 0 AND NOT a.attisdropped
  ), mismatch AS (
    (SELECT * FROM actual EXCEPT SELECT * FROM expected_columns)
    UNION ALL
    (SELECT * FROM expected_columns EXCEPT SELECT * FROM actual)
  )
  SELECT string_agg(table_name || '.' || column_name || ':' || type_name, ', ') INTO differences FROM mismatch;
  IF differences IS NOT NULL THEN RAISE EXCEPTION 'Schema differs from contract: %', differences; END IF;
  RAISE NOTICE 'PASS: all contract columns, types and nullability match';
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND column_name IN ('created_at','updated_at','detected_at','started_at')
      AND column_default IS DISTINCT FROM 'CURRENT_TIMESTAMP'
  ) THEN RAISE EXCEPTION 'Timestamp creation defaults differ from contract'; END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND column_name='id'
      AND ((table_name='app_users' AND column_default IS NOT NULL)
        OR (table_name<>'app_users' AND column_default IS DISTINCT FROM 'gen_random_uuid()'))
  ) THEN RAISE EXCEPTION 'UUID defaults differ from contract'; END IF;
  IF EXISTS (
    SELECT 1 FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
    WHERE n.nspname='public' AND c.contype='f' AND c.confdeltype <> 'r'
  ) THEN RAISE EXCEPTION 'Domain FK delete action must be RESTRICT'; END IF;
  IF EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND cmd IN ('ALL','DELETE')
  ) THEN RAISE EXCEPTION 'No broad ALL or DELETE policies permitted'; END IF;
  IF (SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname IN ('public','private','api') AND p.prosecdef) <> 1
  THEN RAISE EXCEPTION 'Unexpected SECURITY DEFINER surface'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='private' AND p.proname='has_active_membership'
      AND p.prosecdef AND 'search_path=""' = ANY(p.proconfig)
  ) THEN RAISE EXCEPTION 'Authorization helper must lock search_path'; END IF;
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='api')
    OR EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='api')
  THEN RAISE EXCEPTION 'Local Data API schema must remain empty'; END IF;
  RAISE NOTICE 'PASS: defaults, delete actions, policy scope and helper hardening match';
END;
$$;
ROLLBACK;
