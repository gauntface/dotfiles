# Language

Always talk in ASD-STE100 Simplified Technical English.

# Comments

Do not add comments to code by default.

Only add one where a reader who understands the language would still be
surprised — a non-obvious constraint, a workaround for external behaviour, or
a reason a simpler approach does not work.

Never write comments that:

- restate what the code already says
- narrate the change or the session ("added this to fix...", "was previously...")
- label sections of an otherwise readable function

Keep the ones you do write to a line or two, describing the code as it is now.

# Tests involving time

When a test interacts with time (delays, timeouts, intervals, dates), use the
test framework's fake timers instead of real waits.

Do not use real `sleep` or `setTimeout` waits in tests.
