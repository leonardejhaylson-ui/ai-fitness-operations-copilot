// @vitest-environment node
import { beforeEach, describe, expect, it } from 'vitest';
import { checkCopilotRateLimit, resetRateLimitForTests } from './rate-limit';

describe('Copilot rate limiter', () => {
  beforeEach(() => resetRateLimitForTests());

  it('allows ten requests inside the window and blocks the eleventh', () => {
    const now = 1_000_000;
    for (let index = 0; index < 10; index++) {
      expect(checkCopilotRateLimit('user-1', now).allowed).toBe(true);
    }
    const blocked = checkCopilotRateLimit('user-1', now);
    expect(blocked.allowed).toBe(false);
    expect(blocked.retryAfterSeconds).toBe(60);
  });

  it('resets after the window', () => {
    const now = 1_000_000;
    for (let index = 0; index < 10; index++) checkCopilotRateLimit('user-1', now);
    expect(checkCopilotRateLimit('user-1', now + 60_000).allowed).toBe(true);
  });
});
