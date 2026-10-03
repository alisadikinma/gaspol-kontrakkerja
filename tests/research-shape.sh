#!/usr/bin/env bash
# Asserts research/sources.md records the notebook id and >=20 source URL lines.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
F="$ROOT/research/sources.md"
[ -f "$F" ] || { echo "research/sources.md: No such file or directory"; exit 1; }
grep -Eq '^notebook-id: [0-9a-f-]{8,}' "$F" || { echo "research/sources.md: missing notebook-id line"; exit 1; }
n=$(grep -Ec '^- https?://' "$F")
[ "$n" -ge 20 ] || { echo "research/sources.md: only $n source lines (need >=20)"; exit 1; }
exit 0
