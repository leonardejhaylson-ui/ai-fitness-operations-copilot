-- Run only after the Golden seed, in the disposable standalone harness.
BEGIN;
SET LOCAL timezone = 'UTC';
CREATE OR REPLACE FUNCTION pg_temp.check_seed(ok boolean, label text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
  RAISE NOTICE 'PASS: %', label;
END $$;
SELECT pg_temp.check_seed((SELECT count(*) = 500 FROM public.members), '500 persisted members');
SELECT pg_temp.check_seed((SELECT count(*) = 33249 FROM public.access_records), '33249 persisted accesses');
SELECT pg_temp.check_seed((SELECT count(*) = 12 FROM public.access_records WHERE status = 'VOIDED' AND voided_at >= created_at), '12 audit-preserving VOIDED records');
SELECT pg_temp.check_seed(NOT EXISTS (SELECT 1 FROM public.access_records a LEFT JOIN public.members m ON (a.member_id, a.gym_unit_id) = (m.id, m.gym_unit_id) WHERE m.id IS NULL), 'every access has a same-tenant member');
SELECT pg_temp.check_seed(NOT EXISTS (SELECT 1 FROM public.access_records WHERE occurred_at < '2026-03-23T00:00:00-03:00' OR occurred_at >= '2026-09-19T00:00:00-03:00'), 'all facts in 180 local days');
SELECT pg_temp.check_seed((SELECT count(*) = 928 FROM public.access_records WHERE status = 'VALID' AND occurred_at >= '2026-09-12T00:00:00-03:00'), 'Golden current 7 days');
SELECT pg_temp.check_seed((SELECT count(*) = 1087 FROM public.access_records WHERE status = 'VALID' AND occurred_at >= '2026-09-05T00:00:00-03:00' AND occurred_at < '2026-09-12T00:00:00-03:00'), 'Golden previous 7 days');
SELECT pg_temp.check_seed((SELECT count(*) = 4853 FROM public.access_records WHERE status = 'VALID' AND occurred_at >= '2026-08-20T00:00:00-03:00'), 'Golden current 30 days');
SELECT pg_temp.check_seed((SELECT count(*) = 5616 FROM public.access_records WHERE status = 'VALID' AND occurred_at >= '2026-07-21T00:00:00-03:00' AND occurred_at < '2026-08-20T00:00:00-03:00'), 'Golden previous 30 days');

-- A second tenant exists ONLY in rollback test fixtures, never in the demo seed.
INSERT INTO public.gym_units (id, name, code, timezone) VALUES ('00000000-0000-4000-8000-000000000012', 'Other unit', 'SEED-NEGATIVE', 'America/Sao_Paulo');
DO $$ BEGIN
  BEGIN
    INSERT INTO public.access_records (gym_unit_id, member_id, occurred_at)
      SELECT '00000000-0000-4000-8000-000000000012', id, '2026-09-01T12:00:00Z' FROM public.members LIMIT 1;
    RAISE EXCEPTION 'Cross-tenant insert unexpectedly succeeded';
  EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: cross-tenant FK rejects real seed member'; END;
END $$;
INSERT INTO auth.users (id) VALUES ('00000000-0000-4000-8000-000000000001'), ('00000000-0000-4000-8000-000000000002');
INSERT INTO public.app_users (id, display_name) VALUES ('00000000-0000-4000-8000-000000000001', 'Seed reader'), ('00000000-0000-4000-8000-000000000002', 'Other reader');
INSERT INTO public.user_gym_units (user_id, gym_unit_id, role) VALUES
 ('00000000-0000-4000-8000-000000000001', 'f17e5500-0000-5000-8000-000000000001', 'ANALYST'),
 ('00000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000012', 'ANALYST');
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000001', true);
SELECT pg_temp.check_seed((SELECT count(*) = 500 FROM public.members), 'authorized reader sees demo members');
SELECT pg_temp.check_seed((SELECT count(*) = 33249 FROM public.access_records), 'authorized reader sees demo history');
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000002', true);
SELECT pg_temp.check_seed((SELECT count(*) = 0 FROM public.members), 'other tenant cannot see demo members');
SELECT pg_temp.check_seed((SELECT count(*) = 0 FROM public.access_records), 'other tenant cannot see demo history');
RESET ROLE;
ROLLBACK;
