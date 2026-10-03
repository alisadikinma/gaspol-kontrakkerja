---
name: kontrak-gate
description: The blocking gate of gaspol-kontrakkerja. Use before any employment contract, freelancer agreement, or IP/NDA attachment is signed, rendered, or sent — ours from kontrak-draft or one written by someone else — periksa kontrak, review kontrak kerja, cek PKWT, cek perjanjian freelancer, audit klausul NDA dan HKI, gate kontrak sebelum tanda tangan. Checks nine gates (G1 wadah, G2 dasar hukum, G3 forbidden traps, G4 non-compete, G5 age, G6 IP, G7 enforcement, G8 numbers and freshness, G9 signatory) with quoted evidence per finding. Emits review.md with verdict PASS or BLOCKING, the sha256 of the reviewed kontrak.md, and loops back to kontrak-draft until PASS. Never edits kontrak.md.
---

# kontrak-gate

> Path ke file plugin (`../../references/…`, `../../templates/…`) dihitung dari folder skill
> ini, bukan dari folder kerja.

> Gate adalah pembaca terakhir sebelum kontrak ditandatangani. Setelah itu kontrak dibaca
> orang yang tidak bisa bertanya lagi. Gate tidak melunak karena terburu-buru, dan PASS
> bukan jaminan: PASS hanya berarti pemeriksaan aturan di bawah lolos per tanggal itu.

**Announce at start (Indonesian):**
> "Saya pakai kontrak-gate. Saya periksa kontrak.md dengan sembilan gate (G1 sampai G9) dan
> menulis review.md berisi PASS atau BLOCKING. BLOCKING dikembalikan ke kontrak-draft.
> Saya tidak mengubah kontrak.md."

## Input

- `kontrak.md` di folder kerja, atau file kontrak yang disebut Ali. Tidak ada: tolak, satu
  kalimat, arahkan ke `kontrak-draft`.
- `brief.md` di folder kerja (fakta: wadah, tanggal lahir, upah, akses, penandatangan,
  tag `[user]` `[vault]` `[riset]` `[ASUMSI]`). Tidak ada: lanjut hanya jika kontrak datang
  dari luar; catat "brief.md tidak ada" sebagai temuan G2 dan jangan menebak fakta.
- Pustaka, dibaca saat dijalankan, bukan dari ingatan:
  `../../references/pasal/*.md` (daftar id `P-XXX-NN` yang sah) dan
  `../../references/hukum/*.md` (teks aturan, frontmatter `verified:`; `ketenagakerjaan.md`,
  `perdata.md`, `hki-rahasia-dagang.md`, `pidana.md`, `data-pribadi.md`,
  `pajak-jaminan-sosial.md`, `signing-authority.md`).
- Vault `/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md` untuk G9.
  Tidak terbaca: katakan satu baris dengan teks errornya; itu bukan "kosong".
- Hari ini: `date +%Y-%m-%d`. Jangan memakai tanggal dari ingatan.

## Aturan keras

1. **Tidak pernah mengubah `kontrak.md`** (atau `brief.md`). Gate hanya membaca dan menulis
   `review.md`. Perbaikan adalah kerja `kontrak-draft`. Gate yang mengedit kontrak yang
   diperiksanya membuat `kontrak_sha256` tidak berarti.
2. **BLOCKING bila satu saja gate gagal.** Tidak ada "lolos bersyarat", tidak ada tingkat
   keparahan yang meloloskan.
3. **Setiap temuan menyebut pasal dan mengutip bukti** (potongan kalimat kontrak persis
   dalam tanda kutip, dengan nomor pasal dan bagian: kontrak atau Lampiran I). Temuan tanpa
   kutipan tidak boleh ditulis. Temuan "tidak ada" (absensi) hanya setelah mencari di
   seluruh file, termasuk sinonim.
4. **Dasar hukum di temuan diambil dari `../../references/hukum/*.md`**, dengan nama file.
   Jangan mengutip pasal, putusan, atau angka sanksi dari ingatan. Tidak ada di pustaka:
   tulis "tidak ada di pustaka" dan jangan mengarang.
5. **Baris `<!-- GATE-STATUS -->`** (baris terakhir file yang ditulis `kontrak-draft`, berisi
   "Draf ini DISUSUN per … menunggu kontrak-gate") dan bagian `# CATATAN PENYUSUN` adalah
   normal, **bukan temuan**. Bagian catatan dibaca sebagai konteks (celah, kontradiksi
   wadah yang dicatat penyusun, tanggal verifikasi), bukan sebagai klausul. Satu
   pengecualian: kata "dijamin" di mana pun dalam file adalah temuan G9.
6. **Fakta berasal dari `brief.md`, bukan dari kontrak.** Bila kontrak dan brief berbeda
   (usia, upah, wadah, akses), itu temuan di gate yang terkait.
7. **Aturan putaran: loop back to kontrak-draft until PASS.** Setelah BLOCKING, gate dijalankan lagi pada
   `kontrak.md` hasil revisi; `review.md` baru menggantikan yang lama.

## Sembilan gate

Jalankan semuanya, berurutan, setiap kali. Teks gate di bawah adalah daftar resmi, disalin
apa adanya. Pemeriksaan tambahan ada di bawah tiap gate.

- **G1 Wadah:** wadah (PKWT / PKWTT / freelancer) contradicts the facts. Fixed working hours or attendance in a freelancer agreement; probation in a PKWT (Art. 58 UU 13/2003, batal demi hukum); PKWT used for permanent core work.
- **G2 Dasar hukum:** a clause without a `Catatan penyusun — dasar:` line, or citing a clause id absent from `../../references/pasal/`.
- **G3 Jebakan terlarang:** withholding diploma/ID/original documents; wage below UMK while a work relationship exists (prohibition Art. 88E(2) UU 13/2003 jo. UU 6/2023; criminal sanction per Art. 185 as amended by UU 1/2026 — cite from `../../references/hukum/ketenagakerjaan.md`, never a figure from memory); removing mandatory rights (BPJS enrolment, PKWT compensation, THR, overtime); penalty above ~1 month fee/wage (Art. 1309 KUHPer: judge may reduce if the main obligation was partly performed) without a stated reduction-proof rationale; time limit on ownership of IP or source code.
- **G4 Non-kompetisi:** non-compete without an explicit written purpose of protecting trade secrets / legitimate business interest; or scope not specific (activity, duration, area).
- **G5 Usia:** candidate under 21 (KUHPer Art. 330) with no guardian "mengetahui dan menyetujui" signature block.
- **G6 HKI:** IP assignment not explicit (Art. 16(2) UU 28/2014 requires only a written agreement; "comprehensive, permanent, irrevocable" is INDUSIA's own clause design, not a statutory requirement); "Hasil Karya" defined narrowly (must cover source code, object code, repository + commit history, database + schema, scripts, configuration, prompts, models + weights, datasets, algorithms, technical documentation, SOP, test results, derivative works; across all projects/customers/business lines); moral-rights handling missing (Art. 5: moral rights stay with creator — clause obtains non-assertion consent only); no copyleft-hygiene warranty.
- **G7 Penegakan:** no "upaya layak" confidentiality clause (Art. 3 UU 30/2000); no set-off clause (Art. 1425 KUHPer) where damages exist; no dispute forum stated correctly (PHI for employment; PN for freelancer agreement).
- **G8 Angka & kesegaran:** a number (UMK, rate, percentage, amount) without a verification date; any referenced `../../references/hukum/*.md` with `verified:` older than 180 days relative to today.
- **G9 Penandatangan:** the PT signatory has no stated authority basis (per `../../references/hukum/signing-authority.md` and vault `company-legal`); party identity fields incomplete; criminal-law text used as a threat to force civil payment instead of as a plain notice.

### Cara memeriksa, per gate

**G1.** Ambil wadah dari `brief.md` dan dari judul kontrak; bandingkan dengan isi.
- Freelancer: cari jam kerja, absensi, hari kerja, masa percobaan, cuti, lembur, pengawasan
  harian, kewajiban hadir. Satu saja = temuan.
- PKWT: cari pasal masa percobaan atau kata "masa percobaan" dan "penilaian" yang
  menentukan kelanjutan. Ada = temuan, bahkan bila pasal itu punya baris dasar. Cek juga
  pekerjaan inti yang tetap (bukan proyek, musiman, atau sementara) dan jangka waktu
  terhadap batas PKWT di `ketenagakerjaan.md`.
- PKWTT: kontrak yang memuat tanggal berakhir adalah kontradiksi.
- Kontradiksi wadah yang dicatat penyusun di CATATAN PENYUSUN tetap temuan; gate yang
  memutuskan, bukan catatan.

**G2.** Untuk setiap `## Pasal` (di kontrak **dan** di Lampiran I) harus ada baris
`> **Catatan penyusun — dasar:** P-XXX-NN; …` tepat di bawah judul.
- Hitung judul `## Pasal` dan baris dasar; selisih = temuan, sebut pasal yang tanpa baris.
- Setiap id `P-XXX-NN` di baris dasar harus ada sebagai judul `## P-XXX-NN` di
  `../../references/pasal/*.md`. Id yang tidak ada = temuan.
- Tambahan (b): setiap id itu juga harus **cocok dengan isi pasal**. Pasal tentang
  masa percobaan yang bersandar pada id pajak, atau pasal ijazah yang bersandar pada id
  pengembalian aset yang melarang penahanan, adalah dasar yang tidak mendukung klausulnya;
  tulis sebagai temuan hanya bila klausul itu melanggar apa yang dilarang entri tersebut.
- Pasal tanpa dasar yang memang tidak ada di pustaka tidak dibenarkan; draf harus STOP.

**G3.** Cari dengan kata kunci lalu baca konteksnya.
- Penahanan: ijazah, KTP, paspor, akta, sertifikat, dokumen asli, "menyimpan",
  "menahan", "jaminan". Kalimat yang justru **melarang** INDUSIA menahan bukan temuan.
- Upah: bandingkan upah di kontrak dengan UMK di `brief.md` (nilai, sumber, tanggal ambil).
  Di bawah UMK saat ada hubungan kerja = temuan. Kontrak PKWT/PKWTT tanpa kalimat bahwa
  upah tidak lebih rendah dari UMK = temuan. Sanksi pidana hanya disebut bila perlu dan
  hanya dari `ketenagakerjaan.md`, dengan nama file.
- Hak wajib yang dihapus: BPJS, uang kompensasi PKWT, THR, lembur. Kalimat yang
  menggugurkan, mengurangi, atau menggantinya dengan hal lain = temuan.
- Penalti dan ganti rugi: cari angka bulan upah/imbalan atau jumlah tetap. Batas ganti rugi
  atau penalti **lebih dari kira-kira 1 bulan upah/imbalan** (misal 12 bulan, penalti
  tetap "terlepas dari kerugian nyata") = temuan, kecuali ada alasan tertulis yang
  menjelaskan mengapa angka itu wajar (rationale pembuktian pengurangan). Pelanggaran IP
  dan rahasia dagang boleh di luar batas bila dibatasi pada kerugian nyata yang dibuktikan.
  Tambahan (c): rujukan **Art. 1307** untuk hak hakim menurunkan penalti salah; yang benar
  **Art. 1309 KUHPer**. Kontrak yang memakai Art. 1307 untuk itu = temuan; bila dasar
  baris memuat 1307 untuk pengurangan, itu juga temuan.
- Batas waktu kepemilikan: kewajiban kerahasiaan source code atau rahasia dagang yang
  berakhir (misal "1 tahun sejak Perjanjian berakhir"), atau hak memakai, menjual,
  menerbitkan Hasil Karya yang dibatasi waktu = temuan. Kerahasiaan informasi umum boleh
  berjangka; source code, rahasia dagang, dan kepemilikan IP tidak.

**G4.** Untuk setiap klausul non-kompetisi (setelah hubungan berakhir, selama perjanjian,
larangan membujuk): harus ada kalimat tujuan tertulis yang menyebut perlindungan rahasia
dagang atau kepentingan bisnis yang sah, **dan** kegiatan, lama, wilayah yang spesifik.
Salah satunya hilang atau umum ("semua usaha sejenis, tanpa batas") = temuan. Brief
meminta non-kompetisi tetapi kontrak tanpa pasalnya bukan temuan G4 (catat di G2/CATATAN).

**G5.** Hitung usia dari tanggal lahir di `brief.md` (atau komparisi) terhadap tanggal tanda
tangan. Di bawah 21 (Art. 330 KUHPerdata, lihat `perdata.md`): harus ada blok wali
berisi "mengetahui dan menyetujui", nama wali, dan hubungan; di kontrak **dan** di Lampiran
I bila lampiran punya blok tanda tangan sendiri. Tambahan (a): kalimat bahwa Pihak Kedua
"telah dewasa" (misal "menyatakan telah dewasa menurut hukum") padahal berusia di bawah 21
adalah **kontradiksi G5/G1** dan BLOCKING, sekalipun blok wali ada. Kutip kalimatnya.
Usia di kontrak harus sama dengan hasil hitungan; selisih = temuan. Usia di bawah 18 = temuan.

**G6.** Baca pasal Hasil Karya dan pasal pengalihan.
- Pengalihan hak ekonomi harus tertulis dan eksplisit ("mengalihkan"), bukan sekadar
  "memberi lisensi" atau "menjadi milik".
- Definisi Hasil Karya harus memuat **semua** butir G6: source code, object code,
  repositori beserta riwayat commit, basis data beserta skema, skrip, konfigurasi, prompt,
  model beserta bobot, dataset, algoritma, dokumentasi teknis, SOP, hasil pengujian, karya
  turunan; dan berlaku untuk seluruh proyek, pelanggan, dan lini bisnis. Daftar butir yang
  hilang disebut satu per satu.
- Hak moral: harus ada persetujuan tidak menggunakan (non-assertion), bukan klaim
  pengalihan hak moral. Klausul yang bilang hak moral "dialihkan" = temuan.
- Garansi copyleft: ada janji tidak ada komponen GPL/AGPL tanpa persetujuan tertulis.
- Pembatasan waktu pada pemakaian Hasil Karya dilaporkan di **G3** dan **G6** sekaligus.
- Kontrak tanpa Lampiran I (PKWT, PKWTT, freelancer semuanya wajib) = temuan G6.

**G7.** Cari tiga hal. (1) Kalimat "upaya layak" yang menyebut Art. 3 UU 30/2000.
(2) Pasal perjumpaan utang (Art. 1425 KUHPerdata) bila ada klausul ganti rugi.
(3) Forum sengketa: PHI untuk kontrak kerja (PKWT, PKWTT); PN (dengan kedudukan yang
disebut) untuk freelancer. Forum yang tertukar (freelancer ke PHI, karyawan ke PN atau
arbitrase tunggal) atau tidak ada = temuan.

**G8.** (1) Setiap angka di kontrak: UMK, tarif, persentase, jumlah uang. Angka UMK harus
disertai tanggal verifikasi dan sumber (dari `brief.md`). Angka yang disepakati para pihak
(upah, imbalan) cukup bertanggal perjanjian. Tidak boleh ada persentase BPJS atau pajak.
(2) Staleness: dari setiap file `../../references/hukum/*.md` yang dirujuk (semua yang
disebut di baris dasar, plus `ketenagakerjaan.md` dan `signing-authority.md`), baca
`verified:` dan hitung selisih hari dengan hari ini
(`date -j -f "%Y-%m-%d" <verified> +%s`, bandingkan dengan `date +%s`). **Lebih dari 180
hari = G8 gagal**, sebut file dan tanggalnya. Tanggal `verified:` di CATATAN PENYUSUN harus
sama dengan frontmatter; beda = temuan.

**G9.** Komparisi: nama penandatangan PT, jabatan, dan **dasar kewenangan** (akta,
pengesahan, keputusan RUPS, atau surat kuasa khusus bila bukan direksi), cocok dengan
`signing-authority.md` dan vault `company-legal`. Identitas Pihak Kedua: nama, tanggal lahir,
jenis dan nomor identitas, alamat. Ada yang kosong, `{{`, atau `[ASUMSI]` di brief = temuan.
Teks pidana: harus berbentuk pemberitahuan ("ini pemberitahuan, bukan ancaman") dan tidak
dipakai untuk menagih utang perdata; kalimat seperti "bila tidak membayar, akan dilaporkan
pidana" = temuan. Tambahan: kata "dijamin" di kontrak = temuan.

## Cara kerja

1. Baca input (di atas). Hitung `shasum -a 256 kontrak.md` **sebelum** menganalisis dan
   catat hasilnya; file tidak berubah selama gate jalan.
2. Jalankan G1 sampai G9. Untuk setiap gate catat: lolos, atau daftar temuan (pasal,
   kutipan, alasan).
3. Setiap temuan punya kolom **Fix**: apa yang harus dilakukan `kontrak-draft`, tanpa
   menulis ulang klausulnya sendiri.
4. Jangan menambah temuan dari selera gaya. Hanya yang masuk G1 sampai G9.
5. Tulis `review.md` (format di bawah) di folder kerja, menimpa yang lama.

## Format `review.md`

```markdown
## Verdict: PASS | BLOCKING

reviewed_at: YYYY-MM-DD
kontrak_sha256: <hasil shasum -a 256 kontrak.md>

| Gate | Status | Evidence | Fix |
|---|---|---|---|
| G1 Wadah | PASS | — | — |
| G3 Jebakan terlarang | BLOCKING | Pasal 11 "penalti tetap sebesar 12 (dua belas) bulan upah" | Turunkan batas sekitar 1 bulan atau tulis alasan; rujuk Art. 1309 |
| … | | | |
```

- Baris pertama berisi `## Verdict: PASS` atau `## Verdict: BLOCKING`, persis itu.
- Tabel memuat **sembilan baris**, G1 sampai G9, berurutan, setiap kali. Gate yang gagal
  bisa punya beberapa temuan: beberapa baris dengan gate yang sama, atau satu baris dengan
  temuan dipisah `<br>`. Kolom Evidence berisi nomor pasal dan kutipan.
- `reviewed_at` = hari ini. `kontrak_sha256` = hasil `shasum -a 256` (hanya 64 karakter
  hex). **PASS yang berlaku** = verdict PASS **dan** sha sama dengan `kontrak.md` sekarang.
  Kontrak yang berubah sesudah PASS membuat PASS itu basi; gate dijalankan lagi.
- Verdict PASS hanya bila sembilan baris berstatus PASS.
- Di bawah tabel, bila BLOCKING: bagian `## Daftar perbaikan` bernomor, satu butir per
  temuan (pasal, gate, apa yang salah, apa yang harus dilakukan draft). Fakta yang hanya
  Ali yang punya (tanggal lahir, wali, tanggal ambil UMK) ditandai "tanya Ali".

## Setelah verdict

- **BLOCKING:** katakan ke Ali dalam bahasa Indonesia gampang: jumlah gate yang gagal,
  butir perbaikan tersingkat, dan bahwa langkah berikutnya `kontrak-draft`, yang menulis
  ulang kontrak dari template dan pustaka. Gate tidak menambal. Loop back to kontrak-draft
  until PASS, lalu jalankan gate lagi.
- **PASS:** katakan bahwa pemeriksaan aturan lolos per `reviewed_at`, bahwa ini bukan
  jaminan, dan bahwa tinjauan advokat disarankan sebelum tanda tangan. Arahkan ke
  `kontrak-finish`, yang hanya jalan bila PASS berlaku.

## Pemeriksaan sendiri sebelum menulis review.md

- Sembilan baris G1 sampai G9 ada.
- Setiap temuan punya nomor pasal dan kutipan persis dari file, bukan parafrase.
- Tidak ada angka sanksi atau pasal dari ingatan; semua dari `../../references/hukum/`.
- `kontrak.md` tidak berubah (`shasum -a 256` yang sama sebelum dan sesudah).
- Baris GATE-STATUS tidak dilaporkan sebagai temuan.
