#!/usr/bin/env bash
# clean.sh <kontrak.md> <out.md> [review.md]
# Cleaned markdown shared by the PDF and DOCX paths of kontrak-finish.
#  - drops "# CATATAN PENYUSUN" to end of file and every "> **Catatan penyusun" line
#  - drops the GATE-STATUS marker line; only with a CURRENT PASS (review.md verdict PASS and
#    kontrak_sha256 equal to the sha of kontrak.md) appends the PASS sentence instead
#  - wraps the closing + signature block in "::: ttd" (up to Lampiran I), and in each Lampiran
#    wraps every signature table together with its guardian block in its own "::: ttd" group
#  - kontrak.md itself is never modified (its sha256 stays valid)
# Exit: 0 ok, 2 bad usage or missing file, 3 review.md is not a current PASS, 4 leftover {{ or drafter note.
set -euo pipefail

[ $# -ge 2 ] && [ $# -le 3 ] || { echo "usage: clean.sh <kontrak.md> <out.md> [review.md]" >&2; exit 2; }
SRC="$1"; OUT="$2"; REV="${3:-}"
[ -f "$SRC" ] || { echo "clean.sh: kontrak tidak ditemukan: $SRC" >&2; exit 2; }

PASS_LINE=""
if [ -n "$REV" ]; then
  [ -f "$REV" ] || { echo "clean.sh: review.md tidak ditemukan: $REV" >&2; exit 2; }
  verdict="$(sed -n '1,/^## Verdict:/{/^## Verdict:/p;}' "$REV" | head -1)"
  rsha="$(sed -n 's/^kontrak_sha256: *//p' "$REV" | head -1 | tr -d '[:space:]')"
  rat="$(sed -n 's/^reviewed_at: *//p' "$REV" | head -1 | tr -d '[:space:]')"
  csha="$(shasum -a 256 "$SRC" | awk '{print $1}')"
  if [ "$verdict" != "## Verdict: PASS" ] || [ "$rsha" != "$csha" ] \
     || ! printf '%s' "$rat" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    echo "clean.sh: review.md bukan PASS yang berlaku untuk kontrak.md ini (verdict, sha, atau tanggal tidak cocok)" >&2
    exit 3
  fi
  if grep -q 'GATE-STATUS' "$SRC"; then
    PASS_LINE="Draf ini lolos pemeriksaan aturan per ${rat}. Tinjauan advokat disarankan sebelum tanda tangan."
  fi
fi

{
  awk '/^# CATATAN PENYUSUN/{exit} {print}' "$SRC" \
    | { grep -v -e '^> \*\*Catatan penyusun' -e 'GATE-STATUS' || true; } \
    | awk '
        { line[NR] = $0 }
        END {
          n = NR
          while (n > 0 && (line[n] ~ /^[[:space:]]*$/ || line[n] ~ /^[[:space:]]*-{3,}[[:space:]]*$/)) n--
          for (i = 1; i <= n; i++) print line[i]
        }' \
    | awk '
        # t: 0 none, 1 main closing+signature group open, 2 in Lampiran (no group open), 3 Lampiran group open
        /^\*\*DEMIKIANLAH PERJANJIAN INI\*\*/ && !t && !seen { print "::: ttd"; t = 1 }
        /^::: ttd/ { seen = 1 }
        /^# / && (t == 1 || t == 3) { print ":::"; print ""; t = 2 }
        /^# LAMPIRAN/ && !t { t = 2 }
        # a signature table (header row of bold-only cells) opens one unbreakable group that
        # also carries the guardian block and anything else up to the next heading
        t == 2 && /^\|( *\*\*[^|*]+\*\* *\|)+ *$/ { print "::: ttd"; t = 3 }
        { print }
        END { if (t == 1 || t == 3) { print ""; print ":::" } }'
  if [ -n "$PASS_LINE" ]; then
    printf '\n%s\n' "$PASS_LINE"
  fi
} > "$OUT"

if grep -q '{{' "$OUT" || grep -qi 'catatan penyusun' "$OUT"; then
  echo "clean.sh: hasil masih memuat {{ atau catatan penyusun; berhenti" >&2
  rm -f "$OUT"
  exit 4
fi
