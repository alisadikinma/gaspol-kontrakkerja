#!/usr/bin/env bash
# RED if any references/hukum/*.md has a 'verified:' date older than 180 days (macOS date -j -f).
# TODAY=YYYY-MM-DD may override the current date (for testing).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAX=180
today="${TODAY:-$(date +%Y-%m-%d)}"
to_epoch() { date -j -f "%Y-%m-%d %H:%M:%S" "$1 00:00:00" +%s 2>/dev/null; }
now=$(to_epoch "$today") || { echo "freshness: cannot parse today '$today'"; exit 1; }
n=0; fail=0
for f in "$ROOT"/references/hukum/*.md; do
  [ -f "$f" ] || continue
  n=$((n+1))
  rel="references/hukum/$(basename "$f")"
  v=$(awk '/^verified: /{print $2; exit}' "$f")
  [ -n "$v" ] || { echo "$rel: no verified: date"; fail=1; continue; }
  e=$(to_epoch "$v") || { echo "$rel: unparseable verified '$v'"; fail=1; continue; }
  age=$(( (now - e) / 86400 ))
  if [ "$age" -gt "$MAX" ]; then echo "$rel: verified $v is $age days old (> $MAX)"; fail=1; fi
done
[ "$n" -ge 1 ] || { echo "references/hukum: no *.md files"; exit 1; }
exit $fail
