#!/usr/bin/env bash
# Print an absolute findings-file path for the herdr-review-loop skill.
#
# Usage:
#   findings-path.sh --slug SLUG --round N [--repo DIR]
#
# Rule: <repo>/.tmp/reviews/ when the repo is a git worktree and .tmp/ is
# gitignored; otherwise $TMPDIR (or /tmp) /herdr-review-<slug>/. Prints the
# absolute path as the only stdout line and creates the directory.

set -euo pipefail

die() { printf 'findings-path: %s\n' "$*" >&2; exit 1; }

SLUG="" ROUND="" REPO="$PWD"

while [ $# -gt 0 ]; do
  case "$1" in
    --slug)  SLUG="${2:-}";  shift 2 ;;
    --round) ROUND="${2:-}"; shift 2 ;;
    --repo)  REPO="${2:-}";  shift 2 ;;
    -h|--help)
      printf 'usage: findings-path.sh --slug SLUG --round N [--repo DIR]\n' >&2
      exit 1
      ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$SLUG" ] || die "--slug is required"
case "$ROUND" in ''|*[!0-9]*) die "--round must be an integer" ;; esac
[ "$ROUND" -ge 1 ] || die "--round must be >= 1"
[ -d "$REPO" ] || die "--repo directory not found: $REPO"

dir=""
if root="$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null)"; then
  if mkdir -p "$root/.tmp/reviews" 2>/dev/null \
     && git -C "$REPO" check-ignore -q .tmp/reviews/probe 2>/dev/null; then
    dir="$root/.tmp/reviews"
  fi
fi

if [ -z "$dir" ]; then
  dir="${TMPDIR:-/tmp}/herdr-review-$SLUG"
fi

mkdir -p "$dir"
abs="$(cd "$dir" && pwd -P)"
printf '%s/%s-r%s.md\n' "$abs" "$SLUG" "$ROUND"
