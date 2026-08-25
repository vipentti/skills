#!/usr/bin/env bash
# Start or reuse a herdr reviewer agent for the herdr-review-loop skill.
# Idempotent: safe to run again at any time; prints the live reviewer when one exists.
#
# Usage:
#   start-reviewer.sh --slug SLUG [--kind pi|codex|claude|cursor] [--model M] [--thinking T]
#                     [--name NAME] [--dir DIR] [--direction right|down]
#                     [--timeout MS] [-- EXECUTABLE_ARGS...]
#
# Output: KEY=VALUE lines on stdout, logs on stderr.
#   IMPLEMENTER_PANE_ID=wX:pY pane running this script, usually the dispatcher
#   TARGET=name-or-pane-id  pass this to `send-prompt.sh`
#   REVIEWER_PANE_ID=wX:pY  pane hosting the reviewer
#   PANE_ID=wX:pY           compatibility alias for REVIEWER_PANE_ID
#   REUSED=0|1              1 when an existing live reviewer was reused
#
# Exit codes: 0 success, 1 environment or herdr failure.
# Encodes the platform rules: on Windows (MINGW/MSYS/CYGWIN) it skips
# `herdr agent start` for kinds installed as .cmd shims (pi, cursor), splits
# a pane, runs the explicit .cmd shim (pi.cmd, cursor-agent.cmd), waits for
# detection, then renames. Real-binary kinds (codex, claude) try `agent
# start` on any platform, with the pane-run fallback.

set -euo pipefail

die() { printf 'start-reviewer: %s\n' "$*" >&2; exit 1; }
log() { printf 'start-reviewer: %s\n' "$*" >&2; }

usage() {
  printf 'usage: start-reviewer.sh --slug SLUG [--kind pi|codex|claude|cursor] [--model M] [--thinking T]\n' >&2
  printf '                   [--name NAME] [--dir DIR] [--direction right|down]\n' >&2
  printf '                   [--timeout MS] [-- EXECUTABLE_ARGS...]\n' >&2
  exit 1
}

SLUG="" KIND="pi" MODEL="" THINKING="" NAME=""
START_DIR="$PWD" DIRECTION="right" TIMEOUT_MS="60000"
AGENT_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --slug)      SLUG="${2:-}";       shift 2 ;;
    --kind)      KIND="${2:-}";       shift 2 ;;
    --model)     MODEL="${2:-}";      shift 2 ;;
    --thinking)  THINKING="${2:-}";   shift 2 ;;
    --name)      NAME="${2:-}";       shift 2 ;;
    --dir)       START_DIR="${2:-}";  shift 2 ;;
    --direction) DIRECTION="${2:-}";  shift 2 ;;
    --timeout)   TIMEOUT_MS="${2:-}"; shift 2 ;;
    --)          shift; AGENT_ARGS=("$@"); break ;;
    -h|--help)   usage ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$SLUG" ] || die "--slug is required"
case "$DIRECTION" in right|down) ;; *) die "--direction must be right or down" ;; esac
case "$TIMEOUT_MS" in ''|*[!0-9]*) die "--timeout must be milliseconds" ;; esac

NAME="${NAME:-review-$SLUG}"
printf '%s' "$NAME" | grep -Eq '^[a-z][a-z0-9_-]{0,31}$' \
  || die "reviewer name '$NAME' must match [a-z][a-z0-9_-]{0,31}"

[ "${HERDR_ENV:-}" = 1 ] || die "HERDR_ENV != 1; this agent is not running inside Herdr"
command -v herdr >/dev/null 2>&1 || die "herdr not found on PATH"
IMPLEMENTER_PANE_ID="${HERDR_PANE_ID:-}"
[ -n "$IMPLEMENTER_PANE_ID" ] || die "HERDR_PANE_ID is missing; cannot report the implementer pane"

report() { # $1=target $2=reviewer_pane_id $3=reused
  printf 'IMPLEMENTER_PANE_ID=%s\nTARGET=%s\nREVIEWER_PANE_ID=%s\nPANE_ID=%s\nREUSED=%s\n' \
    "$IMPLEMENTER_PANE_ID" "$1" "$2" "$2" "$3"
}

# Read a pane id out of herdr JSON. Prefers jq; falls back to a narrow scan,
# since pane ids always look like wX:pY.
pane_id_of() {
  local json="$1" v=""
  if command -v jq >/dev/null 2>&1; then
    v="$(printf '%s' "$json" | jq -r '.. | .pane_id? // empty' 2>/dev/null | head -n1 || true)"
  fi
  if [ -z "$v" ]; then
    v="$(printf '%s' "$json" \
      | grep -oE '"pane_id"[[:space:]]*:[[:space:]]*"[A-Za-z0-9]+:p[A-Za-z0-9]+"' \
      | head -n1 | sed 's/.*:[[:space:]]*"\(.*\)"/\1/')"
  fi
  printf '%s' "$v"
}

split_pane() {
  local out id
  out="$(herdr pane split --current --direction "$DIRECTION" --cwd "$START_DIR" --no-focus)" \
    || die "pane split failed: $out"
  id="$(pane_id_of "$out")"
  [ -n "$id" ] || die "no pane id in split response; install jq or inspect manually: $out"
  printf '%s' "$id"
}

# Assemble native CLI arguments from model/thinking plus any passthrough args.
# The thinking knob has different flag names per kind; unknown kinds keep the
# historical pi-style passthrough.
ARGS=()
case "$KIND" in
  claude)
    [ -n "$MODEL" ] && ARGS+=("--model" "$MODEL")
    [ -n "$THINKING" ] && ARGS+=("--effort" "$THINKING")
    ;;
  codex)
    [ -n "$MODEL" ] && ARGS+=("--model" "$MODEL")
    [ -n "$THINKING" ] && ARGS+=("-c" "model_reasoning_effort=$THINKING")
    ;;
  cursor)
    [ -n "$MODEL" ] && ARGS+=("--model" "$MODEL")
    if [ -n "$THINKING" ]; then
      log "thinking: cursor has no standalone thinking flag; reasoning is model-encoded (e.g. --model 'claude-opus-4-8[effort=high]'); --thinking ignored"
    fi
    ;;
  *)
    [ -n "$MODEL" ] && ARGS+=("--model" "$MODEL")
    [ -n "$THINKING" ] && ARGS+=("--thinking" "$THINKING")
    ;;
esac
if [ ${#AGENT_ARGS[@]} -gt 0 ]; then ARGS+=("${AGENT_ARGS[@]}"); fi

# Canonical executable for the kind. The pane-run path and the Windows .cmd
# shim detection use this; cursor's CLI binary is `cursor-agent`.
agent_exec="$KIND"
case "$KIND" in
  cursor) agent_exec="cursor-agent" ;;
esac

# 1. Reuse a live reviewer with the same name, regardless of how it was started.
if out="$(herdr agent get "$NAME" 2>/dev/null)"; then
  pane="$(pane_id_of "$out")"
  [ -n "$pane" ] || die "live reviewer '$NAME' has no readable pane id"
  log "reusing live reviewer '$NAME'"
  report "$NAME" "$pane" 1
  exit 0
fi

# 2. Prefer `herdr agent start` when the kind launches from a real binary.
#    On Windows, kinds installed as .cmd shims (e.g. pi, cursor) cannot be
#    launched that way; they go straight to the pane-run path below.
WIN=0
case "$(uname -s 2>/dev/null)" in *MINGW*|*MSYS*|*CYGWIN*) WIN=1 ;; esac

SHIM_ONLY=0
if [ "$WIN" -eq 1 ] && command -v "$agent_exec.cmd" >/dev/null 2>&1; then
  SHIM_ONLY=1
  log "kind '$KIND' is a Windows .cmd shim ($agent_exec.cmd); using the pane-run path"
fi

if [ "$SHIM_ONLY" -eq 0 ]; then
  pane="$(split_pane)"
  # shellcheck disable=SC2086
  if herdr agent start "$NAME" --kind "$KIND" --pane "$pane" --timeout "$TIMEOUT_MS" \
       ${ARGS[@]+"${ARGS[@]}"}; then
    log "started '$NAME' via agent start"
    report "$NAME" "$pane" 0
    exit 0
  fi
  log "'agent start' failed; falling back to pane run on a fresh pane"
fi

# 3. Pane-run path: required on Windows for .cmd-shim kinds (pi, cursor),
#    and the universal fallback when 'agent start' fails anywhere else.
pane="$(split_pane)"
pane_exec="$agent_exec"
if [ "$WIN" -eq 1 ] && command -v "$agent_exec.cmd" >/dev/null 2>&1; then
  # Herdr's Windows integration recognizes the explicit .cmd shim (e.g.
  # pi.cmd, cursor-agent.cmd), not the shell-resolved bare spelling.
  pane_exec="$agent_exec.cmd"
fi
cmd="$pane_exec"
if [ ${#ARGS[@]} -gt 0 ]; then cmd="$cmd $(printf '%s ' "${ARGS[@]}")"; fi
log "running in pane $pane: $cmd"
herdr pane run "$pane" "$cmd" || die "pane run failed"

polls=$(( TIMEOUT_MS / 2000 )); [ "$polls" -ge 1 ] || polls=1
i=1
while [ "$i" -le "$polls" ]; do
  if herdr agent get "$pane" >/dev/null 2>&1; then break; fi
  sleep 2
  i=$((i + 1))
done
herdr agent get "$pane" >/dev/null 2>&1 \
  || die "agent not detected in pane $pane within ${TIMEOUT_MS}ms; inspect with: herdr pane read $pane --source recent-unwrapped"

target="$pane"
if herdr agent rename "$pane" "$NAME" >/dev/null 2>&1; then
  target="$NAME"
else
  log "rename to '$NAME' failed; use the pane id as the prompt target"
fi

log "reviewer ready"
report "$target" "$pane" 0
