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
- `findings-path.sh`: resolve an absolute findings-file path.

Every script prints `KEY=VALUE` lines on stdout, logs to stderr, exits nonzero on failure, and verifies it runs inside Herdr (`HERDR_ENV=1`). Never hand-type `herdr` commands for this loop. If a script fails, report its stderr to the user and stop; do not improvise.

## Contracts

### Reviewer name

Derive a stable slug from the repo directory name plus branch or task: lowercase, replace non-alphanumeric runs with `-`, trim dashes, truncate to 25 chars. Reviewer name is `review-<slug>`: max 32 chars, matching `[a-z][a-z0-9_-]{0,31}`.

The same task always maps to the same reviewer name. Later rounds reuse the live reviewer instead of starting a new one; `start-reviewer.sh` does this automatically.

### Findings file

One file per round, never overwritten. Resolve it with:

```bash
out="$(bash "<skill-dir>/scripts/findings-path.sh" --slug "$slug" --round "$round")"
```

It prints one absolute path: `<repo>/.tmp/reviews/<slug>-r<round>.md` when the repo's `.tmp/` is gitignored, otherwise `${TMPDIR:-/tmp}/herdr-review-<slug>/`.

Use absolute paths in all messages.

### Messages

Review request, dispatcher to reviewer:

```
You are the reviewer for task "<task description>".

Load the "<review-skill>" skill and follow it exactly. If the skill is not
installed, reply REVIEW FAILED skill-not-installed.

Scope: <what to review: branch, commit range, PR, or diff, plus a summary
of the intended change>

You must be running model "<model>" with thinking "<thinking>". If your
current model or thinking level differs, reply REVIEW FAILED wrong-model
instead of reviewing.

Write your complete findings as Markdown to: <absolute path>.
Always write the file, even when approving; non-blocking suggestions
belong there too.

When done, send exactly one line back to the dispatcher pane
<dispatcher-pane-id>, using exactly this helper script (do not search for
any other copy):

  bash "<send-prompt-path>" --target <dispatcher-pane-id> "REVIEW <VERDICT> <path>"

VERDICT is APPROVED, CHANGES_REQUESTED, or FAILED. For FAILED, put a short
reason in place of the path. Then end your turn and wait; the next round
arrives as a new prompt in this session. Do not call herdr commands
directly; the helper confirms delivery.
```

Reviewer reply, always one line:

```
REVIEW APPROVED <path>
REVIEW CHANGES_REQUESTED <path>
REVIEW FAILED <short-reason>
```

A needs-discussion style verdict from the review skill maps to `CHANGES_REQUESTED`, with the open questions inside the file.

## Dispatcher procedure

1. Pick the review skill (default `deep-diff-review` unless the user says otherwise), the reviewer kind (default `pi`), and model plus thinking. If the user did not specify model or thinking, use the kind's defaults and say so in the request.

2. Compute the slug and round number, then resolve the findings path per `Findings file`.

3. Start or reuse the reviewer:

```bash
bash "<skill-dir>/scripts/start-reviewer.sh" --slug "$slug" --kind pi --model <model> --thinking <thinking>
```

Read `TARGET`, `PANE_ID`, and `REUSED` from the output; `$TARGET` is the prompt target for every send below.

4. Resolve the helper's absolute path, write the request with `<send-prompt-path>` substituted, and send:

```bash
helper="<skill-dir>/scripts/send-prompt.sh"
helper="$(cd "$(dirname "$helper")" && pwd -P)/$(basename "$helper")"
```

```bash
req="$(dirname "$out")/$slug-r$round.request.txt"
cat > "$req" <<'EOF'
<request text from Contracts, with <send-prompt-path> set to the resolved helper path>
EOF

bash "$helper" --target "$TARGET" --file "$req"
```

Carrying the exact helper path spares the reviewer from locating the skill directory; the request must be self-sufficient.

`STATUS=CONFIRMED` in any variant means the reviewer started processing. `STATUS=BLOCKED` or `STATUS=UNCONFIRMED` means tell the user; do not end the turn silently expecting a reply that will never come.

5. End your turn immediately. Tell the user the reviewer is running and that you will continue when the reply lands. Do not poll, sleep, or read the reviewer's pane.

6. When the reply arrives, read the findings file, whatever the verdict: an `APPROVED` review can still carry non-blocking suggestions.

- `APPROVED`: the loop is done. Apply the suggestions that are clearly worth it, and list the rest for the user; do not start another review round for them. Report the verdict and what you did with the suggestions.
- `CHANGES_REQUESTED`: address the findings, bump the round, then repeat steps 2 to 5 with the same reviewer:

```
Round <N>: the fixes for the previous findings are in the working tree.
Re-review <scope>. Write findings to <new absolute path>. Same reply
format as before.
```

- `FAILED`: fix the stated reason (missing skill, wrong model), rerun `start-reviewer.sh` to get a healthy reviewer, and resend. If you cannot resolve it, report to the user.

## Reviewer procedure

You receive the request as a prompt in your pane.

1. Parse the request: review skill, scope, output path, dispatcher pane id, expected model and thinking, and the helper script path.

2. Verify you are running the requested model and thinking. If not, reply `REVIEW FAILED wrong-model` and end your turn. Never review silently with a different setup.

3. Load the named review skill and follow it. If it is not installed, reply `REVIEW FAILED skill-not-installed`. Do not substitute a different methodology silently.

4. Perform the review per that skill: static inspection, findings scoped to the change, and no validation commands unless the skill allows them.

5. Write the full findings to the given path, creating parent directories as needed. Put the verdict on the first line, and keep the skill's own output format inside the file.

6. Send the reply, then end your turn at once. Use the exact helper path from the request; fall back to this skill's `scripts/send-prompt.sh` only if that path does not exist:

```bash
bash "<helper path from the request>" --target <dispatcher-pane-id> "REVIEW CHANGES_REQUESTED <path>"
```

Confirm `STATUS=CONFIRMED` in some variant before ending your turn; otherwise retry once or record the failure in the findings file and tell the user.

7. Later rounds arrive as new prompts in this session. Keep context: verify earlier blockers are actually fixed, but focus each round on the delta.

## Rules

- Sends always go through `send-prompt.sh`. A confirmed send means the target started processing; the sender then ends its turn immediately. Never hold the turn open waiting for the other side to finish; the callback is the wake-up, and holding the turn stalls its delivery.
- One reviewer per task slug. Reuse it across rounds; `start-reviewer.sh` handles this.
- New findings file per round; never overwrite a previous round.
- Do not close workspaces, tabs, or panes you did not create. The reviewer pane belongs to the loop; close it only when the user asks.
- Script failure is a stop-and-report event, not an invitation to hand-roll Herdr commands.
