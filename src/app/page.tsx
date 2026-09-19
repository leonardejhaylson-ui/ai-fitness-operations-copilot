import { BootstrapStatus } from "@/components/bootstrap-status";

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-3xl flex-col justify-center gap-8 px-6 py-16">
      <header>
        <p className="text-sm font-semibold uppercase tracking-widest text-slate-500">Foundation phase</p>
        <h1 className="mt-3 text-4xl font-bold tracking-tight">AI Fitness Operations Copilot</h1>
      </header>
      <BootstrapStatus />
    </main>
  );
}
