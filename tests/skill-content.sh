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
  'Status UU Ketenagakerjaan baru' 'kontrak-draft' 'Status kawin' 'Tempat pekerjaan'
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
  'kontrak-gate' 'kontrak-finish' 'Sama dengan' 'Status kawin' 'belum kawin' 'TEMPAT_KERJA'
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

need kontrak-gate \
  'G1 Wadah' 'G2 Dasar hukum' 'G3 Jebakan terlarang' 'G4 Non-kompetisi' 'G5 Usia' \
  'G6 HKI' 'G7 Penegakan' 'G8 Angka & kesegaran' 'G9 Penandatangan' \
  'PASS' 'BLOCKING' 'kontrak_sha256' 'reviewed_at' '180' \
  'loop back to kontrak-draft until PASS' 'GATE-STATUS' 'review.md' 'kontrak.md' 'brief.md' \
  'references/pasal/' 'references/hukum/' 'kontrak-draft' 'kontrak-finish' 'shasum -a 256' \
  'telah dewasa' 'Art. 1309' 'Art. 1307' \
  'P-HKI-04' 'Status kawin' 'belum kawin' 'P-NK-01' 'P-NK-03' '1601x' 'tempat pekerjaan'
f="$ROOT/skills/kontrak-gate/SKILL.md"
if [ -f "$f" ]; then
  grep -qE 'TODO|TBD|FIXME' "$f" && { echo "FAIL kontrak-gate: placeholder text"; fail=1; }
  grep -qiE 'never edit|tidak (pernah )?(mengubah|mengedit)|jangan (mengubah|mengedit)' "$f" || { echo "FAIL kontrak-gate: no never-edit-kontrak.md rule"; fail=1; }
  [ "$(wc -l < "$f")" -le 290 ] || { echo "FAIL kontrak-gate: longer than 290 lines"; fail=1; }
fi

need gaspol-kontrakkerja \
  'brief.md' 'kontrak.md' 'review.md' 'kontrak-brainstorm' 'kontrak-draft' 'kontrak-gate' \
  'kontrak-finish' 'shasum -a 256' 'kontrak_sha256' 'BLOCKING' 'PASS' \
  'Tidak ada PDF atau DOCX tanpa PASS yang berlaku' 'Router tidak pernah menulis teks kontrak' \
  '../../' 'mtime' 'selesai'
f="$ROOT/skills/gaspol-kontrakkerja/SKILL.md"
if [ -f "$f" ]; then
  grep -qE 'TODO|TBD|FIXME' "$f" && { echo "FAIL gaspol-kontrakkerja: placeholder text"; fail=1; }
  grep -qiE 'buat kontrak|PKWT|freelancer' "$f" || { echo "FAIL gaspol-kontrakkerja: no Indonesian trigger words"; fail=1; }
  [ "$(grep -c '^| ' "$f")" -ge 8 ] || { echo "FAIL gaspol-kontrakkerja: routing table too short"; fail=1; }
fi

# README: honest-guarantee boundary; "dijamin" only inside a negation line
r="$ROOT/README.md"
if [ ! -f "$r" ]; then
  echo "FAIL README.md: No such file or directory"; fail=1
else
  for s in 'does not guarantee' 'advocate' 'KONTRAK_LOGO' 'company-legal.md' 'Merek' 'Tagline' \
           'pandoc' 'Chrome' 'NODE_PATH' 'Firecrawl' '180' 'verified:' '0.1.1' 'UU Ketenagakerjaan' \
           'Risiko' 'kontrak-brainstorm' 'kontrak-finish' 'An advocate should confirm this reading'; do
    grep -qF -- "$s" "$r" || { echo "FAIL README.md: missing string: $s"; fail=1; }
  done
  grep -iF 'dijamin' "$r" | grep -viE 'tidak ada jaminan|tidak (ada|pernah|boleh|menjanjikan)|does not|never|jangan' | grep -q . \
    && { echo "FAIL README.md: 'dijamin' outside a negation line"; fail=1; }
  grep -qE 'TODO|TBD|FIXME' "$r" && { echo "FAIL README.md: placeholder text"; fail=1; }
fi

[ "$fail" -eq 0 ] && echo "PASS skill-content"
exit "$fail"
