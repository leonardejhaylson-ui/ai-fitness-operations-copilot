-- Database Contract v0.1: M07.
CREATE TABLE public.operational_insights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_unit_id uuid NOT NULL REFERENCES public.gym_units(id) ON DELETE RESTRICT,
  type text NOT NULL CHECK (type IN ('ATTENDANCE_DROP', 'MEMBER_FREQUENCY_DROP', 'PROLONGED_ABSENCE', 'UNUSUALLY_LOW_OCCUPANCY')),
  severity text NOT NULL CHECK (severity IN ('INFO', 'WARNING', 'HIGH')),
  subject_type text NOT NULL CHECK (subject_type IN ('GYM_UNIT', 'MEMBER', 'TIME_SLOT')),
  subject_id uuid,
  period_start timestamptz NOT NULL,
  period_end timestamptz NOT NULL,
  comparison_start timestamptz,
  comparison_end timestamptz,
  rule_code varchar(80) NOT NULL CHECK (btrim(rule_code) <> ''),
  rule_version varchar(40) NOT NULL CHECK (btrim(rule_version) <> ''),
  evidence_snapshot jsonb NOT NULL CHECK (jsonb_typeof(evidence_snapshot) = 'object'),
  detected_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (subject_id, gym_unit_id) REFERENCES public.members(id, gym_unit_id) ON DELETE RESTRICT,
  CHECK ((subject_type = 'MEMBER' AND subject_id IS NOT NULL) OR
         (subject_type IN ('GYM_UNIT', 'TIME_SLOT') AND subject_id IS NULL)),
  CHECK (coalesce(jsonb_typeof(evidence_snapshot -> 'schemaVersion') = 'string'
    AND btrim(evidence_snapshot ->> 'schemaVersion') <> '', false)),
  CHECK (period_start < period_end),
  CHECK ((comparison_start IS NULL) = (comparison_end IS NULL)),
  CHECK (comparison_start < comparison_end),
  CHECK (resolved_at IS NULL OR resolved_at >= detected_at)
);

CREATE FUNCTION private.guard_insight() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF OLD.resolved_at IS NOT NULL OR NEW.resolved_at IS NULL
     OR (to_jsonb(NEW) - 'resolved_at') IS DISTINCT FROM (to_jsonb(OLD) - 'resolved_at') THEN
    RAISE EXCEPTION 'Insight snapshots only allow resolution' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.guard_insight() FROM PUBLIC;
CREATE TRIGGER guard_history BEFORE UPDATE ON public.operational_insights
FOR EACH ROW EXECUTE FUNCTION private.guard_insight();
