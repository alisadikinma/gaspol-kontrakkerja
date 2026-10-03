#!/usr/bin/env bash
# Asserts 7 research/ask-*.md exist and research/crosscheck.md has MATCH/DIVERGED rows, none UNCHECKED.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for d in ketenagakerjaan perdata hki-rahasia-dagang pidana data-pribadi pajak-jaminan-sosial signing-authority; do
  [ -s "$ROOT/research/ask-$d.md" ] || { echo "research/ask-$d.md: No such file or directory"; exit 1; }
done
C="$ROOT/research/crosscheck.md"
[ -f "$C" ] || { echo "research/crosscheck.md: No such file or directory"; exit 1; }
grep -q 'UNCHECKED' "$C" && { echo "crosscheck.md: UNCHECKED row present"; exit 1; }
rows=$(grep -v '^| Article ' "$C" | grep -Ec '^\|.*\|[[:space:]]*(MATCH|DIVERGED)[^|]*\|[[:space:]]*$')
[ "$rows" -ge 24 ] || { echo "crosscheck.md: only $rows MATCH/DIVERGED rows (need >=24)"; exit 1; }
# every row must carry an http URL
bad=$(grep -v '^| Article ' "$C" | grep -E '\|[[:space:]]*(MATCH|DIVERGED)[^|]*\|[[:space:]]*$' | grep -vc 'https\?://')
[ "$bad" -eq 0 ] || { echo "crosscheck.md: $bad rows without source URL"; exit 1; }
for a in "UU 13/2003 Art. 58" "Art. 62" "Art. 185" "PP 35/2021 Art. 8" "Art. 14" "Art. 15" "Art. 16" "Art. 17" "UU 28/2014 Art. 5" "Art. 16(2)" "Art. 36" "UU 30/2000 Art. 3" "Art. 11" "Art. 13" "KUHPer Art. 330" "Art. 1304" "Art. 1307" "Art. 1425" "Art. 1446" "MA 3549" "KUHP baru" "UU 27/2022"; do
  grep -q "$a" "$C" || { echo "crosscheck.md: missing key article '$a'"; exit 1; }
done
if grep -q '| DIVERGED |$' "$C"; then grep -q '^## Resolusi DIVERGED' "$C" || { echo "crosscheck.md: DIVERGED rows without resolution section"; exit 1; }; fi
exit 0
