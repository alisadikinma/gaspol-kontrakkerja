#!/usr/bin/env bash
# Runs the explicit list of test scripts. A missing script is RED, never skipped.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS="frontmatter.sh guard-generic.sh research-shape.sh crosscheck-shape.sh hukum-shape.sh freshness.sh pasal-shape.sh fixture-shape.sh skill-content.sh refs-resolve.sh"
red=0
for t in $TESTS; do
  if [ ! -f "$DIR/$t" ]; then
    echo "MISSING $t"
    red=1
    continue
  fi
  if bash "$DIR/$t"; then
    echo "OK $t"
  else
    echo "RED $t"
    red=1
  fi
done
if [ "$red" -eq 0 ]; then echo "ALL GREEN"; exit 0; else echo "SOME RED"; exit 1; fi
