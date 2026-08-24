---
name: herdr-review-loop
description: Run an implement-and-review loop between two agents over Herdr. Use when the user asks to dispatch a reviewer agent, send finished work to a reviewer via Herdr, or act as the reviewer agent that receives such a request and reports findings back. Requires HERDR_ENV=1.
---

# Herdr review loop

Two agents cooperate through Herdr:

- The dispatcher implements a feature, then hands the change to a reviewer agent in a neighboring pane.
- The reviewer reviews with a named review skill, writes findings to a file, and prompts the dispatcher back with the path.
- The dispatcher fixes and re-submits to the same reviewer. The loop repeats until the reviewer approves.

Neither side polls while waiting. The dispatcher ends its turn right after dispatching; the reviewer's reply arrives as the next prompt. The reviewer ends its turn right after replying. The reply itself is the wake-up.

## Scripts

All Herdr interaction in this loop goes through the helper scripts next to this file (resolve their paths against this skill's directory):

- `start-reviewer.sh`: idempotently start or reuse a named reviewer agent. Handles reuse probes, platform differences (including Windows, where `herdr agent start --kind pi` cannot launch `.cmd` shims such as `pi.cmd`, so it splits a pane, runs the CLI directly, waits for detection, and renames), and fallbacks.
- `send-prompt.sh`: submit a prompt and confirm the target actually started processing; retries with an Enter nudge and one resend when a submission was swallowed.
- `findings-path.sh`: internal helper that resolves an absolute findings-file path. You do not need to call it directly; `send-review-request.sh` calls it for you.
- `send-review-request.sh`: orchestrated dispatcher-side request. Performs the entire request step in one command: derives the reviewer slug automatically, resolves the findings path (via `findings-path.sh`), starts or reuses the reviewer (via `start-reviewer.sh`), composes the full review-request message from the template at `templates/review-request.md` (fallback: built-in template) with the correct pane ids substituted, writes the request file, sends it via `send-prompt.sh`, and confirms `STATUS=CONFIRMED`. Adds `--dry-run` to print the fully composed request and the target it would use without sending.

The Herdr-facing scripts print `KEY=VALUE` lines on stdout, log to stderr, exit nonzero on failure, and verify they run inside Herdr (`HERDR_ENV=1`). `start-reviewer.sh` always returns `CURRENT_PANE_ID`, `TARGET`, `REVIEWER_PANE_ID`, the compatibility alias `PANE_ID`, and `REUSED`. `send-prompt.sh` always returns `CURRENT_PANE_ID`, `TARGET`, `STATUS`, and `STATE`. `send-review-request.sh` returns `CURRENT_PANE_ID`, `TARGET`, `REVIEWER_PANE_ID`, `PANE_ID`, `REUSED`, `FINDINGS_PATH`, `REQUEST_FILE`, `STATUS`, and `STATE` (`STATUS=DRY_RUN` in dry-run). Never hand-type `herdr` commands for this loop. If a script fails, report its stderr to the user and stop; do not improvise.

## Contracts

### Reviewer name

Reviewer name is `review-<slug>`: max 32 chars, matching `[a-z][a-z0-9_-]{0,31}`. The slug is derived automatically by `send-review-request.sh` from the repo directory name plus branch or task (lowercase, non-alphanumeric runs to `-`, trim dashes, truncate to 25 chars). Pass `--slug` only to override the derived value. Later rounds reuse the live reviewer instead of starting a new one; `send-review-request.sh` (via `start-reviewer.sh`) does this automatically.

### Findings file

One file per round, never overwritten. The path is resolved internally by `send-review-request.sh` via `findings-path.sh`: `<repo>/.tmp/reviews/<slug>-r<round>.md` when the repo's `.tmp/` is gitignored, otherwise `${TMPDIR:-/tmp}/herdr-review-<slug>/`. You do not need to compute or pass the path; the script writes the request file alongside it and embeds the absolute path in the message.

### Messages

The review-request message template lives in this skill at `templates/review-request.md` (with a built-in fallback in `send-review-request.sh`). The script renders it with the task, review skill, scope, model, thinking, findings path, dispatcher pane id, and helper path already substituted.

Reviewer reply, always one line:

```
REVIEW APPROVED <path>
REVIEW APPROVED_WITH_SUGGESTIONS <path>
REVIEW CHANGES_REQUESTED <path>
REVIEW FAILED <short-reason>
```

A needs-discussion style verdict from the review skill maps to `CHANGES_REQUESTED`, with the open questions inside the file.

## Dispatcher procedure

1. Pick the review skill (default `deep-diff-review` unless the user says otherwise), the reviewer kind (default `pi`), and model plus thinking. If the user did not specify model or thinking, use the kind's defaults and say so in the request.

2. Dispatch the review in one command. `send-review-request.sh` derives the slug, resolves the findings path, renders `templates/review-request.md` with the correct pane ids, writes the request file, and sends it:

```bash
bash "<skill-dir>/scripts/send-review-request.sh" \
  --task "<task description>" \
  --scope "<what to review: branch, commit range, PR, or diff, plus a summary of the intended change>" \
  --review-skill deep-diff-review \
  --model <model> --thinking <thinking> \
  --round "$round"
```

The slug and findings path are derived automatically; pass `--slug`, `--findings-path`, `--repo`, `--kind`, `--dir`, `--direction`, `--timeout`, or `--template` only to override defaults (see `send-review-request.sh --help`). The script logs to stderr and prints `CURRENT_PANE_ID`, `TARGET`, `REVIEWER_PANE_ID`, `PANE_ID`, `REUSED`, `FINDINGS_PATH`, `REQUEST_FILE`, `STATUS`, and `STATE` on stdout. `STATUS=CONFIRMED` (or `CONFIRMED_NUDGE` / `CONFIRMED_RESEND`) means the reviewer started processing. `STATUS=BLOCKED` or `STATUS=UNCONFIRMED` means tell the user; do not end the turn silently expecting a reply that will never come.

Preview without sending:

```bash
bash "<skill-dir>/scripts/send-review-request.sh" --task "<task>" --scope "<scope>" --round "$round" --dry-run
```

This prints the fully composed request (and the target it would use) to stderr and `STATUS=DRY_RUN` on stdout, without starting a non-existent reviewer beyond a reuse probe and without invoking `send-prompt.sh`. Use it to verify template rendering and target selection.

3. End your turn immediately. Tell the user the reviewer is running and that you will continue when the reply lands. Do not poll, sleep, or read the reviewer's pane.

4. When the reply arrives, read the findings file, whatever the verdict.

- `APPROVED`: the loop is done. No suggestions are expected, but handle any suggestions in the file as non-blocking and report what you did with them.
- `APPROVED_WITH_SUGGESTIONS`: the loop is done. Apply the suggestions that are clearly worth it, and list the rest for the user; do not start another review round for them.
- `CHANGES_REQUESTED`: address the findings, bump the round, then repeat step 2 with the same reviewer (same task, so the derived slug reuses the reviewer):

```
Round <N>: the fixes for the previous findings are in the working tree.
Re-review <scope>. Write findings to <new absolute path>. Same reply
format as before.
```

The next invocation of `send-review-request.sh` with an incremented `--round` reuses the same reviewer automatically.

- `FAILED`: fix the stated reason (missing skill, wrong model), then rerun `send-review-request.sh` (it reruns `start-reviewer.sh` to get a healthy reviewer and resends). If you cannot resolve it, report to the user.

## Reviewer procedure

You receive the request as a prompt in your pane.

1. Parse the request: review skill, scope, output path, dispatcher pane id, expected model and thinking, and the helper script path.

2. Verify you are running the requested model and thinking. If not, reply `REVIEW FAILED wrong-model` and end your turn. Never review silently with a different setup.

3. Load the named review skill and follow it. If it is not installed, reply `REVIEW FAILED skill-not-installed`. Do not substitute a different methodology silently.

4. Perform the review per that skill: static inspection, findings scoped to the change, and no validation commands unless the skill allows them. Map the result to the transport verdict: use `APPROVED` with no suggestions, `APPROVED_WITH_SUGGESTIONS` when only non-blocking suggestions remain, `CHANGES_REQUESTED` when any fix is required, and `FAILED` when the review cannot be completed. Keep the named review skill's own verdict and output format in the findings file.

5. Write the full findings to the given path, creating parent directories as needed. Put the review skill's verdict on the first line, and keep its output format inside the file.

6. Send the reply, then end your turn at once. Use the exact helper path from the request; fall back to this skill's `scripts/send-prompt.sh` only if that path does not exist:

```bash
bash "<helper path from the request>" --target <dispatcher-pane-id> "REVIEW CHANGES_REQUESTED <path>"
```

Confirm `STATUS=CONFIRMED` in some variant before ending your turn; otherwise retry once or record the failure in the findings file and tell the user.

7. Later rounds arrive as new prompts in this session. Keep context: verify earlier blockers are actually fixed, but focus each round on the delta.

## Rules

- Dispatcher sends go through `send-review-request.sh` (which calls `send-prompt.sh` internally); reviewer replies go through `send-prompt.sh` directly. A confirmed send means the target started processing; the sender then ends its turn immediately. Never hold the turn open waiting for the other side to finish; the callback is the wake-up, and holding the turn stalls its delivery.
- One reviewer per task slug. Reuse it across rounds; `start-reviewer.sh` and `send-review-request.sh` handle this.
- New findings file per round; never overwrite a previous round.
- Do not close workspaces, tabs, or panes you did not create. The reviewer pane belongs to the loop; close it only when the user asks.
- Script failure is a stop-and-report event, not an invitation to hand-roll Herdr commands.
