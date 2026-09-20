-- Database Contract v0.1: M13. Grants and policies are both required.
-- Narrow SECURITY DEFINER helper avoids recursive membership policies.
-- No caller-supplied user ID; identity always comes from auth.uid().
CREATE FUNCTION private.has_active_membership(unit_id uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_gym_units AS membership
    JOIN public.app_users AS app_user ON app_user.id = membership.user_id
    WHERE membership.user_id = (SELECT auth.uid())
      AND membership.gym_unit_id = unit_id
      AND membership.status = 'ACTIVE'
      AND app_user.status = 'ACTIVE' AND app_user.deleted_at IS NULL
  );
$$;
REVOKE ALL ON FUNCTION private.has_active_membership(uuid) FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA public, private TO authenticated;
GRANT EXECUTE ON FUNCTION private.has_active_membership(uuid) TO authenticated;

-- Explicitly remove Supabase default grants, including TRUNCATE and REFERENCES.
REVOKE ALL ON public.app_users, public.gym_units, public.user_gym_units,
  public.members, public.access_records, public.operational_insights,
  public.ai_conversations, public.ai_messages, public.ai_runs FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.app_users, public.gym_units, public.user_gym_units,
  public.members, public.access_records, public.operational_insights,
  public.ai_conversations, public.ai_messages, public.ai_runs TO authenticated;
GRANT UPDATE (display_name) ON public.app_users TO authenticated;
GRANT INSERT (gym_unit_id, user_id, title) ON public.ai_conversations TO authenticated;
GRANT UPDATE (title, status, deleted_at) ON public.ai_conversations TO authenticated;

ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_gym_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.access_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.operational_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_runs ENABLE ROW LEVEL SECURITY;

CREATE POLICY own_profile_select ON public.app_users FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()));
CREATE POLICY own_profile_update ON public.app_users FOR UPDATE TO authenticated
USING (id = (SELECT auth.uid()) AND status = 'ACTIVE' AND deleted_at IS NULL)
WITH CHECK (id = (SELECT auth.uid()) AND status = 'ACTIVE' AND deleted_at IS NULL);
CREATE POLICY own_memberships ON public.user_gym_units FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));
CREATE POLICY authorized_units ON public.gym_units FOR SELECT TO authenticated
USING (private.has_active_membership(id));
CREATE POLICY authorized_members ON public.members FOR SELECT TO authenticated
USING (private.has_active_membership(gym_unit_id));
CREATE POLICY authorized_access_records ON public.access_records FOR SELECT TO authenticated
USING (private.has_active_membership(gym_unit_id));
CREATE POLICY authorized_insights ON public.operational_insights FOR SELECT TO authenticated
USING (private.has_active_membership(gym_unit_id));
CREATE POLICY own_conversations_select ON public.ai_conversations FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()) AND private.has_active_membership(gym_unit_id));
CREATE POLICY own_conversations_insert ON public.ai_conversations FOR INSERT TO authenticated
WITH CHECK (user_id = (SELECT auth.uid()) AND private.has_active_membership(gym_unit_id));
CREATE POLICY own_conversations_update ON public.ai_conversations FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()) AND private.has_active_membership(gym_unit_id))
WITH CHECK (user_id = (SELECT auth.uid()) AND private.has_active_membership(gym_unit_id));
CREATE POLICY own_messages_select ON public.ai_messages FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.ai_conversations AS conversation
  WHERE conversation.id = ai_messages.conversation_id
    AND conversation.gym_unit_id = ai_messages.gym_unit_id
    AND conversation.user_id = (SELECT auth.uid())
    AND private.has_active_membership(conversation.gym_unit_id)
));
CREATE POLICY own_runs_select ON public.ai_runs FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()) AND private.has_active_membership(gym_unit_id)
  AND EXISTS (
    SELECT 1 FROM public.ai_conversations AS conversation
    WHERE conversation.id = ai_runs.conversation_id
      AND conversation.gym_unit_id = ai_runs.gym_unit_id
      AND conversation.user_id = (SELECT auth.uid())
  ));
-- No end-user message/run/insight writes and no DELETE policies.
-- Server-only orchestration is intentionally not provisioned before its increment.
-- Never grant its capabilities to authenticated or use service_role for requests.
