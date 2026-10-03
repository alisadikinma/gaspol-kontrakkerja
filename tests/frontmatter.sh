#!/usr/bin/env bash
# Asserts plugin.json is present and well-formed.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PJ="$ROOT/.claude-plugin/plugin.json"
fail=0
if [ ! -f "$PJ" ]; then
  echo "FAIL plugin.json: No such file or directory ($PJ)"
  exit 1
fi
grep -q '"name"[[:space:]]*:[[:space:]]*"gaspol-kontrakkerja"' "$PJ" || { echo "FAIL plugin.json: name != gaspol-kontrakkerja"; fail=1; }
grep -q '"version"[[:space:]]*:[[:space:]]*"[^"]\+"' "$PJ" || { echo "FAIL plugin.json: version missing"; fail=1; }
grep -q '"description"[[:space:]]*:[[:space:]]*"[^"]\+"' "$PJ" || { echo "FAIL plugin.json: description missing"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS frontmatter"
exit "$fail"
