#!/usr/bin/env bash
# Smoke test for scripts/clean.sh and scripts/build.sh (PDF path of kontrak-finish).
# Uses a fictional stub vault note and a stub 1x1 PNG logo; never real company data.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STUB="$ROOT/tests/fixtures/company-legal-stub.md"
GOOD="$ROOT/references/examples/good-kontrak.md"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0
ok()  { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
check() { local d="$1"; shift; if "$@"; then ok "$d"; else bad "$d"; fi; }

for s in scripts/clean.sh scripts/build.sh; do
  [ -f "$ROOT/$s" ] || { echo "FAIL $s: No such file or directory"; exit 1; }
done

# stub logo (1x1 PNG) and a working copy of the good fixture with the draft-written marker
echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' | base64 -d > "$TMP/logo.png"
cp "$GOOD" "$TMP/kontrak.md"
grep -q "GATE-STATUS" "$TMP/kontrak.md" || printf '\n<!-- GATE-STATUS -->Draf ini DISUSUN per 2026-10-03; status pemeriksaan aturan: menunggu kontrak-gate. Tinjauan advokat disarankan sebelum tanda tangan.\n' >> "$TMP/kontrak.md"
SHA="$(shasum -a 256 "$TMP/kontrak.md" | awk '{print $1}')"
printf '## Verdict: PASS\n\nreviewed_at: 2026-10-03\nkontrak_sha256: %s\n' "$SHA" > "$TMP/review.md"
printf '## Verdict: PASS\n\nreviewed_at: 2026-10-03\nkontrak_sha256: %064d\n' 0 > "$TMP/review-stale.md"
printf '## Verdict: BLOCKING\n\nreviewed_at: 2026-10-03\nkontrak_sha256: %s\n' "$SHA" > "$TMP/review-block.md"
PASS_SENTENCE='Draf ini lolos pemeriksaan aturan per 2026-10-03. Tinjauan advokat disarankan sebelum tanda tangan.'

# --- clean.sh
bash "$ROOT/scripts/clean.sh" "$TMP/kontrak.md" "$TMP/clean.md" "$TMP/review.md"
check "clean.sh exit 0 with current PASS" test $? -eq 0
check "clean: no {{" bash -c '! grep -q "{{" "$1"' _ "$TMP/clean.md"
check "clean: no Catatan penyusun (any case)" bash -c '! grep -qi "catatan penyusun" "$1"' _ "$TMP/clean.md"
check "clean: no GATE-STATUS marker" bash -c '! grep -q "GATE-STATUS" "$1"' _ "$TMP/clean.md"
check "clean: PASS sentence present" grep -qF "$PASS_SENTENCE" "$TMP/clean.md"
check "clean: ttd wrapper present" grep -q '^::: ttd' "$TMP/clean.md"
# every signature block (table headed by **PIHAK KEDUA**) sits in a ::: ttd group; guardian block shares the group
check "clean: ttd openers == signature tables" test "$(grep -c '^::: ttd' "$TMP/clean.md")" -eq "$(grep -c '^| \*\*INDUSIA\*\* | \*\*PIHAK KEDUA\*\* |' "$TMP/clean.md")"
check "clean: 2 ttd groups (main + Lampiran I)" test "$(grep -c '^::: ttd' "$TMP/clean.md")" -eq 2
check "clean: every WALI block inside a ttd group" awk '/^::: ttd/{o=1} /^:::$/{o=0} /WALI PIHAK KEDUA/{n++; if(!o)b=1} END{exit (n>=1 && !b)?0:1}' "$TMP/clean.md"
check "clean: Lampiran I signature + WALI in the SAME group" awk '/^::: ttd/{g++} /PIHAK KEDUA\*\* \|$/ && /INDUSIA/{a=g} /WALI PIHAK KEDUA/{w=g} END{exit (a>0 && a==w)?0:1}' "$TMP/clean.md"
check "clean: Lampiran I kept" grep -q '^# LAMPIRAN I' "$TMP/clean.md"
check "clean: original kontrak.md unchanged" test "$(shasum -a 256 "$TMP/kontrak.md" | awk '{print $1}')" = "$SHA"

bash "$ROOT/scripts/clean.sh" "$TMP/kontrak.md" "$TMP/clean-nopass.md"
check "clean without review: exit 0" test $? -eq 0
check "clean without review: no PASS sentence" bash -c '! grep -q "lolos pemeriksaan" "$1"' _ "$TMP/clean-nopass.md"
check "clean without review: no DISUSUN sentence" bash -c '! grep -q "DISUSUN" "$1"' _ "$TMP/clean-nopass.md"
bash "$ROOT/scripts/clean.sh" "$TMP/kontrak.md" "$TMP/x.md" "$TMP/review-stale.md" 2>/dev/null
check "clean: stale sha refuses (exit 3)" test $? -eq 3
bash "$ROOT/scripts/clean.sh" "$TMP/kontrak.md" "$TMP/x.md" "$TMP/review-block.md" 2>/dev/null
check "clean: BLOCKING refuses (exit 3)" test $? -eq 3

# --- build.sh
export KONTRAK_LOGO="$TMP/logo.png"
KONTRAK_REVIEW="$TMP/review.md" bash "$ROOT/scripts/build.sh" "$TMP/kontrak.md" "$TMP/out.pdf" "$STUB" >"$TMP/build.log" 2>&1
check "build.sh exit 0" test $? -eq 0
check "pdf exists" test -f "$TMP/out.pdf"
check "pdf > 10 KB" test "$(wc -c < "$TMP/out.pdf" 2>/dev/null || echo 0)" -gt 10240
if command -v pdftotext >/dev/null 2>&1; then
  pdftotext -layout "$TMP/out.pdf" "$TMP/out.txt"
  check "pdf: no {{" bash -c '! grep -q "{{" "$1"' _ "$TMP/out.txt"
  check "pdf: no Catatan penyusun" bash -c '! grep -qi "catatan penyusun" "$1"' _ "$TMP/out.txt"
  check "pdf: letterhead company name" grep -qi 'PT Contoh Perangkat Lunak' "$TMP/out.txt"
  check "pdf: letterhead NIB" grep -q 'NIB 0000012345' "$TMP/out.txt"
  check "pdf: PASS sentence" bash -c 'tr "\n" " " < "$1" | tr -s " " | grep -qF "$2"' _ "$TMP/out.txt" "$PASS_SENTENCE"
else
  check "pdf: no {{ (strings fallback)" bash -c '! strings "$1" | grep -q "{{"' _ "$TMP/out.pdf"
fi

# merek/tagline absent in the vault note: fall back to the company name, still no blank values
grep -v -e '^- \*\*Merek\*\*' -e '^- \*\*Tagline\*\*' "$STUB" > "$TMP/stub-nomerek.md"
bash "$ROOT/scripts/build.sh" "$TMP/kontrak.md" "$TMP/out2.pdf" "$TMP/stub-nomerek.md" >"$TMP/build2.log" 2>&1
check "build without merek/tagline: exit 0" test $? -eq 0
if command -v pdftotext >/dev/null 2>&1; then
  pdftotext -layout "$TMP/out2.pdf" "$TMP/out2.txt"
  check "fallback: company name in letterhead" grep -qi 'PT Contoh Perangkat Lunak' "$TMP/out2.txt"
fi

# --- exit 2 cases
KONTRAK_LOGO="$TMP/tidak-ada.png" bash "$ROOT/scripts/build.sh" "$TMP/kontrak.md" "$TMP/o3.pdf" "$STUB" >"$TMP/e1.log" 2>&1
check "missing logo: exit 2" test $? -eq 2
check "missing logo: message names logo" grep -qi 'logo' "$TMP/e1.log"
if command -v node >/dev/null 2>&1; then
  node "$ROOT/scripts/md2docx.js" "$TMP/clean.md" "$STUB" "$TMP/o6.docx" "$TMP/tidak-ada.png" >"$TMP/e6.log" 2>&1
  check "md2docx missing logo: exit 2" test $? -eq 2
  check "md2docx missing logo: message names logo" grep -qi 'logo' "$TMP/e6.log"
fi
bash "$ROOT/scripts/build.sh" "$TMP/kontrak.md" "$TMP/o4.pdf" "$TMP/tidak-ada.md" >"$TMP/e2.log" 2>&1
check "missing vault note: exit 2" test $? -eq 2
check "missing vault note: message names the note" grep -qi 'company-legal\|catatan\|vault' "$TMP/e2.log"
grep -v '^- \*\*NIB\*\*' "$STUB" > "$TMP/stub-nonib.md"
bash "$ROOT/scripts/build.sh" "$TMP/kontrak.md" "$TMP/o5.pdf" "$TMP/stub-nonib.md" >"$TMP/e3.log" 2>&1
check "missing NIB value: exit 2" test $? -eq 2
check "missing NIB value: message names NIB" grep -q 'NIB' "$TMP/e3.log"
check "no pdf written on exit 2" test ! -e "$TMP/o5.pdf"

# --- skill kontrak-finish states the refusal rule and both formats
SK="$ROOT/skills/kontrak-finish/SKILL.md"
check "finish skill exists" test -f "$SK"
for pat in '## Verdict: PASS' 'kontrak_sha256' 'shasum -a 256 kontrak.md' 'anthropic-skills:docx' 'KONTRAK-<CODE>-<NNN>.pdf' 'KONTRAK-<CODE>-<NNN>.docx' 'scripts/clean.sh' 'scripts/build.sh' 'gaspol-learn' 'word/document.xml'; do
  check "finish skill mentions: $pat" grep -qF -- "$pat" "$SK"
done
check "finish skill refuses on BLOCKING and stale sha" bash -c 'grep -q "BLOCKING" "$1" && grep -q "sha beda" "$1" && grep -q "STOP" "$1"' _ "$SK"

[ "$fail" -eq 0 ] && echo "PASS build-smoke"
exit "$fail"
