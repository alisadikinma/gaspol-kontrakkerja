---
name: kontrak-finish
description: Final phase of gaspol-kontrakkerja. Use once kontrak-gate has returned a current PASS to produce the files for signing — render kontrak ke PDF dan Word, buat PDF kontrak berkop PT, finalisasi kontrak untuk tanda tangan. Refuses without a current PASS (review.md verdict PASS and kontrak_sha256 equal to the sha256 of kontrak.md). Strips the drafter notes into a cleaned copy, renders KONTRAK-<CODE>-<NNN>.pdf on the company letterhead and KONTRAK-<CODE>-<NNN>.docx from the same cleaned markdown, looks at the rendered pages and the DOCX XML, then offers to record durable lessons. Never edits kontrak.md.
---

# kontrak-finish

> Path ke file plugin (`../../references/…`, `../../templates/…`, `../../scripts/…`) dihitung
> dari folder skill ini, bukan dari folder kerja.

> PDF dan DOCX inilah yang ditandatangani. Keduanya hanya dibuat dari `kontrak.md` yang
> lolos gate dalam bentuknya sekarang. PASS berarti pemeriksaan aturan lolos per tanggal itu,
> bukan jaminan; tinjauan advokat tetap disarankan.

**Announce at start (Indonesian):**
> "Saya pakai kontrak-finish. Saya pastikan PASS-nya masih berlaku, lalu membuat PDF dan
> DOCX dari salinan bersih kontrak.md, memeriksa hasilnya dengan mata, dan menawarkan
> mencatat pelajaran. kontrak.md tidak saya ubah."

## Gerbang masuk (STOP bila gagal)

Di folder kerja, jalankan dan baca hasilnya, bukan ingatan:

```bash
head -1 review.md                                   # harus persis: ## Verdict: PASS
sed -n 's/^kontrak_sha256: *//p' review.md          # sha di review
shasum -a 256 kontrak.md | awk '{print $1}'         # sha kontrak sekarang; harus sama
sed -n 's/^reviewed_at: *//p' review.md             # tanggal PASS
```

**PASS yang berlaku** = baris verdict `## Verdict: PASS` **dan** kedua sha sama. Selain itu
STOP, katakan alasannya dalam satu kalimat, dan arahkan:

| Keadaan | Alasan yang dikatakan | Arah |
|---|---|---|
| `review.md` tidak ada | belum ada pemeriksaan | `kontrak-gate` |
| verdict `BLOCKING` | gate menolak; jangan dibuat PDF "untuk dilihat dulu" | `kontrak-draft` dengan daftar perbaikan |
| sha beda | kontrak.md berubah sesudah PASS, PASS basi | `kontrak-gate` ulang |
| `kontrak.md` tidak ada | tidak ada yang dirender | `kontrak-draft` |

Tidak ada pengecualian, termasuk "hanya untuk internal". File yang dirender akan keluar
dari folder ini.

## Aturan keras

1. **`kontrak.md` tidak diubah.** Penggantian baris `<!-- GATE-STATUS -->` dan pembuangan
   `# CATATAN PENYUSUN` terjadi hanya pada salinan kerja (`scripts/clean.sh`). Cek
   `shasum -a 256 kontrak.md` sama sebelum dan sesudah.
2. **Tidak ada nilai perusahaan di repo atau di skill ini.** Nama, alamat, NIB, NPWP, SK,
   telepon, surel dibaca dari vault saat dijalankan.
3. **Tidak ada kop dengan nilai kosong.** Nilai kop tidak terisi: skrip berhenti dengan
   kode 2. Jangan diakali dengan mengisi tebakan.
4. PDF dan DOCX tidak ditimpa bila file bernama sama sudah ada (lihat "Nama file").
5. Hasil render memuat nilai nyata perusahaan: jangan di-commit ke repo plugin
   (`*.pdf` dan `*.docx` sudah di `.gitignore`).

## Langkah 0 — baca dan siapkan

1. `brief.md`: `{{KODE_KONTRAK}}` di judul (misalnya `BC-FL`) menjadi `<CODE>`. Tidak ada
   atau kosong: tanya Ali, jangan mengarang kode.
2. Vault, langsung dari disk atau Obsidian MCP (nama vault `obsidian-vault`):
   `/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md`. Tidak terbaca:
   katakan satu baris dengan teks errornya dan STOP. Tidak terbaca bukan berarti kosong.
3. Logo: variabel `KONTRAK_LOGO`; bila tidak diset, skrip memakai logo bawaan di path
   default `build.sh`. Logo tidak ada: skrip keluar dengan kode 2; tanya Ali di mana logonya.
4. Alat: `pandoc`, Chrome, `pdftoppm` (PDF), skill `anthropic-skills:docx` (DOCX). Skill
   docx tidak tersedia: STOP, katakan satu baris bahwa DOCX tidak bisa dibuat di sesi ini
   dan PDF tetap bisa; jangan mengganti konverter lain diam-diam.

## Nama file

`KONTRAK-<CODE>-<NNN>.pdf` dan `KONTRAK-<CODE>-<NNN>.docx`.

- `<CODE>` dari brief (langkah 0).
- `<NNN>`: nomor urut tiga digit berikutnya yang bebas di folder kerja:

```bash
n=1; while ls KONTRAK-<CODE>-$(printf '%03d' $n).* >/dev/null 2>&1; do n=$((n+1)); done; printf '%03d\n' $n
```

PDF dan DOCX satu kontrak memakai NNN yang sama. Jangan menimpa file bertanda tangan.

## Langkah 1 — salinan bersih dan PDF

```bash
export KONTRAK_REVIEW=review.md          # PASS yang berlaku; clean.sh memeriksanya lagi
bash ../../scripts/clean.sh kontrak.md "$TMPDIR/bersih.md" review.md
bash ../../scripts/build.sh kontrak.md KONTRAK-<CODE>-<NNN>.pdf
```

(`../../scripts/` dihitung dari folder skill; dari folder kerja, pakai path absolut
skrip di folder plugin.) `clean.sh` membuang `# CATATAN PENYUSUN` sampai akhir file dan
tiap baris `> **Catatan penyusun`, mengganti baris GATE-STATUS dengan kalimat
`Draf ini lolos pemeriksaan aturan per <reviewed_at>. Tinjauan advokat disarankan sebelum tanda tangan.`,
membungkus penutup + tanda tangan dalam `::: ttd` (satu halaman), dan menolak (kode 3) bila
review bukan PASS yang berlaku. `build.sh` mengisi `../../templates/kop.html` dan memakai
`../../templates/style.css`.

Pesan `line NNN: <file>.pdf: No such file or directory` di stderr saat Chrome menulis adalah
pemeriksaan polling dan tidak berbahaya selama kode keluar 0 dan PDF ada. Nama PT untuk
`grep` di langkah 4 dibaca dari bullet `- **Nama**:` catatan vault.

Kode keluar `build.sh`: 2 = logo, catatan vault, atau nilai kop tidak ada (pesan menyebut
yang mana; selesaikan, jangan dilewati). Kolom kop yang boleh kosong hanya dua:

- **Merek** (`- **Merek**: …` di catatan vault): kata merek di kop. Tidak ada: kop memakai
  nama PT sebagai tulisan merek dan baris nama PT terpisah dibuang.
- **Tagline** (`- **Tagline**: …`): tidak ada: sel tagline dibuang utuh, bukan dibiarkan kosong.

## Langkah 2 — periksa PDF dengan mata (bukan dianggap beres)

```bash
pdftotext -layout KONTRAK-<CODE>-<NNN>.pdf - | grep -c '{{'          # harus 0
pdftotext -layout KONTRAK-<CODE>-<NNN>.pdf - | grep -ci 'catatan penyusun'   # harus 0
pdftoppm -r 70 -png KONTRAK-<CODE>-<NNN>.pdf "$TMPDIR/hal"
```

Lalu **buka PNG-nya dengan Read dan lihat**: (a) halaman 1: logo terlihat, nilai kop terisi
semua, tidak ada `{{`; (b) halaman yang memuat `DEMIKIANLAH PERJANJIAN INI`: kalimat
penutup, tabel tanda tangan, dan blok wali (bila ada) utuh dalam satu halaman, tidak
terpotong; (c) halaman pertama Lampiran I mulai di halaman baru. Cari halaman dengan
`pdftotext -f N -l N`. Ada yang salah: perbaiki sumbernya (CSS, kop, vault), render ulang;
jangan menyerahkan file yang belum dilihat.

## Langkah 3 — DOCX dari salinan bersih yang sama

Muat skill `anthropic-skills:docx` (Skill tool). Bahannya adalah `$TMPDIR/bersih.md`, bukan
`kontrak.md`, supaya PDF dan DOCX berisi teks yang persis sama. Pemetaan:

| Isi | Di Word |
|---|---|
| kop (logo, merek atau nama PT, alamat, NIB, NPWP, SK, telp, surel) | **header dokumen**, nilai dari catatan vault |
| `# Judul` dan `# LAMPIRAN I …` | Heading 1, tengah; Lampiran mulai di halaman baru |
| `## Pasal N …` | Heading 2, tengah |
| paragraf, `**tebal**`, daftar bernomor | paragraf rata kiri-kanan, tebal, daftar bernomor Word |
| tabel tanda tangan dan tabel wali | tabel Word sungguhan, baris tanda tangan kosong, baris tidak boleh terbelah halaman |
| kalimat PASS di akhir | paragraf biasa di akhir |

Pembuat bawaan plugin: `node ../../scripts/md2docx.js "$TMPDIR/bersih.md" <company-legal.md> KONTRAK-<CODE>-<NNN>.docx "$KONTRAK_LOGO"`
(argumen logo boleh kosong: skrip memakai `$KONTRAK_LOGO`, lalu logo bawaan yang sama
dengan `build.sh`. Paket npm `docx` belum tentu terpasang; `Cannot find module 'docx'`:
`npm install docx` di folder sementara lalu `export NODE_PATH=<folder>/node_modules`). Pembuat ini memakai catatan vault yang sama dengan
`build.sh`; nilai kosong membuatnya berhenti dengan kode 2. Perlu tata letak lain: tulis
skrip docx-js sendiri sesuai tabel di atas, dari salinan bersih yang sama. Tanpa catatan
penyusun di DOCX, selalu.

## Langkah 4 — periksa DOCX

```bash
unzip -p KONTRAK-<CODE>-<NNN>.docx word/document.xml > "$TMPDIR/doc.xml"
unzip -p KONTRAK-<CODE>-<NNN>.docx 'word/header*.xml' > "$TMPDIR/hdr.xml"
grep -c '{{' "$TMPDIR/doc.xml" "$TMPDIR/hdr.xml"                  # keduanya 0
grep -ci 'catatan penyusun' "$TMPDIR/doc.xml"                      # 0
cat "$TMPDIR/doc.xml" "$TMPDIR/hdr.xml" | grep -c '<nama PT dari vault>'   # ≥ 1
grep -o '<w:tbl>' "$TMPDIR/doc.xml" | wc -l                        # ≥ 1 (tabel tanda tangan)
pandoc -t plain KONTRAK-<CODE>-<NNN>.docx | grep -n 'PIHAK KEDUA'  # tabel tanda tangan terbaca
```

Bila LibreOffice (`soffice`) ada, ubah DOCX ke PDF dan lihat halaman tanda tangannya juga.
Tidak ada: katakan terus terang bahwa tata letak DOCX belum dilihat, hanya strukturnya
yang diperiksa. DOCX gagal dibuat: laporkan teks error apa adanya, jangan menyerahkan
file setengah jadi.

## Langkah 5 — laporan dan tawaran

Laporkan: path PDF dan DOCX, tanggal PASS yang dipakai, hasil pemeriksaan langkah 2 dan 4,
dan bahwa `kontrak.md` tidak berubah (sha sama). Ingatkan: tinjauan advokat disarankan
sebelum tanda tangan.

Lalu **tawarkan**, jangan paksa:

> "Mau saya catat pelajaran dari kontrak ini ke vault (misalnya temuan gate yang berulang
> atau fakta yang Ali konfirmasi)?"

Bila ya: jalankan `gaspol-dev:gaspol-learn` atau tulis satu catatan singkat di vault di
folder yang sesuai, plus satu baris di `hot.md`. Hanya pelajaran yang tahan lama: temuan
gate yang berulang, koreksi Ali, fakta yang dikonfirmasi. Jangan menulis isi kontrak,
identitas pihak kedua, atau angka upah ke vault.
