-- Database Contract v0.1: M12.
CREATE INDEX members_unit_status_idx ON public.members (gym_unit_id, status);
CREATE INDEX access_records_unit_time_idx ON public.access_records (gym_unit_id, occurred_at);
CREATE INDEX access_records_unit_member_time_idx ON public.access_records (gym_unit_id, member_id, occurred_at);
CREATE INDEX operational_insights_unit_detected_idx ON public.operational_insights (gym_unit_id, detected_at DESC);
CREATE INDEX operational_insights_unit_subject_detected_idx ON public.operational_insights (gym_unit_id, subject_type, subject_id, detected_at DESC);
CREATE INDEX ai_conversations_owner_unit_updated_idx ON public.ai_conversations (user_id, gym_unit_id, updated_at DESC);
CREATE INDEX ai_messages_conversation_time_idx ON public.ai_messages (conversation_id, created_at, id);
CREATE INDEX ai_runs_conversation_time_idx ON public.ai_runs (conversation_id, created_at, id);
CREATE INDEX ai_runs_unit_created_idx ON public.ai_runs (gym_unit_id, created_at DESC);
