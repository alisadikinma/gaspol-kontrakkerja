#!/usr/bin/env bash
# Asserts references/pasal/*.md clause entries are well-formed and grounded in references/hukum/.
# Checks only files that exist (the all-groups existence check belongs to Phase E2).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASAL="$ROOT/references/pasal"
HUKUM="$ROOT/references/hukum"
if [ ! -d "$PASAL" ] || ! ls "$PASAL"/*.md >/dev/null 2>&1; then
  echo "references/pasal: no such file or directory"
  exit 1
fi
# Normalised blob of every [dasar: ...] tag in the hukum files (lowercase, collapsed whitespace).
BLOB="$(cat "$HUKUM"/*.md | grep -o '\[dasar: [^]]*\]' | tr 'A-Z' 'a-z' | tr -s ' \t' ' ')"
export BLOB
awk '
function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
function norm(s) { s = tolower(s); gsub(/[ \t]+/, " ", s); return trim(s) }
function group_of(file,   g) {
  g = file; sub(/.*\//, "", g); sub(/\.md$/, "", g)
  if (g == "kerahasiaan") return "RHS"
  if (g == "hki") return "HKI"
  if (g == "non-kompetisi") return "NK"
  if (g == "clean-room") return "CR"
  if (g == "copyleft") return "CL"
  if (g == "data-klien") return "DK"
  if (g == "aset-akses") return "AA"
  if (g == "ganti-rugi") return "GR"
  if (g == "forum-sengketa") return "FS"
  if (g == "pemutusan") return "PM"
  if (g == "pajak") return "PJ"
  return ""
}
function fail(msg) { print msg; bad = 1 }
function finish_entry(   i, f, n, parts, k, seg, v, ok, rel) {
  if (id == "") return
  nent[fname]++
  if (id in seen) fail(rel_of(fname) ": duplicate id " id)
  seen[id] = 1
  if (id !~ /^P-[A-Z]+-[0-9][0-9]$/) fail(id ": id must match P-[A-Z]+-[0-9]{2}")
  if (group_of(fname) != "" && index(id, "P-" group_of(fname) "-") != 1) fail(id ": id prefix does not match group of " rel_of(fname))
  n = split("Dasar hukum|Tujuan|Berlaku untuk|Varian standar|Varian ketat|Pengecualian wajib|Risiko|Verified", F, "|")
  for (i = 1; i <= n; i++) {
    f = F[i]
    if (!(f in val) || trim(val[f]) == "") fail(id ": field \"" f "\" missing or empty")
  }
  if (("Verified" in val) && val["Verified"] !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) fail(id ": Verified must be YYYY-MM-DD")
  if ("Berlaku untuk" in val) {
    k = split(val["Berlaku untuk"], parts, ",")
    for (i = 1; i <= k; i++) { v = trim(parts[i]); if (v != "PKWT" && v != "PKWTT" && v != "FL") fail(id ": Berlaku untuk value \"" v "\" not in {PKWT, PKWTT, FL}") }
  }
  if ("Dasar hukum" in val) {
    k = split(val["Dasar hukum"], parts, ";")
    for (i = 1; i <= k; i++) {
      seg = norm(parts[i])
      if (seg == "") continue
      if (index(ENVIRON["BLOB"], seg) == 0) fail(id ": Dasar hukum not found in any hukum [dasar:] tag: \"" trim(parts[i]) "\"")
    }
  }
  all = val["Tujuan"] val["Varian standar"] val["Varian ketat"] val["Pengecualian wajib"] val["Risiko"]
  if (all ~ /\{\{/ || all ~ /TODO/ || tolower(all) ~ /dijamin/) fail(id ": contains placeholder, TODO, or the word dijamin")
  # group-specific content rules
  if (id ~ /^P-NK-/) {
    if (tolower(val["Varian standar"]) !~ /rahasia dagang/ || tolower(val["Varian ketat"]) !~ /rahasia dagang/) fail(id ": non-compete variants must state the trade-secret purpose")
  }
  if (id == "P-HKI-01") {
    nt = split("source code|object code|repositori|riwayat commit|basis data|skema|skrip|konfigurasi|prompt|model|bobot|dataset|algoritma|dokumentasi teknis|SOP|hasil pengujian|karya turunan|seluruh proyek|pelanggan|lini bisnis", T, "|")
    for (i = 1; i <= nt; i++) {
      if (index(tolower(val["Varian standar"]), tolower(T[i])) == 0) fail(id ": Varian standar lacks Hasil Karya item \"" T[i] "\"")
      if (index(tolower(val["Varian ketat"]), tolower(T[i])) == 0) fail(id ": Varian ketat lacks Hasil Karya item \"" T[i] "\"")
    }
  }
  if (id == "P-HKI-02" || id == "P-HKI-04" || id == "P-HKI-06") {
    if (val["Risiko"] !~ /18/ || val["Risiko"] !~ /25 tahun/) fail(id ": Risiko must state the Art. 18 UU 28/2014 25-year return risk")
  }
  if (id == "P-RHS-03") {
    if (tolower(val["Varian standar"]) !~ /tanpa batas waktu/ || val["Varian standar"] !~ /2 \(dua\) tahun/) fail(id ": must carry no-limit for source code/trade secret and 2 years for general information")
  }
  delete val
  id = ""
}
function rel_of(p,   r) { r = p; sub(/.*references\//, "references/", r); return r }
FNR == 1 { finish_entry(); fname = FILENAME; field = ""; nent[fname] += 0 }
/^## P-/ { finish_entry(); id = $2; fname = FILENAME; field = ""; nent[fname] += 0; next }
/^## / { finish_entry(); field = ""; next }
id != "" && /^\*\*[^*:]+:\*\*/ {
  line = $0
  lab = line; sub(/^\*\*/, "", lab); sub(/:\*\*.*/, "", lab)
  rest = line; sub(/^\*\*[^*:]+:\*\*/, "", rest)
  field = lab; val[field] = trim(rest); next
}
id != "" && field != "" { val[field] = trim(val[field] " " trim($0)); next }
END {
  finish_entry()
  for (f in nent) if (nent[f] < 1) fail(rel_of(f) ": no ## P- entries")
  nfiles = 0; for (f in nent) nfiles++
  if (nfiles == 0) fail("references/pasal: no entries found")
  exit bad
}
' "$PASAL"/*.md
