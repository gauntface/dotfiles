---
name: vitest-fake-timers
description: Use fake timers instead of real waits when writing or fixing Vitest tests that involve setTimeout, setInterval, delays, timeouts, debounce/throttle, or Date/time-dependent behaviour. Triggers on "vitest", "fake timers", "flaky timing test", "setTimeout in a test", "debounce test", "Date.now test".
---

# Vitest fake timers

Never use a real `sleep` or wait for a real timeout inside a test. Use
Vitest's fake timers so time advances instantly and deterministically.

## Setup

```ts
import { afterEach, beforeEach, vi } from "vitest";

beforeEach(() => {
  vi.useFakeTimers();
});

afterEach(() => {
  vi.useRealTimers();
});
```

## Advancing time

```ts
// Run all pending timers immediately.
vi.runAllTimers();

// Advance the clock by a fixed amount without waiting.
vi.advanceTimersByTime(1000);

// Advance and flush any timers those timers themselves scheduled.
await vi.advanceTimersByTimeAsync(1000);

// Advance only to the next scheduled timer.
vi.advanceTimersToNextTimer();
```

Use the `Async` variants (`vi.runAllTimersAsync()`,
`vi.advanceTimersByTimeAsync()`) whenever the code under test awaits a
promise inside a timer callback (e.g. an async `setTimeout` handler) —
the sync variants only flush the timer callback itself, not the
microtasks it queues.

## Example: debounce

```ts
import { describe, expect, it, vi } from "vitest";

it("only calls the handler once after the debounce window", () => {
  vi.useFakeTimers();
  const handler = vi.fn();
  const debounced = debounce(handler, 300);

  debounced();
  debounced();
  debounced();

  vi.advanceTimersByTime(300);

  expect(handler).toHaveBeenCalledTimes(1);
});
```

## Example: mocking the current date

```ts
it("marks a session expired after 1 hour", () => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date("2026-01-01T00:00:00Z"));

  const session = createSession();

  vi.setSystemTime(new Date("2026-01-01T01:00:01Z"));

  expect(session.isExpired()).toBe(true);
});
```

## Example: async code inside a timer

```ts
it("retries the request after the backoff delay", async () => {
  vi.useFakeTimers();
  const fetchMock = vi.fn()
    .mockRejectedValueOnce(new Error("network"))
    .mockResolvedValueOnce({ ok: true });

  const resultPromise = fetchWithRetry(fetchMock, { backoffMs: 1000 });

  await vi.advanceTimersByTimeAsync(1000);

  await expect(resultPromise).resolves.toEqual({ ok: true });
});
```

## Gotchas

- Call `vi.useRealTimers()` in `afterEach` — a leaked fake clock breaks
  unrelated tests that run after it.
- If a library's timer already fired before `vi.useFakeTimers()` runs,
  set up fake timers before constructing the code under test, not after.
- `userEvent` from Testing Library has its own timer handling; pass
  `{ advanceTimers: vi.advanceTimersByTime }` when configuring it under
  fake timers, or its internal delays will hang.
