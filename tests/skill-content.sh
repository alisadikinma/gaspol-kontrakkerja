#!/usr/bin/env bash
# Asserts each skill's SKILL.md carries the strings its contract requires.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
need() { # <skill> <literal string>...
  local skill="$1"; shift
  local f="$ROOT/skills/$skill/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "FAIL skills/$skill/SKILL.md: No such file or directory"
    fail=1
    return
  fi
  local s
  for s in "$@"; do
    grep -qF -- "$s" "$f" || { echo "FAIL $skill: missing string: $s"; fail=1; }
  done
}

need kontrak-brainstorm \
  'AskUserQuestion' 'wadah' 'brief.md' '[ASUMSI]' \
  'references/hukum/ketenagakerjaan.md' 'playbook-kontrak-kerja-id' 'STOP' \
  'company-legal' 'Hal yang belum diketahui' 'templates/brief-template.md' \
  'Status UU Ketenagakerjaan baru' 'kontrak-draft'
# STOP rule must name wage, date and party identity.
f="$ROOT/skills/kontrak-brainstorm/SKILL.md"
if [ -f "$f" ]; then
  grep -E 'STOP' "$f" | grep -qi 'upah' || { echo "FAIL kontrak-brainstorm: STOP rule does not mention upah"; fail=1; }
  grep -E 'STOP' "$f" | grep -qi 'tanggal' || { echo "FAIL kontrak-brainstorm: STOP rule does not mention tanggal"; fail=1; }
  grep -E 'STOP' "$f" | grep -qi 'identitas' || { echo "FAIL kontrak-brainstorm: STOP rule does not mention identitas"; fail=1; }
  grep -q '1307' "$f" && { echo "FAIL kontrak-brainstorm: repeats wrong article 1307"; fail=1; }
fi

[ "$fail" -eq 0 ] && echo "PASS skill-content"
exit "$fail"
