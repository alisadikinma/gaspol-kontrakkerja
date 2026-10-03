#!/usr/bin/env bash
# Every plugin-file reference in a SKILL.md must be ../../references/... or ../../templates/...
# and must resolve from the skill's own folder. A bare references/ or templates/ path is a failure.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
count=0
for f in "$ROOT"/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  dir="$(dirname "$f")"
  # Bare references: "references/..." or "templates/..." not preceded by "../../"
  bare="$(grep -noE '(^|[^./A-Za-z])(references|templates)/[A-Za-z0-9_./-]+' "$f" || true)"
  if [ -n "$bare" ]; then
    echo "FAIL ${f#$ROOT/}: bare path (must start with ../../): $bare"
    fail=1
  fi
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    count=$((count+1))
    p="${p%[.,;:)]}"
    case "$p" in
      *'*'*) ls $dir/$p >/dev/null 2>&1 || { echo "FAIL ${f#$ROOT/}: glob matches nothing: $p"; fail=1; } ;;
      *) [ -e "$dir/$p" ] || { echo "FAIL ${f#$ROOT/}: broken reference: $p"; fail=1; } ;;
    esac
  done < <(grep -oE '\.\./\.\./(references|templates)/[A-Za-z0-9_./*-]*' "$f" | sort -u)
done
[ "$fail" -eq 0 ] && echo "PASS refs-resolve ($count refs)"
exit "$fail"
