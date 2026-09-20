'use client';

import { useActionState } from 'react';
import { login, type LoginState } from './actions';

const initialState: LoginState = { error: null };

export function LoginForm() {
  const [state, action, pending] = useActionState(login, initialState);

  return (
    <form action={action} className="login-form">
      <label>
        <span>E-mail</span>
        <input name="email" type="email" autoComplete="email" required />
      </label>
      <label>
        <span>Senha</span>
        <input name="password" type="password" autoComplete="current-password" required />
      </label>
      {state.error ? <p className="login-error" role="alert">{state.error}</p> : null}
      <button className="button-primary" type="submit" disabled={pending}>
        {pending ? 'Entrando…' : 'Entrar'}
      </button>
    </form>
  );
}
