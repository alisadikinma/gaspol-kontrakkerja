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

need kontrak-draft \
  'brief.md' 'references/pasal/' 'Catatan penyusun — dasar:' 'lampiran-ip.md' 'STOP' \
  '[ASUMSI]' 'dijamin' '# CATATAN PENYUSUN' 'Tinjauan advokat disarankan sebelum tanda tangan' \
  'GATE-STATUS' 'DISUSUN per' 'signing-authority.md' 'company-legal' 'verified:' \
  'kontrak-gate' 'kontrak-finish' 'Sama dengan'
f="$ROOT/skills/kontrak-draft/SKILL.md"
if [ -f "$f" ]; then
  # refusal rules: missing brief.md, and [ASUMSI] on a legal-critical fact
  grep -E 'STOP|[Tt]olak' "$f" | grep -qF 'brief.md' || { echo "FAIL kontrak-draft: no refusal rule for missing brief.md"; fail=1; }
  grep -E 'STOP' "$f" | grep -qF '[ASUMSI]' || { echo "FAIL kontrak-draft: STOP rule does not mention [ASUMSI]"; fail=1; }
  # the word dijamin is only ever named as forbidden
  grep -F 'dijamin' "$f" | grep -qiE 'jangan|tidak boleh|nol|dilarang' || { echo "FAIL kontrak-draft: 'dijamin' is not stated as forbidden"; fail=1; }
  grep -F 'dijamin' "$f" | grep -viE 'jangan|tidak boleh|nol|dilarang|grep' | grep -q . && { echo "FAIL kontrak-draft: 'dijamin' used outside a prohibition line"; fail=1; }
  grep -q '[0-9]\+[a-z]\.' "$f" && grep -qE '^[0-9]+[a-z]\. ' "$f" && { echo "FAIL kontrak-draft: lettered numbering used"; fail=1; }
  grep -q '1307' "$f" && { echo "FAIL kontrak-draft: repeats article 1307"; fail=1; }
  grep -qE 'TODO|TBD|FIXME' "$f" && { echo "FAIL kontrak-draft: placeholder text"; fail=1; }
fi

[ "$fail" -eq 0 ] && echo "PASS skill-content"
exit "$fail"
