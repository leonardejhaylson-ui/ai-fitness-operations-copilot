import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

function config() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;
  if (!url || !key) return null;
  return { url, key };
}

export async function createSupabaseServerClient() {
  const cfg = config();
  if (!cfg) return null;
  const store = await cookies();

  return createServerClient(cfg.url, cfg.key, {
    cookies: {
      getAll() {
        return store.getAll();
      },
      setAll(items) {
        try {
          for (const { name, value, options } of items) store.set(name, value, options);
        } catch {
          // Server Components cannot always write cookies. Middleware refreshes sessions.
        }
      },
    },
  });
}

export async function getAuthenticatedUser() {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return null;
  const { data, error } = await supabase.auth.getUser();
  if (error) return null;
  return data.user ?? null;
}
