-- Database Contract v0.1: M06.
CREATE TABLE public.access_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_unit_id uuid NOT NULL,
  member_id uuid NOT NULL,
  occurred_at timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'VALID' CHECK (status IN ('VALID', 'VOIDED')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  voided_at timestamptz,
  FOREIGN KEY (member_id, gym_unit_id) REFERENCES public.members(id, gym_unit_id) ON DELETE RESTRICT,
  CHECK ((status = 'VALID' AND voided_at IS NULL) OR (status = 'VOIDED' AND voided_at IS NOT NULL)),
  CHECK (voided_at IS NULL OR voided_at >= created_at)
);

CREATE FUNCTION private.guard_access_record() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF OLD.status <> 'VALID' OR NEW.status <> 'VOIDED'
     OR (to_jsonb(NEW) - ARRAY['status', 'voided_at']) IS DISTINCT FROM
        (to_jsonb(OLD) - ARRAY['status', 'voided_at']) THEN
    RAISE EXCEPTION 'Access records only allow VALID to VOIDED' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.guard_access_record() FROM PUBLIC;
CREATE TRIGGER guard_history BEFORE UPDATE ON public.access_records
FOR EACH ROW EXECUTE FUNCTION private.guard_access_record();
