#!/usr/bin/env bash
# Content contracts from KKJ-1 review fix-round 1: under-21 + marital status, post-employment
# non-compete (Art. 1601x), Art. 1309, open BPJS list, place of work (PP 35/2021 Art. 13).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
R="$ROOT/references"; T="$ROOT/templates"; S="$ROOT/skills"
fail=0
bad() { echo "FAIL legal-content: $*"; fail=1; }
# every helper fails when the file is missing (a renamed file must not pass silently)
has()  { [ -f "$1" ] || { bad "${1#$ROOT/}: No such file"; return; }; grep -qF -- "$2" "$1" || bad "${1#$ROOT/}: missing: $2"; }
hasnt(){ [ -f "$1" ] || { bad "${1#$ROOT/}: No such file"; return; }; grep -qF -- "$2" "$1" && bad "${1#$ROOT/}: must not contain: $2"; }
hasre(){ [ -f "$1" ] || { bad "${1#$ROOT/}: No such file"; return; }; grep -qE -- "$2" "$1" || bad "${1#$ROOT/}: missing pattern: $2"; }

# --- C1: guardian does NOT cure a post-employment restriction (Art. 1601x(1): buruh dewasa)
for f in "$R/hukum/hki-rahasia-dagang.md" "$R/hukum/perdata.md"; do
  has "$f" 'bukan penyembuh yang didukung sumber'
  hasnt "$f" 'perlu tanda tangan wali'
done
has "$R/hukum/perdata.md" 'wali "mengetahui dan menyetujui" bukan penyembuh'
nk="$R/pasal/non-kompetisi.md"
hasnt "$nk" 'klausul tidak sah tanpa tanda tangan wali'
hasnt "$nk" 'memerlukan tanda tangan wali'
hasnt "$nk" 'diperlukan tanda tangan wali'
has "$nk" 'tidak dipasang untuk Pihak Kedua yang belum genap 21 tahun dan belum kawin'
has "$nk" 'advokat'
# P-NK-02 (during employment) stays; the post-employment ones carry the exclusion in their own entry
awk '/^## P-NK-01/{e="01"} /^## P-NK-02/{e="02"} /^## P-NK-03/{e="03"} /^## P-NK-04/{e="04"} /Pengecualian wajib/ && (e=="01"||e=="03"||e=="04") && /belum kawin/ {c++} END{exit (c==3)?0:1}' "$nk" || bad "non-kompetisi.md: P-NK-01, P-NK-03 and P-NK-04 Pengecualian wajib must all name 'belum kawin'"
awk '/^## P-NK-0[13]/{e=1; next} /^## /{e=0} e && /^\*\*Risiko/ && /advokat/ {c++} END{exit (c==2)?0:1}' "$nk" || bad "non-kompetisi.md: P-NK-01 and P-NK-03 Risiko must say an advocate should confirm the reading"
# the draft skill, the good fixture and README follow
d="$S/kontrak-draft/SKILL.md"
hasnt "$d" 'ditandatangani dengan persetujuan Wali'
has "$d" 'JANGAN pasang P-NK-01 dan P-NK-03'
has "$d" 'P-NK-02'
g="$R/examples/good-kontrak.md"
hasnt "$g" 'P-NK-01'
hasnt "$g" 'P-NK-03'
has "$g" 'P-NK-02'
hasnt "$g" 'sejak Perjanjian berakhir, Pihak Kedua tidak akan'
hasnt "$g" 'ditandatangani dengan persetujuan Wali'
has "$g" 'Larangan Bersaing Selama Perjanjian'
has "$ROOT/README.md" 'An advocate should confirm this reading'
has "$ROOT/README.md" '1601x'
# gate: BLOCKING rule in G4 (and G5)
gt="$S/kontrak-gate/SKILL.md"
for s in 'P-NK-01' 'P-NK-03' '1601x' 'belum kawin' 'walau ada blok wali'; do has "$gt" "$s"; done
# eval 03 exists and its recorded review is BLOCKING
[ -f "$ROOT/evals/03-underage-noncompete.md" ] || bad "evals/03-underage-noncompete.md: No such file"
rv="$ROOT/evals/results/03-underage-noncompete-review.md"
if [ -f "$rv" ]; then head -1 "$rv" | grep -qx '## Verdict: BLOCKING' || bad "evals/results/03: first line is not '## Verdict: BLOCKING'"; else bad "evals/results/03-underage-noncompete-review.md: No such file"; fi

# --- PA-I1: marital status, Art. 330 = belum genap 21 DAN belum kawin
for f in "$T/brief-template.md" "$S/kontrak-brainstorm/SKILL.md" "$S/kontrak-draft/SKILL.md" "$gt"; do
  has "$f" 'Status kawin'
  has "$f" 'belum kawin'
done
has "$T/brief-template.md" '{{STATUS_KAWIN}}'
has "$S/kontrak-draft/SKILL.md" 'sudah kawin'
has "$S/kontrak-gate/SKILL.md" 'sudah kawin'
# the old unconditional age rule is gone from the executable skill text
hasnt "$S/kontrak-draft/SKILL.md" '**Blok wali, usia di bawah 21** (KUHPerdata Art. 330)'
hasnt "$S/kontrak-gate/SKILL.md" 'Di bawah 21 (Art. 330 KUHPerdata, lihat `perdata.md`): harus ada blok wali'
has "$R/hukum/perdata.md" 'sudah kawin dianggap dewasa'
has "$R/hukum/ketenagakerjaan.md" 'belum kawin'

# --- PA-I2: Art. 1309 covers partial performance only
for f in "$R/pasal/ganti-rugi.md" "$g" "$T"/*.md; do
  hasnt "$f" 'atau jumlahnya tidak patut, jumlahnya diturunkan sesuai Pasal 1309'
done
has "$R/pasal/ganti-rugi.md" 'INDUSIA berjanji menurunkan jumlah'

# --- PA-I3: BPJS list is open, JHT researched
has "$R/hukum/pajak-jaminan-sosial.md" 'JHT'
has "$R/hukum/pajak-jaminan-sosial.md" 'PP 44/2015 Art. 4(1)'
has "$R/hukum/pajak-jaminan-sosial.md" 'Permenaker 5/2021 Art. 3(1)'
for f in "$R/pasal/pajak.md" "$g"; do
  has "$f" 'antara lain JKK, JKM, JHT'
  hasnt "$f" 'program jaminan kecelakaan kerja dan jaminan kematian BPJS Ketenagakerjaan serta pada BPJS Kesehatan'
done
awk '/^## P-PJ-03/{e=1; next} /^## /{e=0} e && /^\*\*Risiko/ && /JP/ && /JKP/ {c=1} END{exit c?0:1}' "$R/pasal/pajak.md" || bad "pajak.md P-PJ-03 Risiko must say JP and JKP are not researched"

# --- PA-I4: gate G6 requires P-HKI-04 (also in the plan)
has "$gt" 'P-HKI-04'
has "$ROOT/docs/plans/2026-10-03-KKJ-1-gaspol-kontrakkerja-plan.md" 'P-HKI-04'

# --- PA-I5: place of work in PKWT/PKWTT (PP 35/2021 Art. 13), not in freelancer
for f in "$T/kontrak-pkwt.md" "$T/kontrak-pkwtt.md"; do has "$f" '{{TEMPAT_KERJA}}'; has "$f" '{{KONDISI_KERJA}}'; done
hasnt "$T/kontrak-freelancer.md" '{{TEMPAT_KERJA}}'
hasnt "$T/kontrak-freelancer.md" '{{KONDISI_KERJA}}'
has "$T/brief-template.md" '{{TEMPAT_KERJA}}'
has "$T/brief-template.md" '{{KONDISI_KERJA}}'
has "$R/hukum/ketenagakerjaan.md" 'PP 35/2021 Art. 13'
has "$R/hukum/ketenagakerjaan.md" 'tempat pekerjaan'
has "$S/kontrak-draft/SKILL.md" 'TEMPAT_KERJA'
has "$S/kontrak-brainstorm/SKILL.md" 'Tempat pekerjaan'
has "$gt" 'tempat pekerjaan'
has "$g" 'bertempat kerja di'

# --- fix-round 2
# I1: PKWT/PKWTT komparisi carries the Art. 13 identity fields (jenis usaha, jenis kelamin, umur); freelancer untouched
for f in "$T/kontrak-pkwt.md" "$T/kontrak-pkwtt.md"; do
  for k in PT_JENIS_USAHA PIHAK_KEDUA_JENIS_KELAMIN PIHAK_KEDUA_USIA; do has "$f" "{{$k}}"; done
done
for k in PT_JENIS_USAHA PIHAK_KEDUA_JENIS_KELAMIN PIHAK_KEDUA_USIA; do
  has "$T/brief-template.md" "{{$k}}"; hasnt "$T/kontrak-freelancer.md" "{{$k}}"
done
has "$S/kontrak-brainstorm/SKILL.md" 'Jenis usaha'
has "$S/kontrak-brainstorm/SKILL.md" 'Jenis kelamin'
has "$S/kontrak-draft/SKILL.md" 'PT_JENIS_USAHA'
has "$S/kontrak-draft/SKILL.md" 'PIHAK_KEDUA_JENIS_KELAMIN'
has "$gt" 'jenis usaha'
has "$gt" 'jenis kelamin'
hasre "$g" 'bergerak di bidang '
hasre "$g" 'berjenis kelamin '
# I2: G5 extra (a) is conditional on 'belum kawin'
grep -qE 'padahal berusia di bawah 21( *$| +[^d])' "$gt" && bad "kontrak-gate/SKILL.md: G5 extra (a) not conditional on belum kawin"
has "$gt" 'padahal berusia di bawah 21 dan belum kawin'
# M4: Art. 13 is PKWT only; PKWTT basis is UU 13/2003 Art. 54(1), flagged as primary-PDF only
for f in "$S"/*/SKILL.md "$T"/*.md; do
  [ -f "$f" ] && grep -E 'PKWTT' "$f" | grep -qF 'PP 35/2021 Art. 13' && bad "${f#$ROOT/}: a PKWTT line cites PP 35/2021 Art. 13 (PKWT only)"
done
hasnt "$T/kontrak-pkwtt.md" 'PP 35/2021 Art. 13'
has "$T/kontrak-pkwtt.md" 'UU 13/2003 Art. 54(1)'
has "$gt" 'UU 13/2003 Art. 54(1)'
has "$R/hukum/ketenagakerjaan.md" 'hanya dibaca dari PDF primer'
# M5: STATUS_KAWIN value defined for age >= 21
has "$T/brief-template.md" 'tidak relevan (usia 21 tahun ke atas)'
has "$S/kontrak-brainstorm/SKILL.md" 'tidak relevan (usia 21 tahun ke atas)'
# M6: no dead 'telah dewasa' replacement branch in the draft skill
hasnt "$S/kontrak-draft/SKILL.md" 'pasal lain Lampiran I (bila ada)'
# M7: a drafted kontrak.md never says 'lolos pemeriksaan'; the good fixture ends with the draft GATE-STATUS line
hasnt "$g" 'lolos pemeriksaan'
has "$g" '<!-- GATE-STATUS -->Draf ini DISUSUN per'
[ "$(grep -c 'GATE-STATUS' "$g")" -eq 1 ] || bad "good-kontrak.md: GATE-STATUS must appear exactly once"

# --- fix-round 3
has "$S/kontrak-draft/SKILL.md" 'ANGKA saja'
sed -n '/Fakta penentu hukum:/,/Jangan diisi/p' "$S/kontrak-draft/SKILL.md" | grep -q 'jenis usaha' || bad "kontrak-draft/SKILL.md: mandatory-facts list lacks jenis usaha"
sed -n '/Fakta penentu hukum:/,/Jangan diisi/p' "$S/kontrak-draft/SKILL.md" | grep -q 'jenis kelamin' || bad "kontrak-draft/SKILL.md: mandatory-facts list lacks jenis kelamin"
grep -E 'Jenis usaha Pihak Pertama' "$T/brief-template.md" | grep -qF '[user]' || bad "brief-template.md: Jenis usaha line must allow [user]"
has "$ROOT/evals/03-underage-noncompete.md" 'already ends with a `<!-- GATE-STATUS -->` line'
hasnt "$ROOT/evals/03-underage-noncompete.md" 'A `<!-- GATE-STATUS -->` last line added'
has "$ROOT/evals/01-bad-fixture.md" 'EXTRA catches'

# --- item 10: env var inline on the build.sh call
hasre "$S/kontrak-finish/SKILL.md" 'KONTRAK_REVIEW=review\.md bash \.\./\.\./scripts/build\.sh'

[ "$fail" -eq 0 ] && echo "PASS legal-content"
exit "$fail"
