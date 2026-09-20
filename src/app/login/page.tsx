import { redirect } from 'next/navigation';
import { getAuthenticatedUser } from '@/lib/supabase/server';
import { LoginForm } from './login-form';

export default async function LoginPage() {
  const user = await getAuthenticatedUser();
  if (user) redirect('/overview');

  return (
    <main className="login-page">
      <section className="login-panel" aria-labelledby="login-title">
        <div className="login-brand">
          <span className="brand-mark">AF</span>
          <span>AI Fitness Operations Copilot</span>
        </div>
        <h1 id="login-title">Acesse sua conta</h1>
        <p>Entre com uma conta autorizada para acessar os dados operacionais da unidade.</p>
        <LoginForm />
      </section>
    </main>
  );
}
