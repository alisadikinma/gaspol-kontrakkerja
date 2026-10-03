#!/usr/bin/env bash
# Smoke test for scripts/md2docx.js (DOCX path of kontrak-finish): success path and letterhead exit-2 cases.
# Fictional stub vault note and stub logo only. The npm package "docx" is not part of the repo:
# it is looked up in $NODE_PATH, <repo>/.cache/node_modules (npm install docx --prefix .cache),
# Not found => the success-path asserts are SKIPPED, loudly,
# and a SKIP never counts as a pass (run-all.sh prints SKIP, not OK). The exit-2 cases need no package.
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

command -v node >/dev/null 2>&1 || { echo "SKIP docx-smoke (node not installed): NOT a pass"; exit 0; }
[ -f "$ROOT/scripts/md2docx.js" ] || { echo "FAIL scripts/md2docx.js: No such file or directory"; exit 1; }

echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' | base64 -d > "$TMP/logo.png"
cp "$GOOD" "$TMP/kontrak.md"
grep -q "GATE-STATUS" "$TMP/kontrak.md" || printf '\n<!-- GATE-STATUS -->Draf ini DISUSUN per 2026-10-03; status pemeriksaan aturan: menunggu kontrak-gate. Tinjauan advokat disarankan sebelum tanda tangan.\n' >> "$TMP/kontrak.md"
SHA="$(shasum -a 256 "$TMP/kontrak.md" | awk '{print $1}')"
printf '## Verdict: PASS\n\nreviewed_at: 2026-10-03\nkontrak_sha256: %s\n' "$SHA" > "$TMP/review.md"
bash "$ROOT/scripts/clean.sh" "$TMP/kontrak.md" "$TMP/clean.md" "$TMP/review.md" || { echo "FAIL clean.sh on good fixture"; exit 1; }

# --- letterhead exit-2 cases (validated before the docx package is loaded)
run2() { # <label> <vault-file>
  node "$ROOT/scripts/md2docx.js" "$TMP/clean.md" "$2" "$TMP/o.docx" "$TMP/logo.png" >"$TMP/e.log" 2>&1
  local rc=$?
  check "$1: exit 2" test "$rc" -eq 2
  check "$1: no docx written" test ! -e "$TMP/o.docx"
}
# no ## Alamat heading at all: the front-matter '---' must NOT be taken as the address
awk '/^## Alamat/{skip=1; next} skip && /^## /{skip=0} !skip{print}' "$STUB" > "$TMP/stub-noalamat.md"
run2 "missing ## Alamat heading" "$TMP/stub-noalamat.md"
check "missing ## Alamat: message names the heading" grep -qF '## Alamat' "$TMP/e.log"
# heading present but empty (next heading follows)
awk '/^## Alamat/{print; print ""; skip=1; next} skip && /^## /{skip=0} !skip{print}' "$STUB" > "$TMP/stub-emptyalamat.md"
run2 "empty ## Alamat section" "$TMP/stub-emptyalamat.md"
for key in Nama NIB NPWP 'SK Pengesahan' Telp Email; do
  grep -v "^- \*\*$key" "$STUB" > "$TMP/stub-no.md"
  run2 "missing $key" "$TMP/stub-no.md"
  check "missing $key: message names it" grep -qF -- "- **$key**" "$TMP/e.log"
done

# --- success path
NM=""
for c in "${NODE_PATH:-}" "$ROOT/.cache/node_modules"; do
  [ -n "$c" ] && [ -d "$c/docx" ] && { NM="$c"; break; }
done
if [ -z "$NM" ]; then
  echo "SKIP (docx package not installed): DOCX success path NOT tested, this is NOT a pass."
  echo "     Install: npm install docx --prefix \"$ROOT/.cache\"   (folder is gitignored)"
  [ "$fail" -eq 0 ] && echo "SKIP docx-smoke (exit-2 cases only)"
  exit "$fail"
fi
NODE_PATH="$NM" node "$ROOT/scripts/md2docx.js" "$TMP/clean.md" "$STUB" "$TMP/out.docx" "$TMP/logo.png" >"$TMP/ok.log" 2>&1
check "md2docx success: exit 0" test $? -eq 0
check "docx exists and > 5 KB" test "$(wc -c < "$TMP/out.docx" 2>/dev/null || echo 0)" -gt 5120
unzip -p "$TMP/out.docx" word/document.xml > "$TMP/doc.xml" 2>/dev/null
check "document.xml readable" test -s "$TMP/doc.xml"
check "document.xml: no {{" bash -c '! grep -q "{{" "$1"' _ "$TMP/doc.xml"
check "document.xml: no Catatan penyusun (any case)" bash -c '! grep -qi "catatan penyusun" "$1"' _ "$TMP/doc.xml"
check "document.xml: >= 2 tables" test "$(grep -o '<w:tbl>' "$TMP/doc.xml" | wc -l | tr -d ' ')" -ge 2
check "document.xml: PASS sentence" bash -c 'grep -qF "lolos pemeriksaan aturan per 2026-10-03" "$1"' _ "$TMP/doc.xml"
HDR="$(unzip -l "$TMP/out.docx" | awk '{print $4}' | grep -E '^word/header[0-9]*\.xml$' | head -1)"
check "header part exists" test -n "$HDR"
unzip -p "$TMP/out.docx" "$HDR" > "$TMP/hdr.xml" 2>/dev/null
check "header: stub company/brand name" bash -c 'grep -q "CONTOH" "$1"' _ "$TMP/hdr.xml"
check "header: stub address" bash -c 'grep -q "Jalan Percobaan" "$1"' _ "$TMP/hdr.xml"
check "header: NIB" bash -c 'grep -q "0000012345" "$1"' _ "$TMP/hdr.xml"

[ "$fail" -eq 0 ] && echo "PASS docx-smoke"
exit "$fail"
