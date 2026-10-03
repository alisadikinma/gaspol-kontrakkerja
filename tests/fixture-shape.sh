#!/usr/bin/env bash
# Asserts templates/ and references/examples/ keep their contracts:
# slot ids exist in the library, wadah clause sets are right, fixtures carry (bad) or lack (good) the planted defects.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$ROOT/templates"
EX="$ROOT/references/examples"
PASAL="$ROOT/references/pasal"
fail=0
bad() { echo "FAIL fixture-shape: $*"; fail=1; }
need() { [ -f "$1" ] || { bad "${1#$ROOT/}: No such file or directory"; return 1; }; }

lib_ids=$(grep -h '^## P-' "$PASAL"/*.md 2>/dev/null | awk '{print $2}' | sort -u)
in_lib() { printf '%s\n' "$lib_ids" | grep -qx "$1"; }

for f in brief-template.md kontrak-pkwt.md kontrak-pkwtt.md kontrak-freelancer.md lampiran-ip.md kop.html; do need "$T/$f"; done
need "$EX/bad-kontrak.md"; need "$EX/good-kontrak.md"
[ "$fail" -eq 1 ] && exit 1

# --- contract templates
for f in kontrak-pkwt.md kontrak-pkwtt.md kontrak-freelancer.md lampiran-ip.md; do
  p="$T/$f"
  ids=$(grep -o '{{CLAUSE:[^}]*}}' "$p" | sed 's/{{CLAUSE://; s/}}//')
  [ -n "$ids" ] || bad "$f: no {{CLAUSE:...}} slots"
  for id in $ids; do in_lib "$id" || bad "$f: slot $id not in references/pasal/"; done
  dup=$(printf '%s\n' $ids | sort | uniq -d); [ -z "$dup" ] || bad "$f: duplicate slot $dup"
  [ "$f" = lampiran-ip.md ] || grep -q '^# CATATAN PENYUSUN' "$p" || bad "$f: missing # CATATAN PENYUSUN slot"
  grep -qE '^[0-9]+[a-z]\.' "$p" && bad "$f: lettered numbering (2a.) is forbidden"
done
for f in kontrak-pkwt.md kontrak-pkwtt.md kontrak-freelancer.md; do
  p="$T/$f"
  grep -q '{{BLOK_WALI_JIKA_<21}}' "$p" || bad "$f: missing guardian block slot"
  for k in PT_NAMA PT_PENANDATANGAN_NAMA PT_PENANDATANGAN_JABATAN PT_DASAR_KEWENANGAN PIHAK_KEDUA_NAMA TANGGAL_MULAI; do
    grep -q "{{$k}}" "$p" || bad "$f: missing placeholder {{$k}}"
  done
  grep -q 'DEMIKIANLAH PERJANJIAN INI' "$p" || bad "$f: missing DEMIKIANLAH marker"
  grep -q '{{LAMPIRAN_I}}' "$p" || bad "$f: missing {{LAMPIRAN_I}} slot"
done
la="$T/lampiran-ip.md"
grep -q '^# LAMPIRAN I' "$la" || bad "lampiran-ip.md: missing '# LAMPIRAN I' heading"
grep -q '{{BLOK_WALI_JIKA_<21}}' "$la" || bad "lampiran-ip.md: missing guardian block slot"
for id in P-RHS-01 P-RHS-02 P-RHS-03 P-HKI-01 P-HKI-02 P-HKI-03 P-HKI-04 P-HKI-06 P-NK-01 P-CL-01; do
  grep -q "{{CLAUSE:$id}}" "$la" || bad "lampiran-ip.md: missing $id"
done
has() { grep -q "{{CLAUSE:$2}}" "$T/$1"; }
for id in P-PM-01 P-PM-02 P-PJ-02 P-PJ-03 P-PJ-04 P-FS-01 P-AA-03 P-GR-01; do has kontrak-pkwt.md $id || bad "kontrak-pkwt.md: missing $id"; done
for id in P-PM-03 P-PJ-02 P-PJ-03 P-PJ-04 P-FS-01 P-AA-03; do has kontrak-pkwtt.md $id || bad "kontrak-pkwtt.md: missing $id"; done
for id in P-PM-01 P-PM-02; do has kontrak-pkwtt.md $id && bad "kontrak-pkwtt.md: PKWT-only clause $id"; done
for id in P-PJ-01 P-FS-02 P-PM-04 P-PJ-03; do has kontrak-freelancer.md $id || bad "kontrak-freelancer.md: missing $id"; done
for id in P-PM-01 P-PM-02 P-PM-03 P-PJ-02 P-PJ-04 P-FS-01; do has kontrak-freelancer.md $id && bad "kontrak-freelancer.md: employment-only clause $id"; done
if grep -qiE 'jam kerja|absensi|absen |kehadiran|jam masuk|hari kerja|masa percobaan|cuti|lembur' "$T/kontrak-freelancer.md"; then
  bad "kontrak-freelancer.md: fixed-hours/attendance language"
fi
grep -qi 'masa percobaan' "$T/kontrak-pkwt.md" && bad "kontrak-pkwt.md: probation language in PKWT"

# --- brief template
for tag in '[user]' '[vault]' '[riset]' '[ASUMSI]' 'Hal yang belum diketahui'; do
  grep -qF -- "$tag" "$T/brief-template.md" || bad "brief-template.md: missing $tag"
done

# --- kop.html
for k in PT_NAMA PT_ALAMAT PT_NIB PT_NPWP PT_SK_MENKUMHAM PT_TELP PT_EMAIL PT_TAGLINE LOGO_B64; do
  grep -q "{{$k}}" "$T/kop.html" || bad "kop.html: missing {{$k}}"
done

# --- bad fixture
b="$EX/bad-kontrak.md"
for n in 1 2 3 4 5 6; do
  c=$(grep -c "<!-- DEFECT D$n -->" "$b"); [ "$c" -eq 1 ] || bad "bad-kontrak.md: DEFECT D$n count=$c (want 1)"
done
tot=$(grep -c 'DEFECT' "$b"); [ "$tot" -eq 6 ] || bad "bad-kontrak.md: DEFECT total=$tot (want 6)"
grep -q 'Budi Contoh' "$b" || bad "bad-kontrak.md: fictional party Budi Contoh missing"
grep -q '{{' "$b" && bad "bad-kontrak.md: contains {{"
# the bad fixture must carry the Art. 13 komparisi fields and place of work so that only D1-D6 are defects
for k in 'bergerak di bidang usaha' 'berjenis kelamin' 'bertempat kerja di'; do grep -qF "$k" "$b" || bad "bad-kontrak.md: missing '$k' (would be an unplanted 7th defect)"; done

# --- good fixture
g="$EX/good-kontrak.md"
grep -q 'DEFECT' "$g" && bad "good-kontrak.md: contains DEFECT"
grep -q '{{' "$g" && bad "good-kontrak.md: contains {{"
grep -qi 'dijamin' "$g" && bad "good-kontrak.md: contains 'dijamin'"
grep -q 'Budi Contoh' "$g" || bad "good-kontrak.md: Budi Contoh missing"
grep -q 'UMK yang berlaku, diverifikasi pada tanggal' "$g" || bad "good-kontrak.md: UMK verification phrase missing"
grep -q '^<!-- GATE-STATUS -->Draf ini DISUSUN per 2026-10-03; status pemeriksaan aturan: menunggu kontrak-gate. Tinjauan advokat disarankan sebelum tanda tangan.$' "$g" || bad "good-kontrak.md: GATE-STATUS draft line missing"
grep -qi 'lolos pemeriksaan' "$g" && bad "good-kontrak.md: contains 'lolos pemeriksaan' (only clean.sh writes it, after PASS)"
grep -q '^# CATATAN PENYUSUN' "$g" || bad "good-kontrak.md: # CATATAN PENYUSUN missing"
grep -q 'mengetahui dan menyetujui' "$g" || bad "good-kontrak.md: guardian block missing"
# every clause heading is followed by a dasar line before the next heading
awk '
  function chk() { if (inc && !got) { print "FAIL fixture-shape: good-kontrak.md: no dasar line under \"" h "\""; bad=1 } }
  /^## Pasal/ { chk(); inc=1; got=0; h=$0; next }
  /^# / { chk(); inc=0; next }
  /^> \*\*Catatan penyusun — dasar:\*\* P-[A-Z]+-[0-9]+/ { if (inc) got=1 }
  END { chk(); exit bad }
' "$g" || fail=1
for id in $(grep '^> \*\*Catatan penyusun — dasar:' "$g" | grep -o 'P-[A-Z]*-[0-9]*'); do
  in_lib "$id" || bad "good-kontrak.md: dasar cites unknown $id"
done
n_pasal=$(grep -c '^## Pasal' "$g"); n_dasar=$(grep -c '^> \*\*Catatan penyusun — dasar:' "$g")
[ "$n_pasal" -eq "$n_dasar" ] || bad "good-kontrak.md: $n_pasal clauses vs $n_dasar dasar lines"
# bad fixture clauses are tagged too, except the planted ones may lack nothing: same shape
nb=$(grep -c '^## Pasal' "$b"); nd=$(grep -c '^> \*\*Catatan penyusun — dasar:' "$b")
[ "$nb" -eq "$nd" ] || bad "bad-kontrak.md: $nb clauses vs $nd dasar lines (only planted defects may fire)"

[ "$fail" -eq 0 ] && echo "PASS fixture-shape"
exit "$fail"
