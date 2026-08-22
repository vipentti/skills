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

Follow the `herdr` skill for CLI discovery, pane etiquette, and safety rules. This skill only defines the loop protocol.

## Guard

Both roles run this first and stop if it fails:

```bash
test "${HERDR_ENV:-}" = 1
```

## Windows and pi

On Windows, `herdr agent start --kind pi` does not work: Herdr spawns the bare executable `pi`, but Windows installs expose `pi.cmd`, so the spawn fails and the pane never reaches a ready agent. Do not retry it and do not debug it; agents get stuck in that loop.

Detect Windows before starting any reviewer:

```bash
case "$(uname -s)" in *MINGW*|*MSYS*|*CYGWIN*) win=1 ;; *) win=0 ;; esac
```

When `win=1`, skip `herdr agent start` for pi and go straight to the pane-run path in the dispatcher procedure. The same applies to any kind whose CLI is installed as a `.cmd` shim (npm and scoop installs). The pane-run path also serves as the fallback on any platform when `agent start` fails for another reason.

## Contracts

### Reviewer name

Derive a stable slug from the repo directory name plus branch or task: lowercase, replace non-alphanumeric runs with `-`, trim dashes, truncate to 25 chars. Reviewer name is `review-<slug>`: max 32 chars, matching `[a-z][a-z0-9_-]{0,31}`.

The same task always maps to the same reviewer name. Later rounds reuse the live reviewer instead of starting a new one. Names are unique across the whole Herdr session, so include the repo name to avoid collisions between repos.

### Findings file

One file per round, never overwritten:

```bash
slug=...    # slug without the review- prefix
round=...   # 1 for the first round, then +1 per re-review
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && mkdir -p .tmp/reviews && git check-ignore -q .tmp/reviews/probe; then
  dir="$(git rev-parse --show-toplevel)/.tmp/reviews"
else
  dir="${TMPDIR:-/tmp}/herdr-review-$slug"
fi
mkdir -p "$dir"
out="$dir/$slug-r$round.md"
```

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

Write your complete findings as Markdown to: <absolute path>

When done, send exactly one line back to the dispatcher, then end your turn:

  herdr agent prompt <dispatcher-pane-id> "REVIEW <VERDICT> <path>"

VERDICT is APPROVED, CHANGES_REQUESTED, or FAILED. For FAILED, put a short
reason in place of the path. Then end your turn and wait; the next round
arrives as a new prompt in this session.
```

Reviewer reply, always one line:

```
REVIEW APPROVED <path>
REVIEW CHANGES_REQUESTED <path>
REVIEW FAILED <short-reason>
```

A needs-discussion style verdict from the review skill maps to `CHANGES_REQUESTED`, with the open questions inside the file.

## Dispatcher procedure

1. Guard. Pick the review skill (default `deep-diff-review` unless the user says otherwise), the reviewer kind (default `pi`), and model plus thinking. If the user did not specify model or thinking, use the kind's defaults and say so in the request.

2. Compute the slug, round number, and findings path.

3. Reuse check:

```bash
herdr agent list | jq -r '.result.agents[] | select(.name=="review-<slug>") | "\(.pane_id) \(.agent_status)"'
```

A live entry means reuse it as the prompt target. If `agent_status` is `blocked`, inspect it with `herdr agent get` and `herdr agent read` first; clear a dialog with `herdr agent send-keys` only when you understand it.

4. Otherwise start one.

Non-Windows: split a sibling pane, preserving cwd and focus, read `.result.pane.pane_id` from the response, then start the agent with the requested model and thinking as native flags after `--`:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
herdr agent start review-<slug> --kind pi --pane <pane-id> --timeout 60000 -- --model <model> --thinking <thinking>
```

Windows with pi (see "Windows and pi" above), or any platform where `agent start` failed: split a fresh sibling pane, because a failed `agent start` can leave the pane dirty, then run the agent as a plain command and wait for Herdr to detect it:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
herdr pane run <pane-id> "pi --model <model> --thinking <thinking>"
for i in $(seq 1 30); do
  herdr agent get <pane-id> >/dev/null 2>&1 && break
  sleep 2
done
herdr agent get <pane-id>
```

Then name it so later rounds can reuse it by name:

```bash
herdr agent rename <pane-id> review-<slug>
```

Translate model and thinking into the kind's own flags; ask the user when unknown. If detection never succeeds, report and stop.

5. Send the request. No `--wait`: you are not waiting for the review.

```bash
herdr agent prompt review-<slug> "$(cat <<'EOF'
<request text from Contracts>
EOF
)"
```

If the send errors (`agent_blocked`, `agent_prompt_stalled`), inspect `herdr agent get` and `herdr agent read`, resolve, and resend once.

6. End your turn immediately. Tell the user the reviewer is running and that you will continue when the reply lands. Do not poll, sleep, or read the reviewer's pane.

7. When the reply arrives, read the findings file.

- `APPROVED`: report to the user. The loop is done. Leave the reviewer pane open unless the user asks to close it (`herdr pane close <pane-id>`).
- `CHANGES_REQUESTED`: address the findings, bump the round, then send the next request to the same reviewer and end your turn again:

```
Round <N>: the fixes for the previous findings are in the working tree.
Re-review <scope>. Write findings to <new absolute path>. Same reply
format as before.
```

- `FAILED`: diagnose with `herdr agent read review-<slug>`. Fix the stated reason (missing skill, wrong model) or restart the reviewer under the same name if it exited, then resend. If you cannot resolve it, report to the user.

## Reviewer procedure

You receive the request as a prompt in your pane.

1. Guard. Parse the request: review skill, scope, output path, dispatcher pane id, expected model and thinking.

2. Verify you are running the requested model and thinking. If not, reply `REVIEW FAILED wrong-model` and end your turn. Never review silently with a different setup.

3. Load the named review skill and follow it. If it is not installed, reply `REVIEW FAILED skill-not-installed`. Do not substitute a different methodology silently.

4. Perform the review per that skill: static inspection, findings scoped to the change, and no validation commands unless the skill allows them.

5. Write the full findings to the given path, creating parent directories as needed. Put the verdict on the first line, and keep the skill's own output format inside the file.

6. Send the reply, then end your turn at once. No `--wait`:

```bash
herdr agent prompt <dispatcher-pane-id> "REVIEW CHANGES_REQUESTED <path>"
```

7. Later rounds arrive as new prompts in this session. Keep context: verify earlier blockers are actually fixed, but focus each round on the delta.

## Rules

- Never use `--wait` on dispatch or reply sends. The sender always ends its turn right after a successful send; holding the turn open stalls delivery of the callback.
- One reviewer per task slug. Reuse it across rounds; start a new one only when it is no longer live.
- New findings file per round; never overwrite a previous round.
- Prompt by agent name or pane id parsed from `herdr` JSON, never by sidebar position or assumption.
- On Windows with pi, never attempt or retry `herdr agent start --kind pi`; use the pane-run path immediately.
- Do not close workspaces, tabs, or panes you did not create. The reviewer pane belongs to the loop; close it only when the user asks.
- If the dispatcher's pane was moved, its old pane id stops resolving for other clients; the latest request always carries the current return target.
