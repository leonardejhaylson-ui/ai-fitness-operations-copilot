-- M14: real database integration checks. Fixtures roll back; this is not a dataset.
BEGIN;
SET LOCAL timezone = 'UTC';
CREATE FUNCTION pg_temp.assert_true(actual boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF actual IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
  RAISE NOTICE 'PASS: %', label;
END;
$$;
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text, label text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE caught_state text;
BEGIN
  BEGIN
    EXECUTE statement;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS caught_state = RETURNED_SQLSTATE;
    IF caught_state <> expected_state THEN
      RAISE EXCEPTION 'FAIL: % expected %, got % (%)', label, expected_state, caught_state, SQLERRM;
    END IF;
  END;
  IF caught_state IS NULL THEN RAISE EXCEPTION 'FAIL: % unexpectedly succeeded', label; END IF;
  RAISE NOTICE 'PASS: %', label;
END;
$$;

INSERT INTO auth.users (id) VALUES ('00000000-0000-4000-8000-000000000001');

INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000001', 'Fixture user 1');

INSERT INTO auth.users (id) VALUES ('00000000-0000-4000-8000-000000000002');

INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000002', 'Fixture user 2');

INSERT INTO auth.users (id) VALUES ('00000000-0000-4000-8000-000000000003');

INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000003', 'Fixture user 3');

INSERT INTO auth.users (id) VALUES ('00000000-0000-4000-8000-000000000004');

INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000004', 'Fixture user 4');

INSERT INTO public.gym_units (id, name, code, timezone) VALUES ('00000000-0000-4000-8000-000000000011', 'Fixture unit', 'TEST-11', 'America/Sao_Paulo');

INSERT INTO public.gym_units (id, name, code, timezone) VALUES ('00000000-0000-4000-8000-000000000012', 'Fixture unit', 'TEST-12', 'America/Sao_Paulo');

INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES ('00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000011', 'ANALYST');

INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES ('00000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000012', 'ANALYST');

INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES ('00000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000011', 'ANALYST');

INSERT INTO public.members (id, gym_unit_id, member_code, display_name, joined_at) VALUES ('00000000-0000-4000-8000-000000000021', '00000000-0000-4000-8000-000000000011', 'M1', 'Fixture member', '2026-01-01Z');

INSERT INTO public.members (id, gym_unit_id, member_code, display_name, joined_at) VALUES ('00000000-0000-4000-8000-000000000022', '00000000-0000-4000-8000-000000000012', 'M1', 'Fixture member', '2026-01-01Z');

INSERT INTO public.access_records (id, gym_unit_id, member_id, occurred_at) VALUES ('00000000-0000-4000-8000-000000000031', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000021', '2026-09-01T01:00:00Z');

INSERT INTO public.access_records (id, gym_unit_id, member_id, occurred_at) VALUES ('00000000-0000-4000-8000-000000000032', '00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000022', '2026-09-01T01:00:00Z');

INSERT INTO public.operational_insights (id, gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000041', '00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}');

INSERT INTO public.operational_insights (id, gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000042', '00000000-0000-4000-8000-000000000012', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}');

INSERT INTO public.ai_conversations (id, gym_unit_id, user_id, title) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', 'Fixture conversation');

INSERT INTO public.ai_conversations (id, gym_unit_id, user_id, title) VALUES ('00000000-0000-4000-8000-000000000052', '00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000002', 'Fixture conversation');

INSERT INTO public.ai_conversations (id, gym_unit_id, user_id, title) VALUES ('00000000-0000-4000-8000-000000000053', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000003', 'Fixture conversation');

INSERT INTO public.ai_conversations (id, gym_unit_id, user_id, title) VALUES ('00000000-0000-4000-8000-000000000054', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', 'Fixture conversation');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000061', '00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'USER', 'Fixture question');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000062', '00000000-0000-4000-8000-000000000052', '00000000-0000-4000-8000-000000000012', 'USER', 'Fixture question');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000063', '00000000-0000-4000-8000-000000000053', '00000000-0000-4000-8000-000000000011', 'USER', 'Fixture question');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000064', '00000000-0000-4000-8000-000000000054', '00000000-0000-4000-8000-000000000011', 'USER', 'Fixture question');

INSERT INTO public.ai_runs (id, conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000071', '00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1');

INSERT INTO public.ai_runs (id, conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000072', '00000000-0000-4000-8000-000000000052', '00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000062', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1');

INSERT INTO public.ai_runs (id, conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000073', '00000000-0000-4000-8000-000000000053', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000063', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1');

INSERT INTO public.ai_runs (id, conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000074', '00000000-0000-4000-8000-000000000054', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000064', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000081', '00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'ASSISTANT', 'Fixture response', '00000000-0000-4000-8000-000000000071');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000082', '00000000-0000-4000-8000-000000000052', '00000000-0000-4000-8000-000000000012', 'ASSISTANT', 'Fixture response', '00000000-0000-4000-8000-000000000072');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000083', '00000000-0000-4000-8000-000000000053', '00000000-0000-4000-8000-000000000011', 'ASSISTANT', 'Fixture response', '00000000-0000-4000-8000-000000000073');

INSERT INTO public.ai_messages (id, conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000084', '00000000-0000-4000-8000-000000000054', '00000000-0000-4000-8000-000000000011', 'ASSISTANT', 'Fixture response', '00000000-0000-4000-8000-000000000074');

SELECT pg_temp.assert_true(((SELECT count(*) FROM pg_tables WHERE schemaname = 'public') = 9), 'exactly nine domain tables');

SELECT pg_temp.assert_true(((SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' AND c.relrowsecurity) = 9), 'RLS on all nine tables');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND data_type='timestamp without time zone')), 'no timezone-less timestamps');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace WHERE n.nspname='public' AND t.typtype='e')), 'text CHECK domains, no native enum');

SELECT pg_temp.assert_true(((SELECT count(*) FROM pg_index i JOIN pg_class c ON c.oid=i.indrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND NOT i.indisunique)=9), 'exactly nine approved secondary indexes');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_runs)=4), 'valid linked fixtures accepted');

SELECT pg_temp.expect_error($test$INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000099', 'Unknown')$test$, '23503', 'profile requires Auth identity');

SELECT pg_temp.expect_error($test$INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000004', 'Duplicate')$test$, '23505', 'identity unique');

SELECT pg_temp.expect_error($test$INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES ('00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000011', 'MANAGER')$test$, '23505', 'membership unique');

SELECT pg_temp.expect_error($test$INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES ('00000000-0000-4000-8000-000000000099', '00000000-0000-4000-8000-000000000011', 'ANALYST')$test$, '23503', 'membership requires existing user and unit');

SELECT pg_temp.expect_error($test$INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES ('00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000099', 'ANALYST')$test$, '23503', 'membership requires existing user and unit');

SELECT pg_temp.expect_error($test$UPDATE public.app_users SET status='ADMIN'$test$, '23514', 'app_users.status rejects unknown value');

SELECT pg_temp.expect_error($test$UPDATE public.gym_units SET status='DELETED'$test$, '23514', 'gym_units.status rejects unknown value');

SELECT pg_temp.expect_error($test$UPDATE public.user_gym_units SET role='OWNER'$test$, '23514', 'user_gym_units.role rejects unknown value');

SELECT pg_temp.expect_error($test$UPDATE public.user_gym_units SET status='REVOKED'$test$, '23514', 'user_gym_units.status rejects unknown value');

SELECT pg_temp.expect_error($test$UPDATE public.members SET status='DELETED'$test$, '23514', 'members.status rejects unknown value');

SELECT pg_temp.expect_error($test$UPDATE public.app_users SET display_name=' '$test$, '23514', 'app_users.display_name cannot be blank');

SELECT pg_temp.expect_error($test$UPDATE public.gym_units SET name=' '$test$, '23514', 'gym_units.name cannot be blank');

SELECT pg_temp.expect_error($test$UPDATE public.gym_units SET code=' '$test$, '23514', 'gym_units.code cannot be blank');

SELECT pg_temp.expect_error($test$UPDATE public.gym_units SET timezone=' '$test$, '23514', 'gym_units.timezone cannot be blank');

SELECT pg_temp.expect_error($test$UPDATE public.members SET member_code=' '$test$, '23514', 'members.member_code cannot be blank');

SELECT pg_temp.expect_error($test$UPDATE public.members SET display_name=' '$test$, '23514', 'members.display_name cannot be blank');

SELECT pg_temp.expect_error($test$UPDATE public.app_users SET deleted_at=CURRENT_TIMESTAMP$test$, '23514', 'app_users deletion requires INACTIVE');

SELECT pg_temp.expect_error($test$UPDATE public.gym_units SET deleted_at=CURRENT_TIMESTAMP$test$, '23514', 'gym_units deletion requires INACTIVE');

SELECT pg_temp.expect_error($test$UPDATE public.members SET deleted_at=CURRENT_TIMESTAMP$test$, '23514', 'members deletion requires INACTIVE');

SELECT pg_temp.expect_error($test$UPDATE public.members SET deactivated_at=CURRENT_TIMESTAMP WHERE id='00000000-0000-4000-8000-000000000021'$test$, '23514', 'ACTIVE member cannot be deactivated');

SELECT pg_temp.expect_error($test$UPDATE public.members SET status='INACTIVE', deactivated_at='2025-01-01Z' WHERE id='00000000-0000-4000-8000-000000000021'$test$, '23514', 'deactivation cannot precede joining');

SELECT pg_temp.expect_error($test$INSERT INTO public.members (gym_unit_id, member_code, display_name, joined_at) VALUES ('00000000-0000-4000-8000-000000000011', 'M1', 'Duplicate', '2026-01-01Z')$test$, '23505', 'member code unique within tenant');

SELECT pg_temp.expect_error($test$INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at) VALUES ('00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000021', '2026-09-01Z')$test$, '23503', 'access/member cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at, status) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000021', '2026-09-01Z', 'DELETED')$test$, '23514', 'invalid access state');

SELECT pg_temp.expect_error($test$INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at, status) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000021', '2026-09-01Z', 'VOIDED')$test$, '23514', 'VOIDED requires timestamp');

SELECT pg_temp.expect_error($test$INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at, voided_at) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000021', '2026-09-01Z', CURRENT_TIMESTAMP)$test$, '23514', 'VALID forbids voided timestamp');

SELECT pg_temp.expect_error($test$INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at, status, voided_at) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000021', '2026-09-01Z', 'VOIDED', '2000-01-01Z')$test$, '23514', 'void cannot precede creation');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot, subject_id) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'MEMBER', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}', '00000000-0000-4000-8000-000000000022')$test$, '23503', 'insight member cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-08-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'equal period bounds rejected');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-07-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'reversed period rejected');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot, comparison_start) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}', '2026-07-01Z')$test$, '23514', 'unpaired comparison rejected');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot, comparison_start, comparison_end) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}', '2026-08-01Z', '2026-08-01Z')$test$, '23514', 'equal comparison rejected');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'MEMBER', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'MEMBER needs subject');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot, subject_id) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}', '00000000-0000-4000-8000-000000000021')$test$, '23514', 'GYM_UNIT forbids subject ID');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot, subject_id) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'TIME_SLOT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}', '00000000-0000-4000-8000-000000000021')$test$, '23514', 'TIME_SLOT forbids subject ID');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '[]')$test$, '23514', 'insight JSON must be object');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'CHURN', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'invalid insight type');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'CRITICAL', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'invalid severity');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'OTHER', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'invalid subject type');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', ' ', 'v1', '{"schemaVersion":"v1"}')$test$, '23514', 'nonempty rule code');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', ' ', '{"schemaVersion":"v1"}')$test$, '23514', 'nonempty rule version');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot, resolved_at) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}', '2000-01-01Z')$test$, '23514', 'resolution cannot precede detection');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000002')$test$, '23503', 'conversation requires matching membership');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id, status) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', 'CLOSED')$test$, '23514', 'invalid conversation status');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id, title) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', ' ')$test$, '23514', 'title cannot be blank');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id, deleted_at) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', CURRENT_TIMESTAMP)$test$, '23514', 'deleted conversation must be archived');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000012', 'USER', 'Fixture')$test$, '23503', 'message/conversation cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'SYSTEM', 'Fixture')$test$, '23514', 'SYSTEM message forbidden');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'USER', ' ')$test$, '23514', 'message content required');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'USER', 'Fixture', '00000000-0000-4000-8000-000000000071')$test$, '23514', 'USER cannot reference run');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'ASSISTANT', 'Fixture', '00000000-0000-4000-8000-000000000072')$test$, '23503', 'message/run cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'ASSISTANT', 'Fixture', '00000000-0000-4000-8000-000000000074')$test$, '23503', 'message/run different conversation same tenant');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23503', 'run/conversation cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23503', 'run owner must match conversation');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000062', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23503', 'run/request cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000064', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23503', 'request wrong conversation same tenant');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'PENDING')$test$, '23514', 'invalid run state');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, completed_at) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', CURRENT_TIMESTAMP)$test$, '23514', 'STARTED forbids completion');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, response_snapshot) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', '{}')$test$, '23514', 'STARTED forbids response snapshot');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, response_message_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', '00000000-0000-4000-8000-000000000081')$test$, '23514', 'STARTED forbids response message');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, error_code) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'ERR')$test$, '23514', 'STARTED forbids error code');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '[]', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23514', 'context JSON object');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', 'null', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23514', 'evidence JSON object');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED')$test$, '23514', 'SUCCEEDED requires terminal fields');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'INSUFFICIENT_DATA')$test$, '23514', 'INSUFFICIENT_DATA requires terminal fields');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, latency_ms) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', -1)$test$, '23514', 'latency_ms nonnegative');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, input_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', -1)$test$, '23514', 'input_tokens nonnegative');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', -1)$test$, '23514', 'output_tokens nonnegative');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', ' ', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23514', 'question nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', ' ', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '23514', 'intent nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', ' ', 'fixture', 'v1', 'v1', 'v1')$test$, '23514', 'provider nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', ' ', 'v1', 'v1', 'v1')$test$, '23514', 'model nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', ' ', 'v1', 'v1')$test$, '23514', 'prompt_version nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', ' ', 'v1')$test$, '23514', 'context_schema_version nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', ' ')$test$, '23514', 'response_schema_version nonempty');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000082', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', 0, 0)$test$, '23503', 'response cross-tenant FK');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000084', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', 0, 0)$test$, '23503', 'response wrong conversation same tenant');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000081', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', NULL, 0)$test$, '23514', 'SUCCEEDED requires input usage');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000081', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', 0, NULL)$test$, '23514', 'SUCCEEDED requires output usage');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens, error_code) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000081', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', 0, 0, 'ERR')$test$, '23514', 'SUCCEEDED forbids error code');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens, error_message) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000081', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', 0, 0, 'error')$test$, '23514', 'SUCCEEDED forbids error message');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', '2000-01-01Z', '00000000-0000-4000-8000-000000000081', '{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', 0, 0)$test$, '23514', 'completion cannot precede start');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, response_message_id, response_snapshot, input_tokens, output_tokens) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'SUCCEEDED', CURRENT_TIMESTAMP, '00000000-0000-4000-8000-000000000081', '[]', 0, 0)$test$, '23514', 'response JSON object');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'FAILED_PROVIDER')$test$, '23514', 'FAILED_PROVIDER requires completion and error');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, error_code, response_message_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'FAILED_PROVIDER', CURRENT_TIMESTAMP, 'ERR', '00000000-0000-4000-8000-000000000081')$test$, '23514', 'FAILED_PROVIDER forbids response message');

INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1') RETURNING id AS terminal_run_id \gset

UPDATE public.ai_runs SET status='FAILED_PROVIDER', completed_at=CURRENT_TIMESTAMP, error_code='FIXTURE_ERROR' WHERE id=:'terminal_run_id';

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'FAILED_TIMEOUT')$test$, '23514', 'FAILED_TIMEOUT requires completion and error');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, error_code, response_message_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'FAILED_TIMEOUT', CURRENT_TIMESTAMP, 'ERR', '00000000-0000-4000-8000-000000000081')$test$, '23514', 'FAILED_TIMEOUT forbids response message');

INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1') RETURNING id AS terminal_run_id \gset

UPDATE public.ai_runs SET status='FAILED_TIMEOUT', completed_at=CURRENT_TIMESTAMP, error_code='FIXTURE_ERROR' WHERE id=:'terminal_run_id';

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'FAILED_VALIDATION')$test$, '23514', 'FAILED_VALIDATION requires completion and error');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version, status, completed_at, error_code, response_message_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1', 'FAILED_VALIDATION', CURRENT_TIMESTAMP, 'ERR', '00000000-0000-4000-8000-000000000081')$test$, '23514', 'FAILED_VALIDATION forbids response message');

INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1') RETURNING id AS terminal_run_id \gset

UPDATE public.ai_runs SET status='FAILED_VALIDATION', completed_at=CURRENT_TIMESTAMP, error_code='FIXTURE_ERROR' WHERE id=:'terminal_run_id';

INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1') RETURNING id AS insufficient_run_id \gset

INSERT INTO public.ai_messages (conversation_id,gym_unit_id,role,content,ai_run_id) VALUES ('00000000-0000-4000-8000-000000000051','00000000-0000-4000-8000-000000000011','ASSISTANT','Insufficient fixture data',:'insufficient_run_id') RETURNING id AS insufficient_message_id \gset

UPDATE public.ai_runs SET status='INSUFFICIENT_DATA',completed_at=CURRENT_TIMESTAMP,response_message_id=:'insufficient_message_id',response_snapshot='{"schemaVersion":"v1","limitations":["fixture"]}' WHERE id=:'insufficient_run_id';

SELECT pg_temp.expect_error($test$UPDATE public.access_records SET occurred_at=CURRENT_TIMESTAMP WHERE id='00000000-0000-4000-8000-000000000031'$test$, '23514', 'historical access cannot be rewritten');

UPDATE public.access_records SET status='VOIDED',voided_at=CURRENT_TIMESTAMP WHERE id='00000000-0000-4000-8000-000000000031';

SELECT pg_temp.expect_error($test$UPDATE public.access_records SET status='VALID',voided_at=NULL WHERE id='00000000-0000-4000-8000-000000000031'$test$, '23514', 'VOIDED cannot return to VALID');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.access_records WHERE id='00000000-0000-4000-8000-000000000031')=1), 'VOIDED fact remains stored');

UPDATE public.members SET status='INACTIVE',deactivated_at='2026-09-15Z' WHERE id='00000000-0000-4000-8000-000000000021';

SELECT pg_temp.assert_true(((SELECT joined_at < '2026-08-01Z' AND deactivated_at >= '2026-08-01Z' FROM public.members WHERE id='00000000-0000-4000-8000-000000000021')), 'member historical interval retained after deactivation');

SELECT pg_temp.expect_error($test$UPDATE public.operational_insights SET severity='HIGH' WHERE id='00000000-0000-4000-8000-000000000041'$test$, '23514', 'insight evidence and metadata immutable');

UPDATE public.operational_insights SET resolved_at=CURRENT_TIMESTAMP WHERE id='00000000-0000-4000-8000-000000000041';

SELECT pg_temp.expect_error($test$UPDATE public.operational_insights SET resolved_at=NULL WHERE id='00000000-0000-4000-8000-000000000041'$test$, '23514', 'resolution cannot be removed');

SELECT pg_temp.expect_error($test$UPDATE public.ai_messages SET content='changed' WHERE id='00000000-0000-4000-8000-000000000061'$test$, '23514', 'messages append-only');

SELECT pg_temp.expect_error($test$UPDATE public.ai_runs SET latency_ms=0 WHERE id='00000000-0000-4000-8000-000000000071'$test$, '23514', 'no intermediate STARTED rewrite');

SELECT pg_temp.expect_error($test$UPDATE public.ai_runs SET status='SUCCEEDED', completed_at=CURRENT_TIMESTAMP, response_message_id='00000000-0000-4000-8000-000000000081', response_snapshot='{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', input_tokens=0, output_tokens=0,question='changed' WHERE id='00000000-0000-4000-8000-000000000071'$test$, '23514', 'terminal transition cannot rewrite question');

SELECT pg_temp.expect_error($test$UPDATE public.ai_runs SET status='SUCCEEDED', completed_at=CURRENT_TIMESTAMP, response_message_id='00000000-0000-4000-8000-000000000081', response_snapshot='{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', input_tokens=0, output_tokens=0,context_snapshot='{}' WHERE id='00000000-0000-4000-8000-000000000071'$test$, '23514', 'terminal transition cannot rewrite context snapshot');

UPDATE public.ai_runs SET status='SUCCEEDED', completed_at=CURRENT_TIMESTAMP, response_message_id='00000000-0000-4000-8000-000000000081', response_snapshot='{"schemaVersion":"v1","answer":"fixture","evidenceIds":[]}', input_tokens=0, output_tokens=0 WHERE id='00000000-0000-4000-8000-000000000071';

SELECT pg_temp.expect_error($test$UPDATE public.ai_runs SET latency_ms=1 WHERE id='00000000-0000-4000-8000-000000000071'$test$, '23514', 'terminal run immutable');

SELECT pg_temp.expect_error($test$UPDATE public.ai_runs SET status='STARTED',completed_at=NULL,response_message_id=NULL,response_snapshot=NULL WHERE id='00000000-0000-4000-8000-000000000071'$test$, '23514', 'terminal run cannot restart');

SELECT pg_temp.expect_error($test$DELETE FROM public.app_users WHERE id='00000000-0000-4000-8000-000000000001'$test$, '23503', 'app_users dependent history restricts physical deletion');

SELECT pg_temp.expect_error($test$DELETE FROM public.gym_units WHERE id='00000000-0000-4000-8000-000000000011'$test$, '23503', 'gym_units dependent history restricts physical deletion');

SELECT pg_temp.expect_error($test$DELETE FROM public.members WHERE id='00000000-0000-4000-8000-000000000021'$test$, '23503', 'members dependent history restricts physical deletion');

SELECT pg_temp.expect_error($test$DELETE FROM public.ai_conversations WHERE id='00000000-0000-4000-8000-000000000051'$test$, '23503', 'ai_conversations dependent history restricts physical deletion');

SELECT pg_temp.expect_error($test$DELETE FROM public.ai_messages WHERE id='00000000-0000-4000-8000-000000000061'$test$, '23503', 'ai_messages dependent history restricts physical deletion');

SELECT pg_temp.expect_error($test$DELETE FROM public.ai_runs WHERE id='00000000-0000-4000-8000-000000000071'$test$, '23503', 'ai_runs dependent history restricts physical deletion');

SELECT pg_temp.assert_true((('2026-09-01T01:00:00Z'::timestamptz AT TIME ZONE 'America/Sao_Paulo')::date = DATE '2026-08-31'), 'UTC instant maps to preceding local day');

SELECT pg_temp.assert_true(('2026-09-01T01:00:00Z'::timestamptz = '2026-08-31T22:00:00-03:00'::timestamptz), 'offsets preserve same instant');

SELECT pg_temp.assert_true(((SELECT count(*) FROM (VALUES ('2026-09-01Z'::timestamptz),('2026-09-02Z'::timestamptz)) AS t(instant) WHERE instant >= '2026-09-01Z' AND instant < '2026-09-02Z')=1), 'half-open boundary counted once');

SELECT count(*) AS own_run_count FROM public.ai_runs WHERE user_id='00000000-0000-4000-8000-000000000001' \gset

SELECT count(*) AS own_message_count FROM public.ai_messages WHERE conversation_id IN ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000054') \gset

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id,gym_unit_id,user_id,request_message_id,intent,question,context_snapshot,evidence_snapshot,provider,model,prompt_version,context_schema_version,response_schema_version) SELECT conversation_id,gym_unit_id,user_id,request_message_id,intent,question,'{}',evidence_snapshot,provider,model,prompt_version,context_schema_version,response_schema_version FROM public.ai_runs LIMIT 1$test$, '23514', 'context requires version');
SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id,gym_unit_id,user_id,request_message_id,intent,question,context_snapshot,evidence_snapshot,provider,model,prompt_version,context_schema_version,response_schema_version) SELECT conversation_id,gym_unit_id,user_id,request_message_id,intent,question,'{"schemaVersion":"wrong"}',evidence_snapshot,provider,model,prompt_version,context_schema_version,response_schema_version FROM public.ai_runs LIMIT 1$test$, '23514', 'context version must match column');
SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id,gym_unit_id,user_id,request_message_id,intent,question,context_snapshot,evidence_snapshot,provider,model,prompt_version,context_schema_version,response_schema_version) SELECT conversation_id,gym_unit_id,user_id,request_message_id,intent,question,context_snapshot,'{}',provider,model,prompt_version,context_schema_version,response_schema_version FROM public.ai_runs LIMIT 1$test$, '23514', 'evidence requires version');
SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id,gym_unit_id,user_id,request_message_id,intent,question,context_snapshot,evidence_snapshot,provider,model,prompt_version,context_schema_version,response_schema_version) SELECT conversation_id,gym_unit_id,user_id,request_message_id,intent,question,context_snapshot,'{"schemaVersion":null}',provider,model,prompt_version,context_schema_version,response_schema_version FROM public.ai_runs LIMIT 1$test$, '23514', 'evidence null version rejected');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000001","role":"authenticated"}';

SELECT pg_temp.assert_true((current_user='authenticated' AND NOT (SELECT rolbypassrls OR rolsuper FROM pg_roles WHERE rolname=current_user)), 'RLS tests use nonprivileged authenticated role');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.app_users)=1), 'app_users authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.user_gym_units)=1), 'user_gym_units authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.gym_units)=1), 'gym_units authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.members)=1), 'members authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.access_records)=1), 'access_records authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.operational_insights)=1), 'operational_insights authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_conversations)=2), 'ai_conversations authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_messages)=:own_message_count), 'ai_messages authorized rows visible, others hidden');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_runs)=:own_run_count), 'ai_runs authorized rows visible, others hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.members WHERE id='00000000-0000-4000-8000-000000000022')), 'members direct foreign ID 22 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.access_records WHERE id='00000000-0000-4000-8000-000000000032')), 'access_records direct foreign ID 32 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.operational_insights WHERE id='00000000-0000-4000-8000-000000000042')), 'operational_insights direct foreign ID 42 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.ai_conversations WHERE id='00000000-0000-4000-8000-000000000052')), 'ai_conversations direct foreign ID 52 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.ai_conversations WHERE id='00000000-0000-4000-8000-000000000053')), 'ai_conversations direct foreign ID 53 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.ai_messages WHERE id='00000000-0000-4000-8000-000000000062')), 'ai_messages direct foreign ID 62 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.ai_messages WHERE id='00000000-0000-4000-8000-000000000063')), 'ai_messages direct foreign ID 63 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.ai_runs WHERE id='00000000-0000-4000-8000-000000000072')), 'ai_runs direct foreign ID 72 hidden');

SELECT pg_temp.assert_true((NOT EXISTS (SELECT 1 FROM public.ai_runs WHERE id='00000000-0000-4000-8000-000000000073')), 'ai_runs direct foreign ID 73 hidden');

UPDATE public.app_users SET display_name='Allowed profile update' WHERE id='00000000-0000-4000-8000-000000000001';

SELECT pg_temp.assert_true(((SELECT display_name FROM public.app_users WHERE id='00000000-0000-4000-8000-000000000001')='Allowed profile update'), 'own display name editable');

SELECT pg_temp.assert_true(((SELECT updated_at > created_at FROM public.app_users WHERE id='00000000-0000-4000-8000-000000000001')), 'updated_at automatically maintained');

SELECT pg_temp.expect_error($test$UPDATE public.app_users SET status='INACTIVE' WHERE id='00000000-0000-4000-8000-000000000001'$test$, '42501', 'profile update cannot change account status');

SELECT pg_temp.expect_error($test$UPDATE public.app_users SET deleted_at=CURRENT_TIMESTAMP WHERE id='00000000-0000-4000-8000-000000000001'$test$, '42501', 'profile update cannot delete account');

SELECT pg_temp.expect_error($test$UPDATE public.user_gym_units SET role='MANAGER' WHERE user_id='00000000-0000-4000-8000-000000000001'$test$, '42501', 'membership role cannot be escalated');

INSERT INTO public.ai_conversations (gym_unit_id, user_id, title) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', 'Allowed conversation');

UPDATE public.ai_conversations SET title='Archived', status='ARCHIVED', deleted_at=CURRENT_TIMESTAMP WHERE id='00000000-0000-4000-8000-000000000054';

SELECT pg_temp.assert_true(((SELECT status FROM public.ai_conversations WHERE id='00000000-0000-4000-8000-000000000054')='ARCHIVED'), 'owner can archive/soft-delete conversation');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id) VALUES ('00000000-0000-4000-8000-000000000012', '00000000-0000-4000-8000-000000000001')$test$, '42501', 'RLS denies foreign tenant insert');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000003')$test$, '42501', 'RLS denies forged owner insert');

SELECT pg_temp.expect_error($test$UPDATE public.ai_conversations SET gym_unit_id='00000000-0000-4000-8000-000000000012' WHERE id='00000000-0000-4000-8000-000000000051'$test$, '42501', 'tenant column cannot be reassigned');

SELECT pg_temp.expect_error($test$UPDATE public.ai_conversations SET user_id='00000000-0000-4000-8000-000000000003' WHERE id='00000000-0000-4000-8000-000000000051'$test$, '42501', 'owner column cannot be reassigned');

WITH changed AS (UPDATE public.ai_conversations SET title='tampered' WHERE id='00000000-0000-4000-8000-000000000053' RETURNING id) SELECT pg_temp.assert_true(count(*)=0, 'RLS denies peer conversation update') FROM changed;

SELECT pg_temp.expect_error($test$INSERT INTO public.members (gym_unit_id, member_code, display_name, joined_at) VALUES ('00000000-0000-4000-8000-000000000011', 'ILLEGAL', 'Illegal', CURRENT_TIMESTAMP)$test$, '42501', 'authenticated cannot write members');

SELECT pg_temp.expect_error($test$INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000021', '2026-09-01Z')$test$, '42501', 'authenticated cannot write access_records');

SELECT pg_temp.expect_error($test$INSERT INTO public.operational_insights (gym_unit_id, type, severity, subject_type, period_start, period_end, rule_code, rule_version, evidence_snapshot) VALUES ('00000000-0000-4000-8000-000000000011', 'ATTENDANCE_DROP', 'WARNING', 'GYM_UNIT', '2026-08-01Z', '2026-09-01Z', 'attendance_drop', 'v1', '{"schemaVersion":"v1"}')$test$, '42501', 'authenticated cannot write operational_insights');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'USER', 'Fixture')$test$, '42501', 'authenticated cannot write ai_messages');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_runs (conversation_id, gym_unit_id, user_id, request_message_id, intent, question, context_snapshot, evidence_snapshot, provider, model, prompt_version, context_schema_version, response_schema_version) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000061', 'unit_overview', 'Fixture question', '{"schemaVersion":"v1"}', '{"schemaVersion":"v1","evidence":[]}', 'fixture', 'fixture', 'v1', 'v1', 'v1')$test$, '42501', 'authenticated cannot write ai_runs');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_messages (conversation_id, gym_unit_id, role, content, ai_run_id) VALUES ('00000000-0000-4000-8000-000000000051', '00000000-0000-4000-8000-000000000011', 'ASSISTANT', 'Fixture', '00000000-0000-4000-8000-000000000071')$test$, '42501', 'authenticated cannot forge assistant output');

SELECT pg_temp.expect_error($test$UPDATE public.ai_runs SET status='FAILED_TIMEOUT'$test$, '42501', 'authenticated cannot finalize runs');

SELECT pg_temp.expect_error($test$DELETE FROM public.app_users$test$, '42501', 'normal DELETE denied for app_users');

SELECT pg_temp.expect_error($test$TRUNCATE public.app_users CASCADE$test$, '42501', 'TRUNCATE denied for app_users');

SELECT pg_temp.expect_error($test$DELETE FROM public.gym_units$test$, '42501', 'normal DELETE denied for gym_units');

SELECT pg_temp.expect_error($test$TRUNCATE public.gym_units CASCADE$test$, '42501', 'TRUNCATE denied for gym_units');

SELECT pg_temp.expect_error($test$DELETE FROM public.user_gym_units$test$, '42501', 'normal DELETE denied for user_gym_units');

SELECT pg_temp.expect_error($test$TRUNCATE public.user_gym_units CASCADE$test$, '42501', 'TRUNCATE denied for user_gym_units');

SELECT pg_temp.expect_error($test$DELETE FROM public.members$test$, '42501', 'normal DELETE denied for members');

SELECT pg_temp.expect_error($test$TRUNCATE public.members CASCADE$test$, '42501', 'TRUNCATE denied for members');

SELECT pg_temp.expect_error($test$DELETE FROM public.access_records$test$, '42501', 'normal DELETE denied for access_records');

SELECT pg_temp.expect_error($test$TRUNCATE public.access_records CASCADE$test$, '42501', 'TRUNCATE denied for access_records');

SELECT pg_temp.expect_error($test$DELETE FROM public.operational_insights$test$, '42501', 'normal DELETE denied for operational_insights');

SELECT pg_temp.expect_error($test$TRUNCATE public.operational_insights CASCADE$test$, '42501', 'TRUNCATE denied for operational_insights');

SELECT pg_temp.expect_error($test$DELETE FROM public.ai_conversations$test$, '42501', 'normal DELETE denied for ai_conversations');

SELECT pg_temp.expect_error($test$TRUNCATE public.ai_conversations CASCADE$test$, '42501', 'TRUNCATE denied for ai_conversations');

SELECT pg_temp.expect_error($test$DELETE FROM public.ai_messages$test$, '42501', 'normal DELETE denied for ai_messages');

SELECT pg_temp.expect_error($test$TRUNCATE public.ai_messages CASCADE$test$, '42501', 'TRUNCATE denied for ai_messages');

SELECT pg_temp.expect_error($test$DELETE FROM public.ai_runs$test$, '42501', 'normal DELETE denied for ai_runs');

SELECT pg_temp.expect_error($test$TRUNCATE public.ai_runs CASCADE$test$, '42501', 'TRUNCATE denied for ai_runs');

RESET ROLE;

UPDATE public.user_gym_units SET status='INACTIVE' WHERE user_id='00000000-0000-4000-8000-000000000001';

SET LOCAL ROLE authenticated;

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.gym_units)=0), 'revoked membership denies gym_units immediately');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.members)=0), 'revoked membership denies members immediately');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.access_records)=0), 'revoked membership denies access_records immediately');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.operational_insights)=0), 'revoked membership denies operational_insights immediately');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_conversations)=0), 'revoked membership denies ai_conversations immediately');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_messages)=0), 'revoked membership denies ai_messages immediately');

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.ai_runs)=0), 'revoked membership denies ai_runs immediately');

SELECT pg_temp.expect_error($test$INSERT INTO public.ai_conversations (gym_unit_id, user_id) VALUES ('00000000-0000-4000-8000-000000000011', '00000000-0000-4000-8000-000000000001')$test$, '42501', 'revoked membership cannot create conversation');

RESET ROLE;

UPDATE public.user_gym_units SET status='ACTIVE' WHERE user_id='00000000-0000-4000-8000-000000000001';

UPDATE public.app_users SET status='INACTIVE' WHERE id='00000000-0000-4000-8000-000000000001';

SET LOCAL ROLE authenticated;

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.members)=0), 'inactive account cannot read tenant data');

SET LOCAL request.jwt.claims = '{"sub":"00000000-0000-4000-8000-000000000004","role":"authenticated"}';

SELECT pg_temp.assert_true(((SELECT count(*) FROM public.members)=0), 'no membership means no access');

SET LOCAL request.jwt.claims = '{}';

SELECT pg_temp.assert_true((auth.uid() IS NULL AND (SELECT count(*) FROM public.members)=0), 'missing authenticated identity fails closed');

RESET ROLE;
SET LOCAL ROLE anon;

SELECT pg_temp.expect_error($test$SELECT * FROM public.app_users$test$, '42501', 'anonymous denied app_users');

SELECT pg_temp.expect_error($test$SELECT * FROM public.gym_units$test$, '42501', 'anonymous denied gym_units');

SELECT pg_temp.expect_error($test$SELECT * FROM public.user_gym_units$test$, '42501', 'anonymous denied user_gym_units');

SELECT pg_temp.expect_error($test$SELECT * FROM public.members$test$, '42501', 'anonymous denied members');

SELECT pg_temp.expect_error($test$SELECT * FROM public.access_records$test$, '42501', 'anonymous denied access_records');

SELECT pg_temp.expect_error($test$SELECT * FROM public.operational_insights$test$, '42501', 'anonymous denied operational_insights');

SELECT pg_temp.expect_error($test$SELECT * FROM public.ai_conversations$test$, '42501', 'anonymous denied ai_conversations');

SELECT pg_temp.expect_error($test$SELECT * FROM public.ai_messages$test$, '42501', 'anonymous denied ai_messages');

SELECT pg_temp.expect_error($test$SELECT * FROM public.ai_runs$test$, '42501', 'anonymous denied ai_runs');

SELECT pg_temp.expect_error($test$SELECT private.has_active_membership('00000000-0000-4000-8000-000000000011')$test$, '42501', 'anonymous cannot invoke private authorization helper');

RESET ROLE;
ROLLBACK;
