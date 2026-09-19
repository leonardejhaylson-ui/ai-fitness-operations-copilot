# ADR 0001: Bootstrap Tooling Baseline

- **Date:** 2026-09-19
- **Status:** Accepted for bootstrap

## Context

The approved stack requires Next.js, React, TypeScript, App Router, Tailwind, pnpm, Vitest, Testing Library, Playwright, and Vercel. The repository had no implementation. Approved artifact contents were unavailable.

## Decision

Use a single-package pnpm project, Next.js App Router with strict TypeScript, Tailwind 4 via PostCSS, ESLint flat configuration, Vitest with jsdom/Testing Library, and one Chromium Playwright smoke test. Keep the application shell intentionally non-functional and defer provider SDKs until integration work is approved.

## Consequences

The repository has executable quality gates without speculative domain structure. Browser installation is a separate Playwright setup step. Normative artifact content must be imported before feature development.
