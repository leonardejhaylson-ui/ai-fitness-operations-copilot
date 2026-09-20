-- Database Contract v0.1: M11.
ALTER TABLE public.ai_messages ADD CONSTRAINT ai_messages_run_tenant_fk
FOREIGN KEY (ai_run_id, conversation_id, gym_unit_id)
REFERENCES public.ai_runs(id, conversation_id, gym_unit_id) ON DELETE RESTRICT;
