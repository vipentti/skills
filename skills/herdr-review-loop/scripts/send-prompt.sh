#!/usr/bin/env bash
# Submit a prompt to a herdr agent and VERIFY it actually started processing.
#
# `herdr agent prompt` can return success while the text was never submitted
# (swallowed Enter, slow paste handling), leaving the target silently idle.
# This script holds herdr to its accepted-send contract: an accepted prompt
# from a non-working state must produce an observed lifecycle change within
# ~5s. When that does not happen it retries, in order:
#   1. an Enter nudge (the text often sits unsubmitted in the input box)
#   2. one full resend
#
# Usage:
#   send-prompt.sh --target TARGET (--file PATH | "TEXT")
#
# Output (stdout, KEY=VALUE):
#   STATUS=CONFIRMED | CONFIRMED_NUDGE | CONFIRMED_RESEND | BLOCKED | UNCONFIRMED
#   STATE=<last observed agent_status>
#
# Exit codes: 0 confirmed, 2 target blocked, 1 unconfirmed.

set -euo pipefail

die() { printf 'send-prompt: %s\n' "$*" >&2; exit 1; }
log() { printf 'send-prompt: %s\n' "$*" >&2; }

usage() {
  printf 'usage: send-prompt.sh --target TARGET (--file PATH | "TEXT")\n' >&2
  exit 1
}

TARGET="" FILE=""
TEXTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --target)  TARGET="${2:-}"; shift 2 ;;
    --file)    FILE="${2:-}";   shift 2 ;;
    -h|--help) usage ;;
    *)
      TEXTS+=("$1"); shift
      [ ${#TEXTS[@]} -le 16 ] || die "too many arguments; pass --file PATH or one TEXT argument"
      ;;
  esac
done

[ -n "$TARGET" ] || { usage; }
if [ -n "$FILE" ]; then
  [ -f "$FILE" ] || die "file not found: $FILE"
  [ ${#TEXTS[@]} -eq 0 ] || die "pass either --file or TEXT, not both"
  TEXT="$(cat "$FILE")"
else
  [ ${#TEXTS[@]} -eq 1 ] || die "provide --file PATH or exactly one TEXT argument"
  TEXT="${TEXTS[0]}"
fi
[ -n "$TEXT" ] || die "refusing to send an empty prompt"

[ "${HERDR_ENV:-}" = 1 ] || die "HERDR_ENV != 1; this agent is not running inside Herdr"
command -v herdr >/dev/null 2>&1 || die "herdr not found on PATH"

state_of() {
  printf '%s' "${1:-}" \
    | grep -oE '"agent_status"[[:space:]]*:[[:space:]]*"[a-z]+"' \
    | head -n1 | sed 's/.*:[[:space:]]*"\([a-z]*\)"/\1/' || true
}

report() { printf 'STATUS=%s\nSTATE=%s\n' "$1" "$2"; }

pre="$(herdr agent get "$TARGET" 2>/dev/null)" \
  || die "no live agent at target '$TARGET'"
PRE_STATE="$(state_of "$pre")"
log "target '$TARGET' pre-send state: ${PRE_STATE:-unknown}"

if [ "$PRE_STATE" = "blocked" ]; then
  report BLOCKED blocked
  exit 2
fi

# 1. Primary send. --until working confirms the accepted-send contract and
#    returns as soon as the agent starts processing, not when it finishes.
if out="$(herdr agent prompt "$TARGET" "$TEXT" --wait --until working --timeout 9000 2>&1)"; then
  log "confirmed after send"
  report CONFIRMED working
  exit 0
fi
case "$out" in *agent_blocked*)
  report BLOCKED blocked
  exit 2
  ;; esac
log "no lifecycle change after send; trying Enter nudge"

# 2. Enter nudge: harmless if the input box is empty, submits the text if the
#    Enter key was swallowed after the paste.
herdr agent send-keys "$TARGET" enter >/dev/null 2>&1 || true
sleep 1
if herdr agent wait "$TARGET" --until working --timeout 8000 >/dev/null 2>&1; then
  log "confirmed after Enter nudge"
  report CONFIRMED_NUDGE working
  exit 0
fi

# 3. Last resort: resend the whole prompt once.
log "still no activity; resending prompt"
if out="$(herdr agent prompt "$TARGET" "$TEXT" --wait --until working --timeout 9000 2>&1)"; then
  log "confirmed after resend"
  report CONFIRMED_RESEND working
  exit 0
fi
case "$out" in *agent_blocked*)
  report BLOCKED blocked
  exit 2
  ;; esac

final="$(state_of "$(herdr agent get "$TARGET" 2>/dev/null)")"
report UNCONFIRMED "${final:-unknown}"
die "could not confirm submission to '$TARGET'; inspect with: herdr agent read $TARGET --source recent-unwrapped"
