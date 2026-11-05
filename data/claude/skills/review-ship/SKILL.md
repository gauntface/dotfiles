---
name: review-ship
description: Review current changes with subagents in a loop, apply useful fixes, open a PR, watch CI, fix failures, and optionally merge. Use when the user says "review and ship", "review loop", "review then PR", "ship this", or wants changes reviewed before a PR.
---

# Review and ship

These are the general steps to follow. The user wants you to work without
their involvement from this point (they are walking away from their desk), so
front-load any questions and ask them before you start.

## 1. Ask intent

Ask the user (AskUserQuestion) what they want as an outcome from this work:

- **PR + merge**: open PR, get CI green, merge.
- **PR only**: open PR, get CI green, do not merge.

Never merge unless the user chose merge.

## 2. Review

Get the diff against the merge-base with the default branch (include
uncommitted changes). Launch one subagent per lens, all in one message, in
parallel. Give each the diff range and repo path, not your own opinion of the
changes. Lenses:

- **Quality**:
  - Readability: Is the code easy to read and understand?
  - Naming: Are the names concise and clear? For example, `upgrade_key` vs
    `serialize_sandbox_key`: the former is vague and needs outside context;
    the latter describes the intent.
  - Structure: Are the design patterns, class structures and file contents
    appropriate for the change?
- **Bugs**:
  - Correctness: Is the business logic acting how you'd expect?
  - Edge cases: What scenarios are feasible and not handled?
  - Races: Are there common races that will cause issues?
- **Patterns**: misalignment with existing codebase conventions. Must read
  neighbouring code to compare.
- **DRY**: duplication within the diff and with existing helpers.
- **PR focus**: changes unrelated to the PR's purpose.
- **Comments**:
  - New comments: Keep to a minimum. Only add a comment that explains a
    non-obvious edge case, or code that is hard to understand without
    additional context. Keep it concise.
  - Existing comments: If an existing comment is out of date, update it if it
    still meets the criteria for new comments, else remove it.

Each subagent returns a list of findings: file, line, issue, suggested fix,
severity. No edits.

## 3. Apply

Judge each finding yourself. Apply ones that are correct and worth the change.
Skip nitpicks, false positives, and scope creep. Keep a short note of what you
skipped and why.

If some changes are large refactors that are worth making, consider putting
them in additional stacked PRs. Check the codebase for how it stacks PRs;
otherwise branch off this PR's branch. Smaller focused PRs are extremely
desirable.

## 4. Repeat

If step 3 changed code, go back to step 2 with fresh subagents. Stop when a
round gives no findings worth applying, or after 5 rounds.

## 5. PR and CI

1. Commit, push, open the PR.
2. Start `gh pr checks <n> --watch --fail-fast` in the background.
3. Also schedule a recurring 15-minute check (`/loop 15m` or CronCreate) that
   runs `gh pr checks <n>` so a stuck watcher or stuck job does not stall
   the work. Delete it when CI is final.
4. On failure, read the logs (`gh run view <id> --log-failed`).
   - Failure caused by this PR: fix, push, keep watching.
   - Failure not caused by this PR (flaky infra, broken main, secrets,
     outage): do not work around it. Try to diagnose the issue. If a retry or
     rebase could help, do that. If CI still fails, schedule a recurring
     15-minute monitor that checks the default branch for a fix (then rebase
     and re-run CI), and get user attention (see "Getting user attention").

## 6. Merge

Only if the user chose merge in step 1 and all checks pass: `gh pr merge <n>`
with the repo's normal merge method. Report the result.

## Getting user attention

- If `$AF_SESSION` is set:
  `af sessions attention --self --reason "<short reason>"`.
- Else use a notification tool or skill if one is available
  (e.g. PushNotification).
