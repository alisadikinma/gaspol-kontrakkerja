#!/usr/bin/env bash
# Runs the explicit list of test scripts. A missing script is RED, never skipped.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS="frontmatter.sh guard-generic.sh research-shape.sh crosscheck-shape.sh hukum-shape.sh freshness.sh pasal-shape.sh fixture-shape.sh skill-content.sh refs-resolve.sh build-smoke.sh docx-smoke.sh legal-content.sh"
red=0
skipped=0
for t in $TESTS; do
  if [ ! -f "$DIR/$t" ]; then
    echo "MISSING $t"
    red=1
    continue
  fi
  out="$(bash "$DIR/$t" 2>&1)"; rc=$?
  printf '%s\n' "$out"
  if [ "$rc" -eq 0 ]; then
    # a script that prints a SKIP line did not fully run: loud, and never counted as OK
    if printf '%s\n' "$out" | grep -q '^SKIP'; then echo "SKIPPED $t (NOT a pass)"; skipped=1; else echo "OK $t"; fi
  else
    echo "RED $t"
    red=1
  fi
done
if [ "$red" -eq 0 ]; then if [ "$skipped" -eq 1 ]; then echo "ALL GREEN but SOME TESTS SKIPPED (see SKIPPED lines)"; else echo "ALL GREEN"; fi; exit 0; else echo "SOME RED"; exit 1; fi
