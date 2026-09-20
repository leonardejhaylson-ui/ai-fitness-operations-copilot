import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'AI Fitness Operations Copilot',
  description: 'Inteligência operacional para academias',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
