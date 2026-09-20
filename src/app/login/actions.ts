'use server';

import { redirect } from 'next/navigation';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export interface LoginState {
  readonly error: string | null;
}

export async function login(_: LoginState, formData: FormData): Promise<LoginState> {
  const email = String(formData.get('email') ?? '').trim();
  const password = String(formData.get('password') ?? '');

  if (!email || !password) return { error: 'E-mail ou senha inválidos.' };

  const supabase = await createSupabaseServerClient();
  if (!supabase) return { error: 'Autenticação ainda não configurada neste ambiente.' };

  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) return { error: 'E-mail ou senha inválidos.' };

  redirect('/overview');
}

export async function logout() {
  const supabase = await createSupabaseServerClient();
  if (supabase) await supabase.auth.signOut();
  redirect('/login');
}
