#!/usr/bin/env bash
# Orchestrated dispatcher-side request for herdr-review-loop.
# Resolves slug (auto-derived if not supplied), findings path, starts or
# reuses reviewer, composes review-request message from template, writes
# request file, and sends via send-prompt.sh.
#
# Slug is derived automatically from the repo directory name plus branch
# or task per the skill contract when --slug is omitted, so the
# implementer does not compute it. Findings path is also resolved
# internally via findings-path.sh.
#
# Usage:
#   send-review-request.sh --task "task description" --scope "scope"
#                          [--review-skill SKILL] [--model MODEL] [--thinking THINK]
#                          [--round N] [--slug SLUG] [--findings-path PATH] [--repo DIR]
#                          [--kind pi|codex|claude|cursor] [--dir DIR] [--direction right|down]
#                          [--timeout MS] [--dry-run] [--template PATH]
#
# Output (stdout, KEY=VALUE):
#   IMPLEMENTER_PANE_ID=wX:pY   dispatcher pane running this script
#   TARGET=name-or-pane-id  reviewer prompt target (correct target for send)
#   REVIEWER_PANE_ID=wX:pY  pane hosting the reviewer
#   PANE_ID=wX:pY           compatibility alias for REVIEWER_PANE_ID
#   REUSED=0|1              1 when existing reviewer was reused
#   FINDINGS_PATH=/abs/path reviewer findings file
#   REQUEST_FILE=/abs/path  written request file
#   STATUS=CONFIRMED|CONFIRMED_*|DRY_RUN|UNCONFIRMED|BLOCKED
#   STATE=<last observed agent_status> when not dry-run
#
# Exit codes: 0 success/confirmed/dry-run, 2 target blocked, 1 other failure.
# Logs on stderr with prefix send-review-request:. Verifies HERDR_ENV=1.
# Fail-stop: any helper failure stops and reports stderr.

set -euo pipefail

die() { printf 'send-review-request: %s\n' "$*" >&2; exit 1; }
log() { printf 'send-review-request: %s\n' "$*" >&2; }

usage() {
  printf 'usage: send-review-request.sh --task "task" --scope "scope"\n' >&2
  printf '                              [--review-skill SKILL] [--model M] [--thinking T]\n' >&2
  printf '                              [--round N] [--slug SLUG] [--findings-path PATH] [--repo DIR]\n' >&2
  printf '                              [--kind pi|codex|claude|cursor] [--dir DIR] [--direction right|down]\n' >&2
  printf '                              [--timeout MS] [--dry-run] [--template PATH]\n' >&2
  exit 1
}

SLUG="" TASK="" SCOPE="" REVIEW_SKILL="deep-diff-review" MODEL="" THINKING=""
ROUND="1" FINDINGS_PATH="" REPO="" KIND="pi" START_DIR="" DIRECTION="right" TIMEOUT_MS="60000"
TEMPLATE_PATH="" DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --slug)          SLUG="${2:-}";          shift 2 ;;
    --task)          TASK="${2:-}";          shift 2 ;;
    --scope)         SCOPE="${2:-}";         shift 2 ;;
    --review-skill)  REVIEW_SKILL="${2:-}";  shift 2 ;;
    --model)         MODEL="${2:-}";         shift 2 ;;
    --thinking)      THINKING="${2:-}";      shift 2 ;;
    --round)         ROUND="${2:-}";         shift 2 ;;
    --findings-path) FINDINGS_PATH="${2:-}"; shift 2 ;;
    --repo)          REPO="${2:-}";          shift 2 ;;
    --kind)          KIND="${2:-}";          shift 2 ;;
    --dir)           START_DIR="${2:-}";     shift 2 ;;
    --direction)     DIRECTION="${2:-}";     shift 2 ;;
    --timeout)       TIMEOUT_MS="${2:-}";    shift 2 ;;
    --template)      TEMPLATE_PATH="${2:-}"; shift 2 ;;
    --dry-run)       DRY_RUN=1;              shift ;;
    -h|--help)       usage ;;
    --)              shift; break ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$TASK" ] || die "--task is required (task description)"
[ -n "$SCOPE" ] || die "--scope is required (what to review)"
case "$ROUND" in ''|*[!0-9]*) die "--round must be an integer" ;; esac
[ "$ROUND" -ge 1 ] || die "--round must be >= 1"
case "$DIRECTION" in right|down) ;; *) die "--direction must be right or down" ;; esac
case "$TIMEOUT_MS" in ''|*[!0-9]*) die "--timeout must be milliseconds" ;; esac
[ "${HERDR_ENV:-}" = 1 ] || die "HERDR_ENV != 1; this agent is not running inside Herdr"
IMPLEMENTER_PANE_ID="${HERDR_PANE_ID:-}"
[ -n "$IMPLEMENTER_PANE_ID" ] || die "HERDR_PANE_ID is missing; cannot report the implementer pane"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

START_REVIEWER="$SCRIPT_DIR/start-reviewer.sh"
SEND_PROMPT="$SCRIPT_DIR/send-prompt.sh"
FINDINGS_HELPER="$SCRIPT_DIR/findings-path.sh"
[ -f "$START_REVIEWER" ] || die "start-reviewer.sh not found: $START_REVIEWER"
[ -f "$SEND_PROMPT" ] || die "send-prompt.sh not found: $SEND_PROMPT"
[ -f "$FINDINGS_HELPER" ] || die "findings-path.sh not found: $FINDINGS_HELPER"

SEND_PROMPT_ABS="$(cd "$(dirname "$SEND_PROMPT")" && pwd -P)/$(basename "$SEND_PROMPT")"

# Auto-derive slug when not supplied, per skill contract:
# repo directory name plus branch or task, lowercase, non-alphanumeric runs to '-', trim dashes, truncate 25.
derive_slug() {
  local repo_top repo_name branch raw slug
  if [ -n "${REPO:-}" ] && [ -d "$REPO" ]; then
    repo_top="$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$REPO")"
  else
    repo_top="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
  fi
  repo_name="$(basename "$repo_top")"
  branch="$(git -C "$repo_top" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
    branch="$TASK"
  fi
  raw="${repo_name} ${branch}"
  slug="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  slug="$(printf '%s' "$slug" | cut -c1-25 | sed -E 's/-+$//')"
  if [ -z "$slug" ]; then slug="task"; fi
  printf '%s' "$slug"
}

if [ -z "$SLUG" ]; then
  SLUG="$(derive_slug)"
  log "derived slug: $SLUG (from repo/branch/task)"
fi

REPO_ARG=()
if [ -n "$REPO" ]; then
  REPO_ARG=(--repo "$REPO")
fi
if [ -z "$FINDINGS_PATH" ]; then
  log "resolving findings path for slug=$SLUG round=$ROUND"
  FINDINGS_PATH="$(bash "$FINDINGS_HELPER" --slug "$SLUG" --round "$ROUND" "${REPO_ARG[@]}")"
  [ -n "$FINDINGS_PATH" ] || die "findings-path.sh returned empty path"
fi
case "$FINDINGS_PATH" in
  /*) ;;
  *) die "--findings-path must be absolute: $FINDINGS_PATH" ;;
esac
log "findings path: $FINDINGS_PATH"

mkdir -p "$(dirname "$FINDINGS_PATH")"

REQUEST_FILE="$(dirname "$FINDINGS_PATH")/${SLUG}-r${ROUND}.request.txt"

if [ -n "$TEMPLATE_PATH" ]; then
  [ -f "$TEMPLATE_PATH" ] || die "template not found: $TEMPLATE_PATH"
  TEMPLATE_FILE="$TEMPLATE_PATH"
else
  TEMPLATE_FILE=""
  for c in \
    "$SKILL_DIR/templates/review-request.md" \
    "$SCRIPT_DIR/review-request.template.md" \
    "$SCRIPT_DIR/../templates/review-request.md"
  do
    if [ -f "$c" ]; then TEMPLATE_FILE="$c"; break; fi
  done
  if [ -z "$TEMPLATE_FILE" ]; then
    log "no external template found; using built-in template"
  else
    log "using template: $TEMPLATE_FILE"
  fi
fi

MODEL_DISPLAY="${MODEL:-default for $KIND}"
THINKING_DISPLAY="${THINKING:-default for $KIND}"
if [ -z "$MODEL" ]; then
  log "model not specified; using kind default ($KIND)"
fi
if [ -z "$THINKING" ]; then
  log "thinking not specified; using kind default"
fi

# Helper to parse pane_id from herdr JSON (same logic as start-reviewer.sh)
parse_pane_id() {
  local json="$1" v=""
  if command -v jq >/dev/null 2>&1; then
    v="$(printf '%s' "$json" | jq -r '.. | .pane_id? // empty' 2>/dev/null | head -n1 || true)"
  fi
  if [ -z "$v" ]; then
    v="$(printf '%s' "$json" \
      | grep -oE '"pane_id"[[:space:]]*:[[:space:]]*"[A-Za-z0-9]+:p[A-Za-z0-9]+"' \
      | head -n1 | sed 's/.*:[[:space:]]*"\([^"]*\)"/\1/')"
  fi
  printf '%s' "$v"
}

TARGET="" REVIEWER_PANE_ID="" PANE_ID="" REUSED=""

# Dry-run: probe without creating reviewer, compose and print without sending
if [ "$DRY_RUN" -eq 1 ]; then
  NAME="review-$SLUG"
  REUSED="0"
  REVIEWER_PANE_ID="(not yet created)"
  TARGET="$NAME"
  # Non-creating probe: if reviewer already live, show its actual pane id
  if command -v herdr >/dev/null 2>&1; then
    if out="$(herdr agent get "$NAME" 2>/dev/null)"; then
      pane="$(parse_pane_id "$out")"
      if [ -n "$pane" ]; then
        REVIEWER_PANE_ID="$pane"
        TARGET="$NAME"
        REUSED="1"
        log "dry-run: reusing live reviewer '$NAME' at $pane"
      fi
    else
      log "dry-run: no live reviewer '$NAME'; would create new one"
    fi
  fi
  log "dry-run: dispatcher pane: $IMPLEMENTER_PANE_ID"
  log "dry-run: reviewer target: $TARGET (pane $REVIEWER_PANE_ID, reused=$REUSED)"
else
  # Normal path: start or reuse reviewer via start-reviewer.sh (single invocation)
  SR_ARGS=(--slug "$SLUG" --kind "$KIND" --direction "$DIRECTION" --timeout "$TIMEOUT_MS")
  if [ -n "$MODEL" ]; then SR_ARGS+=(--model "$MODEL"); fi
  if [ -n "$THINKING" ]; then SR_ARGS+=(--thinking "$THINKING"); fi
  if [ -n "$START_DIR" ]; then SR_ARGS+=(--dir "$START_DIR"); fi

  sr_out="$(mktemp)"
  sr_err="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f \"$sr_out\" \"$sr_err\"" EXIT
  if ! bash "$START_REVIEWER" "${SR_ARGS[@]}" >"$sr_out" 2>"$sr_err"; then
    cat "$sr_err" >&2 || true
    cat "$sr_out" >&2 || true
    rm -f "$sr_out" "$sr_err"
    trap - EXIT
    die "start-reviewer.sh failed"
  fi
  cat "$sr_err" >&2 || true
  SR_STDOUT="$(cat "$sr_out")"
  rm -f "$sr_out" "$sr_err"
  trap - EXIT

  TARGET="$(printf '%s\n' "$SR_STDOUT" | grep -E '^TARGET=' | tail -n1 | cut -d= -f2-)"
  REVIEWER_PANE_ID="$(printf '%s\n' "$SR_STDOUT" | grep -E '^REVIEWER_PANE_ID=' | tail -n1 | cut -d= -f2-)"
  PANE_ID_FALLBACK="$(printf '%s\n' "$SR_STDOUT" | grep -E '^PANE_ID=' | tail -n1 | cut -d= -f2-)"
  IMPLEMENTER_FROM_SR="$(printf '%s\n' "$SR_STDOUT" | grep -E '^IMPLEMENTER_PANE_ID=' | tail -n1 | cut -d= -f2-)"
  REUSED="$(printf '%s\n' "$SR_STDOUT" | grep -E '^REUSED=' | tail -n1 | cut -d= -f2-)"

  if [ -z "$REVIEWER_PANE_ID" ] && [ -n "$PANE_ID_FALLBACK" ]; then
    REVIEWER_PANE_ID="$PANE_ID_FALLBACK"
  fi
  PANE_ID="$REVIEWER_PANE_ID"
  if [ -n "$IMPLEMENTER_FROM_SR" ]; then
    IMPLEMENTER_PANE_ID="$IMPLEMENTER_FROM_SR"
  fi
  [ -n "$TARGET" ] || die "failed to parse TARGET from start-reviewer output: $SR_STDOUT"
  [ -n "$REVIEWER_PANE_ID" ] || die "failed to parse REVIEWER_PANE_ID from start-reviewer output: $SR_STDOUT"
  [ -n "$REUSED" ] || REUSED="0"

  log "dispatcher pane: $IMPLEMENTER_PANE_ID"
  log "reviewer target: $TARGET (pane $REVIEWER_PANE_ID, reused=$REUSED)"

  PANE_ID="$REVIEWER_PANE_ID"
fi

# Ensure PANE_ID is set for dry-run path
if [ -z "${PANE_ID:-}" ]; then
  PANE_ID="$REVIEWER_PANE_ID"
fi

# Compose message
if [ -n "${TEMPLATE_FILE:-}" ] && [ -f "$TEMPLATE_FILE" ]; then
  TEMPLATE_CONTENT="$(cat "$TEMPLATE_FILE")"
else
  TEMPLATE_CONTENT='You are the reviewer for task "{{TASK}}".

Load the "{{REVIEW_SKILL}}" skill and follow it exactly. If the skill is not
installed, reply REVIEW FAILED skill-not-installed.

Scope: {{SCOPE}}

Write your complete findings as Markdown to: {{FINDINGS_PATH}}.
Always write the file, even when approving; non-blocking suggestions
belong there too.

When done, send exactly one line back to the dispatcher pane
{{DISPATCHER_PANE_ID}}, using exactly this helper script (do not search for
any other copy):

  bash "{{SEND_PROMPT_PATH}}" --target {{DISPATCHER_PANE_ID}} "REVIEW <VERDICT> <path>"

VERDICT is APPROVED, APPROVED_WITH_SUGGESTIONS, CHANGES_REQUESTED, or
FAILED. Use APPROVED_WITH_SUGGESTIONS when the review passes but includes
non-blocking suggestions. Use CHANGES_REQUESTED when any finding must be
fixed before approval. For FAILED, put a short reason in place of the path.
Then end your turn and wait; the next round arrives as a new prompt in this
session. Do not call herdr commands directly; the helper confirms delivery.'
fi

MSG="$TEMPLATE_CONTENT"
MSG="${MSG//\{\{TASK\}\}/$TASK}"
MSG="${MSG//\{\{REVIEW_SKILL\}\}/$REVIEW_SKILL}"
MSG="${MSG//\{\{SCOPE\}\}/$SCOPE}"
MSG="${MSG//\{\{MODEL\}\}/$MODEL_DISPLAY}"
MSG="${MSG//\{\{THINKING\}\}/$THINKING_DISPLAY}"
MSG="${MSG//\{\{FINDINGS_PATH\}\}/$FINDINGS_PATH}"
MSG="${MSG//\{\{IMPLEMENTER_PANE_ID\}\}/$IMPLEMENTER_PANE_ID}"
MSG="${MSG//\{\{DISPATCHER_PANE_ID\}\}/$IMPLEMENTER_PANE_ID}"
MSG="${MSG//\{\{SEND_PROMPT_PATH\}\}/$SEND_PROMPT_ABS}"

mkdir -p "$(dirname "$REQUEST_FILE")"
printf '%s\n' "$MSG" > "$REQUEST_FILE"
log "wrote request to $REQUEST_FILE"

if [ "$DRY_RUN" -eq 1 ]; then
  log "DRY-RUN: would send to TARGET=$TARGET (reviewer pane $REVIEWER_PANE_ID) from dispatcher $IMPLEMENTER_PANE_ID"
  log "DRY-RUN: request file $REQUEST_FILE (not sent)"
  printf 'IMPLEMENTER_PANE_ID=%s\nTARGET=%s\nREVIEWER_PANE_ID=%s\nPANE_ID=%s\nREUSED=%s\nFINDINGS_PATH=%s\nREQUEST_FILE=%s\nSTATUS=%s\nSTATE=%s\n' \
    "$IMPLEMENTER_PANE_ID" "$TARGET" "$REVIEWER_PANE_ID" "$PANE_ID" "$REUSED" "$FINDINGS_PATH" "$REQUEST_FILE" "DRY_RUN" "dry-run"
  printf 'send-review-request: --- DRY-RUN REQUEST BEGIN (target %s) ---\n' "$TARGET" >&2
  cat "$REQUEST_FILE" >&2
  printf 'send-review-request: --- DRY-RUN REQUEST END ---\n' >&2
  printf 'send-review-request: dry-run target selection: TARGET=%s IMPLEMENTER_PANE_ID=%s REVIEWER_PANE_ID=%s\n' "$TARGET" "$IMPLEMENTER_PANE_ID" "$REVIEWER_PANE_ID" >&2
  exit 0
fi

log "sending request to $TARGET via send-prompt.sh"
SP_TMP_OUT="$(mktemp)"
SP_TMP_ERR="$(mktemp)"
trap 'rm -f "$SP_TMP_OUT" "$SP_TMP_ERR"' EXIT
if bash "$SEND_PROMPT" --target "$TARGET" --file "$REQUEST_FILE" >"$SP_TMP_OUT" 2>"$SP_TMP_ERR"; then
  cat "$SP_TMP_ERR" >&2 || true
  SP_OUT="$(cat "$SP_TMP_OUT")"
  SP_STATUS="$(printf '%s\n' "$SP_OUT" | grep -E '^STATUS=' | tail -n1 | cut -d= -f2-)"
  SP_STATE="$(printf '%s\n' "$SP_OUT" | grep -E '^STATE=' | tail -n1 | cut -d= -f2-)"
  log "send confirmed: STATUS=$SP_STATUS STATE=$SP_STATE"
else
  rc=$?
  cat "$SP_TMP_ERR" >&2 || true
  SP_OUT="$(cat "$SP_TMP_OUT" 2>/dev/null || true)"
  SP_STATUS="$(printf '%s\n' "$SP_OUT" | grep -E '^STATUS=' | tail -n1 | cut -d= -f2-)"
  SP_STATE="$(printf '%s\n' "$SP_OUT" | grep -E '^STATE=' | tail -n1 | cut -d= -f2-)"
  printf 'IMPLEMENTER_PANE_ID=%s\nTARGET=%s\nREVIEWER_PANE_ID=%s\nPANE_ID=%s\nREUSED=%s\nFINDINGS_PATH=%s\nREQUEST_FILE=%s\nSTATUS=%s\nSTATE=%s\n' \
    "$IMPLEMENTER_PANE_ID" "$TARGET" "$REVIEWER_PANE_ID" "$PANE_ID" "$REUSED" "$FINDINGS_PATH" "$REQUEST_FILE" "${SP_STATUS:-UNCONFIRMED}" "${SP_STATE:-unknown}"
  if [ "$SP_STATUS" = "BLOCKED" ]; then
    exit 2
  fi
  die "send-prompt.sh failed (rc=$rc) STATUS=${SP_STATUS:-unknown} STATE=${SP_STATE:-unknown}"
fi

printf 'IMPLEMENTER_PANE_ID=%s\nTARGET=%s\nREVIEWER_PANE_ID=%s\nPANE_ID=%s\nREUSED=%s\nFINDINGS_PATH=%s\nREQUEST_FILE=%s\nSTATUS=%s\nSTATE=%s\n' \
  "$IMPLEMENTER_PANE_ID" "$TARGET" "$REVIEWER_PANE_ID" "$PANE_ID" "$REUSED" "$FINDINGS_PATH" "$REQUEST_FILE" "${SP_STATUS:-CONFIRMED}" "${SP_STATE:-working}"

case "${SP_STATUS:-}" in
  CONFIRMED|CONFIRMED_NUDGE|CONFIRMED_RESEND) exit 0 ;;
  *) die "unexpected STATUS after send: ${SP_STATUS:-empty} (expected CONFIRMED variant)" ;;
esac
