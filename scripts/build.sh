#!/usr/bin/env bash
# build.sh <kontrak.md> <out.pdf> [company-legal.md]
# Renders kontrak markdown to an A4 PDF on the company letterhead (pandoc -> Chrome headless).
# Env: KONTRAK_LOGO   logo PNG (default: INDUSIA brand logo)
#      KONTRAK_REVIEW review.md; with a current PASS the PASS sentence is substituted (see clean.sh)
#      CHROME         Chrome binary (default: macOS Google Chrome)
# Letterhead values come from the vault note, never from this script. Exit 2 when the logo, the
# vault note, Chrome/pandoc, or any required letterhead value is missing: a letterhead is never
# rendered with blank values.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$(dirname "$HERE")"
shopt -u patsub_replacement 2>/dev/null || true

[ $# -ge 2 ] && [ $# -le 3 ] || { echo "usage: build.sh <kontrak.md> <out.pdf> [company-legal.md]" >&2; exit 2; }
SRC="$1"; OUT="$2"
VAULT="${3:-/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md}"
LOGO="${KONTRAK_LOGO:-/Users/alisadikin/Drive-D/my-data/INDUSIA/PT/brand-industria-logo.png}"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
CSS="$PLUGIN/templates/style.css"
KOP="$PLUGIN/templates/kop.html"

[ -f "$SRC" ]   || { echo "build.sh: kontrak tidak ditemukan: $SRC" >&2; exit 2; }
[ -f "$LOGO" ]  || { echo "build.sh: logo tidak ditemukan: $LOGO (set KONTRAK_LOGO)" >&2; exit 2; }
[ -f "$VAULT" ] || { echo "build.sh: catatan company-legal tidak ditemukan: $VAULT" >&2; exit 2; }
[ -f "$CSS" ] && [ -f "$KOP" ] || { echo "build.sh: templates/style.css atau templates/kop.html hilang" >&2; exit 2; }
[ -x "$CHROME" ] || { echo "build.sh: Chrome tidak ditemukan: $CHROME (set CHROME)" >&2; exit 2; }
command -v pandoc >/dev/null 2>&1 || { echo "build.sh: pandoc tidak ditemukan" >&2; exit 2; }

# value of a "- **<Key>**: value" bullet; trailing "(...)" remark removed when $2 = first
bullet() {
  awk -v key="$1" -v first="${2:-}" '
    { pre = "- **" key; if (index($0, pre) == 1) {
        rest = substr($0, length(pre) + 1)
        sub(/^[^*]*\*\*:[[:space:]]*/, "", rest)
        if (first == "first") sub(/[[:space:]]*\(.*$/, "", rest)
        print rest; exit } }' "$VAULT"
}
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

NAMA="$(bullet Nama)"
ALAMAT="$(awk '/^## Alamat/{f=1; next} f && NF {print; exit}' "$VAULT")"
NIB="$(bullet NIB first)"
NPWP="$(bullet NPWP first)"
SK="$(bullet "SK Pengesahan" first)"
TELP="$(bullet Telp first)"
EMAIL="$(bullet Email first)"
MEREK="$(bullet Merek)"
TAGLINE="$(bullet Tagline)"

missing=""
for k in NAMA ALAMAT NIB NPWP SK TELP EMAIL; do
  [ -n "${!k}" ] || missing="$missing $k"
done
if [ -n "$missing" ]; then
  echo "build.sh: nilai kop surat tidak terisi dari $VAULT:$missing" >&2
  echo "          (nama, alamat di bawah '## Alamat', NIB, NPWP, SK Pengesahan, Telp, Email wajib ada)" >&2
  exit 2
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

kop="$(cat "$KOP")"
# merek optional: without it the wordmark is the legal name and the separate legal line is dropped
if [ -z "$MEREK" ]; then
  MEREK="$NAMA"
  kop="$(printf '%s\n' "$kop" | grep -v '<div class="legal">')"
fi
# tagline optional: without it the whole tagline cell is dropped, never left blank
if [ -z "$TAGLINE" ]; then
  kop="$(printf '%s\n' "$kop" | sed 's#<span class="sep">|</span><span>{{PT_TAGLINE}}</span>##')"
fi
B64="$(base64 < "$LOGO" | tr -d '\n')"
kop="${kop//'{{LOGO_B64}}'/$B64}"
kop="${kop//'{{PT_MEREK}}'/$(esc "$MEREK")}"
kop="${kop//'{{PT_NAMA}}'/$(esc "$NAMA")}"
kop="${kop//'{{PT_ALAMAT}}'/$(esc "$ALAMAT")}"
kop="${kop//'{{PT_NIB}}'/$(esc "$NIB")}"
kop="${kop//'{{PT_NPWP}}'/$(esc "$NPWP")}"
kop="${kop//'{{PT_SK_MENKUMHAM}}'/$(esc "$SK")}"
kop="${kop//'{{PT_TELP}}'/$(esc "$TELP")}"
kop="${kop//'{{PT_EMAIL}}'/$(esc "$EMAIL")}"
kop="${kop//'{{PT_TAGLINE}}'/$(esc "$TAGLINE")}"
if printf '%s' "$kop" | grep -q '{{'; then
  echo "build.sh: kop surat masih punya placeholder {{...}} yang tidak terisi" >&2
  exit 2
fi

bash "$HERE/clean.sh" "$SRC" "$TMP/clean.md" ${KONTRAK_REVIEW:+"$KONTRAK_REVIEW"}

{
  printf '<!DOCTYPE html><html lang="id"><head><meta charset="utf-8">\n<style>\n'
  cat "$CSS"
  printf '</style></head><body>\n'
  printf '%s\n' "$kop"
  pandoc -f markdown+pipe_tables+raw_html+fenced_divs -t html5 "$TMP/clean.md"
  printf '</body></html>\n'
} > "$TMP/kontrak.html"

# Chrome can finish writing the PDF and still not exit: poll for a stable file, then stop it.
rm -f "$OUT"
"$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
  --user-data-dir="$TMP/chrome" \
  --print-to-pdf="$OUT" --virtual-time-budget=6000 \
  "file://$TMP/kontrak.html" >"$TMP/chrome.log" 2>&1 &
CPID=$!
last=-1
for _ in $(seq 1 120); do
  sleep 0.5
  size=$(wc -c < "$OUT" 2>/dev/null || echo 0)
  if [ "$size" -gt 0 ] && [ "$size" -eq "$last" ]; then break; fi
  last=$size
  kill -0 "$CPID" 2>/dev/null || break
done
kill "$CPID" 2>/dev/null || true
pkill -f -- "--user-data-dir=$TMP/chrome" 2>/dev/null || true
wait "$CPID" 2>/dev/null || true
if [ ! -s "$OUT" ]; then
  echo "build.sh: Chrome tidak menghasilkan PDF" >&2
  tail -5 "$TMP/chrome.log" >&2
  exit 1
fi
echo "PDF: $OUT"
