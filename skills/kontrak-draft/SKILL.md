---
name: kontrak-draft
description: Second phase of gaspol-kontrakkerja. Use after kontrak-brainstorm has produced brief.md, or after kontrak-gate returned BLOCKING, to write or revise kontrak.md — tulis kontrak dari brief, susun draf PKWT, PKWTT, perjanjian freelancer, lampiran IP, perbaiki kontrak setelah review. Picks the template by wadah, fills every clause slot from the clause library (ketat variant when the role touches source code or client data), puts a dasar line under every clause, attaches Lampiran I (NDA, IP assignment, non-compete) to all three types, adds the guardian block for a signatory under 21, and ends with a CATATAN PENYUSUN section. Refuses without brief.md and stops instead of guessing a legal-critical fact. Never claims a contract is safe.
---

# kontrak-draft

> Path ke file plugin (`../../references/…`, `../../templates/…`) dihitung dari folder skill
> ini, bukan dari folder kerja.

> Kontrak ini disusun dari fakta di brief dan pasal di pustaka. Tidak ada angka, nama,
> atau pasal karangan. Yang tidak ada di sumber, ditanyakan atau dicatat sebagai celah.

**Announce at start (Indonesian):**
> "Saya pakai kontrak-draft. Saya baca brief.md, cek faktanya, lalu menyusun kontrak.md dari
> template dan pustaka pasal. Hasilnya belum diperiksa. Pemeriksaan dilakukan kontrak-gate."

**Input:** `brief.md` di folder kerja. Jika ada `review.md` berstatus BLOCKING, itu daftar
perbaikan (lihat "Revisi setelah BLOCKING"). **Output:** `kontrak.md` di folder kerja.
Satu folder kerja = satu kontrak.

## Aturan keras

1. **Tolak jalan tanpa `brief.md`.** Katakan satu kalimat bahwa brief belum ada dan arahkan
   ke `kontrak-brainstorm`. Jangan menulis kontrak dari ingatan atau dari percakapan.
2. **STOP dan tanya Ali** jika fakta yang menentukan hukum bertag `[ASUMSI]`, kosong, atau
   ada di "Hal yang belum diketahui". Fakta penentu hukum: identitas pihak (nama, alamat,
   jenis dan nomor identitas), tanggal lahir atau usia, Status kawin (bila usia di bawah 21), tempat pekerjaan (PKWT dan PKWTT), wadah, upah atau imbalan, tingkat
   akses (source code, data klien), penandatangan PT beserta dasar kewenangannya, tujuan
   non-kompetisi bila pasal itu dipasang, dan wali bila usia di bawah 21 dan belum kawin. Jangan diisi
   nilai "yang biasa". Jawaban Ali dicatat di brief (lihat langkah 1).
3. **Angka dan nama hanya dari brief, vault, atau `../../references/`.** UMK untuk PKWT dan
   PKWTT hanya dari brief (diambil langsung, bertanggal, bersumber). Tanpa tanggal ambil,
   STOP. Jangan menulis UMK dari ingatan.
4. **Teks pasal disalin dari `../../references/pasal/`, bukan ditulis ulang.** Hanya
   penyesuaian yang disebut di langkah 3 dan 4 yang boleh. Pasal hukum tidak dikutip dari
   ingatan: kutipan di dasar baris hanya yang tertulis di entri.
5. **Kata "dijamin" tidak boleh muncul di `kontrak.md`.** Nol kemunculan, termasuk di
   CATATAN PENYUSUN. Jangan menulis "dijamin aman", "dijamin sah", atau sejenisnya. Draf
   ini belum pasti sah sebelum lolos gate dan ditinjau advokat.
6. **Teks pidana hanya sebagai pemberitahuan**, tanpa angka ancaman, dan tidak dipakai
   untuk menagih. Pakai teks dari entri apa adanya.
7. **Tidak ada `{{` tersisa** di `kontrak.md`, dan tidak ada penanda pekerjaan tertunda
   atau tempat kosong.
8. **Berhenti di `kontrak.md`.** Jangan menjalankan gate, jangan membuat PDF atau DOCX.

## Langkah 0 — baca

1. `brief.md` di folder kerja. Jika tidak ada: aturan 1.
2. Vault, langsung dari disk (atau Obsidian MCP, nama vault `obsidian-vault`):
   `/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md` (nama PT, alamat,
   kedudukan, penandatangan, akta pendirian dan pengesahan). Dibaca **saat dijalankan**;
   nilainya tidak ditanam di skill. Jika tidak terbaca: katakan satu baris dengan teks
   errornya dan tanya Ali. Tidak terbaca bukan berarti kosong.
3. `../../references/hukum/signing-authority.md` (siapa boleh menandatangani untuk PT) dan
   `../../references/hukum/ketenagakerjaan.md` (wadah, usia, status UU baru).
4. Template menurut wadah di brief, dari `../../templates/`:
   PKWT → `kontrak-pkwt.md`, PKWTT → `kontrak-pkwtt.md`, freelancer → `kontrak-freelancer.md`.
   Lampiran untuk **ketiganya**: `../../templates/lampiran-ip.md`.
5. Semua `../../references/pasal/*.md` yang memuat id `{{CLAUSE:P-XXX-NN}}` di template.
6. Baris `verified:` dari setiap file `../../references/hukum/*.md` yang dipakai
   (lihat langkah 7). Hari ini dibandingkan dengan tanggal itu: lebih tua dari 180 hari
   berarti STOP dan minta Ali menyegarkan riset dulu.

## Langkah 1 — pemeriksaan sebelum menulis (STOP bila gagal)

Periksa berurutan. Setiap kegagalan: berhenti, katakan apa yang kurang, tanya Ali (satu
pertanyaan, pilihan yang bisa diklik lewat `AskUserQuestion`). Jangan menulis sebagian.

| Cek | Gagal bila |
|---|---|
| Brief utuh | ada `{{` di brief, atau baris fakta tanpa tag `[user]` `[vault]` `[riset]` `[ASUMSI]` |
| Fakta penentu hukum | salah satunya `[ASUMSI]`, kosong, atau hanya ada di "belum diketahui" |
| Wadah | tidak salah satu dari PKWT, PKWTT, freelancer |
| Usia | hitung ulang dari tanggal lahir dan tanggal tanda tangan; beda dengan brief, atau di bawah 18 tahun |
| Status kawin | usia di bawah 21 tetapi Status kawin kosong atau `[ASUMSI]` (Art. 330: belum dewasa = belum genap 21 tahun DAN belum kawin) |
| Wali | usia di bawah 21 **dan belum kawin** tetapi nama atau hubungan wali tidak ada (alamat wali boleh belum ada; catat di CATATAN PENYUSUN). Pihak Kedua yang sudah kawin atau pernah kawin dianggap dewasa: tidak ada wali, tidak ada pembatasan usia |
| Tempat pekerjaan (PKWT dan PKWTT) | `Tempat pekerjaan` di brief kosong (PP 35/2021 Art. 13 huruf d) |
| Penandatangan PT | nama, jabatan, atau dasar kewenangan kosong atau `[ASUMSI]`; bukan direksi tanpa surat kuasa khusus; atau ada benturan kepentingan (UU 40/2007 Art. 98 dan 99, Art. 103, lihat `signing-authority.md`) |
| UMK (PKWT dan PKWTT) | nilai, sumber, atau tanggal ambil tidak ada di brief |
| Jangka waktu | tanggal mulai atau selesai kosong |
| Non-kompetisi | brief minta, tetapi tujuan, kegiatan, lama, atau wilayah kosong |
| Slot tanpa sumber | ada `{{...}}` yang tidak bisa diisi dari brief atau vault (misalnya tanggal bayar upah, tenggat bayar imbalan) |

Jawaban Ali atas pertanyaan di atas ditulis ke `brief.md` di bagian baru
`## Tambahan saat draf`, satu baris per fakta, bertag `[user]`, supaya gate bisa
menelusurinya. Baris lama yang bertag `[ASUMSI]` dan baru dikonfirmasi Ali diubah tagnya
menjadi `[user]`, dengan satu baris di bagian itu yang menyebut baris mana dan kapan.
Brief tidak diubah selain dua hal ini.

Wadah yang bertentangan dengan fakta (brief memuat "Kontradiksi diketahui") **tidak**
dikoreksi di sini. Tulis wadah pilihan Ali apa adanya dan catat kontradiksinya di
CATATAN PENYUSUN. Gate G1 yang memutuskan.

## Langkah 2 — susun kerangka

Salin template wadah ke `kontrak.md`, lalu isi dari atas ke bawah.

- **Placeholder para pihak dan jangka waktu** (`{{PIHAK_KEDUA_NAMA}}`, `{{TANGGAL_MULAI}}`,
  dst.): dari brief dan vault. Tanggal ditulis panjang (15 Oktober 2026). Uang ditulis
  `Rp 18.000.000 (delapan belas juta rupiah)`.
- `{{TEMPAT_KERJA}}` dan `{{KONDISI_KERJA}}` (hanya PKWT dan PKWTT; freelancer tidak punya slot ini dan tidak boleh diberi bahasa jam kerja): dari baris `Tempat pekerjaan` dan `Ringkasan jam kerja dan syarat kerja` di brief, apa adanya. `{{TEMPAT_KERJA}}` kosong: STOP (tempat pekerjaan wajib tertulis, `ketenagakerjaan.md`, PP 35/2021 Art. 13).
- `{{HARI_TANGGAL_TTD}}`: nama hari dihitung dari tanggal tanda tangan di brief
  (`date -j -f "%Y-%m-%d" <tanggal> "+%A"`), bukan ditebak.
- `{{TEMPAT_TTD}}`: dari brief; jika tidak ada, kota kedudukan PT dari vault, dan catat itu
  di CATATAN PENYUSUN.
- `{{NOMOR_KONTRAK}}`: dari brief bila ada; jika tidak, `<NNN>/<JENIS>/<INISIAL>/<bulan
  Romawi>/<tahun>` dari kode brief dan tanggal tanda tangan, NNN `001`; catat di CATATAN
  PENYUSUN bahwa nomor disusun penyusun.
- `{{PT_...}}`: dari vault. `{{PT_DASAR_KEWENANGAN}}` ditulis dari `signing-authority.md`
  (direksi mewakili Perseroan, UU 40/2007 Art. 98(1)) dan dokumen legalitas di vault (akta
  pendirian, pengesahan). Penandatangan bukan direksi: sebut surat kuasa khusus (Art. 103).
- Jumlah upah, imbalan, tunjangan, dan tanggal bayar: persis dari brief atau
  `## Tambahan saat draf`. Tunjangan "tidak ada" ditulis "tidak ada".
- **PKWT dan PKWTT, upah**: pada Pasal Upah tulis kalimat bahwa upah tidak lebih rendah
  dari UMK yang berlaku, `diverifikasi pada tanggal <tanggal ambil di brief> dari <sumber di
  brief>`. Angka UMK boleh ditulis hanya bila brief memuatnya dengan tanggal dan sumber.
  Upah di bawah UMK: STOP, jangan menulis.
- **Prorata** (bulan pertama atau terakhir tidak penuh, atau pembayaran sebanding bagian
  pekerjaan): tulis rumusnya, dihitung dengan hari kalender:
  `prorata = (jumlah hari kalender yang dijalani ÷ jumlah hari kalender dalam bulan itu) ×
  upah bulanan`. Imbalan per hasil yang berhenti sebelum semua tahap selesai (hanya untuk
  bagian yang dapat dipakai INDUSIA): `prorata = (jumlah hari kalender yang dijalani ÷
  jumlah hari kalender seluruh jangka waktu Perjanjian) × imbalan seluruhnya − imbalan yang
  sudah dibayar`. Kalimat rumus ini ditulis penyusun di pasal imbalan; catat di CATATAN
  PENYUSUN.
- **BPJS dan pajak**: kata "sesuai peraturan yang berlaku". Tidak ada persentase, tarif,
  atau batas angka apa pun.

## Langkah 3 — pilih varian dan isi `{{CLAUSE:P-XXX-NN}}`

1. **Pilih varian untuk seluruh kontrak.** Akses source code, repositori, atau data klien di
   brief (`Akses ke source code dan data klien`) berarti **varian ketat** untuk setiap
   klausul. Tanpa akses: **varian standar**. Satu pilihan, dipakai konsisten di kontrak
   dan Lampiran I.
2. **Salin teks varian utuh.** Entri yang varian ketatnya berbunyi "Sama dengan varian
   standar, ditambah …" ditulis **utuh**: teks varian standar penuh, lalu butir tambahan.
   Jangan menulis kata "sama dengan" ke kontrak.
   - Jika kalimat itu berbentuk "Sama dengan varian standar, dengan <perubahan>, ditambah
     …" (misalnya batas waktu yang lebih pendek): tulis teks standar utuh, lalu satu
     kalimat penegas yang menyebut bagian mana yang berbeda dan angkanya. Jangan sampai
     dua angka bertentangan tanpa kalimat penegas.
   - Varian yang sudah berdiri sendiri disalin apa adanya.
3. **Entri yang membagi teks per wadah** (P-PJ-03: sebagai karyawan atau freelancer):
   tulis hanya kalimat untuk wadah kontrak ini. Kalimat wadah lain dibuang utuh.
4. **Pasal yang dilepas bila brief tidak membutuhkannya** (catat semuanya di CATATAN
   PENYUSUN):
   - Brief: tidak perlu non-kompetisi → lepas P-NK-01, P-NK-02, P-NK-03.
   - **Pihak Kedua belum genap 21 tahun dan belum kawin** (Status kawin di brief) → JANGAN pasang P-NK-01 dan P-NK-03 (pembatasan setelah hubungan berakhir; Art. 1601x(1) mensyaratkan buruh dewasa, dan blok wali bukan penyembuh yang didukung sumber), sekalipun brief memintanya. Lepas keduanya, tulis di CATATAN PENYUSUN bahwa advokat sebaiknya mengonfirmasi pembacaan ini, dan beri tahu Ali. P-NK-02 (selama hubungan berjalan), kerahasiaan, dan HKI tetap dipasang. Yang sudah kawin atau pernah kawin dianggap dewasa: semua klausul NK boleh dipasang.
   - Brief: tidak ada akses data klien → lepas P-DK-01 sampai P-DK-04.
   - Selain itu, setiap slot di template **tetap dipasang**.
5. **Penyesuaian yang boleh pada non-kompetisi** (P-NK-01 sampai 03): kegiatan, lama,
   dan wilayah disesuaikan dengan brief, **tidak boleh melebihi varian ketat**. Kalimat
   tujuan perlindungan rahasia dagang selalu tertulis. Penyesuaian dicatat. Kalimat
   "Pihak Kedua menyatakan telah dewasa menurut hukum dan menandatangani klausul ini secara
   tertulis" hanya benar untuk Pihak Kedua dewasa. Untuk yang belum genap 21 tahun dan belum
   kawin P-NK-01 dan P-NK-03 tidak dipasang sama sekali, jadi kalimat itu dan kalimat
   "persetujuan wali" untuk klausul pasca-kerja tidak pernah ditulis. Kalimat "telah dewasa"
   di pasal lain Lampiran I (bila ada) diganti "Pihak Kedua belum genap 21 (dua puluh satu)
   tahun dan menandatangani dengan persetujuan Wali sebagaimana tertulis pada blok tanda
   tangan wali" hanya bila klausulnya bukan pembatasan pasca-kerja; catat penggantian itu.
6. **Freelancer: tidak boleh ada bahasa hubungan kerja** di kontrak. Teks pustaka
   yang memuatnya diganti tepat begini, dan penggantian dicatat:
   - "hari kerja" → "hari kalender"
   - "baik di dalam maupun di luar jam kerja atau penugasan" → "baik di dalam maupun di luar
     waktu pengerjaan"
   - "masa percobaan, masa uji coba" → "masa uji coba"
   Kata jam kerja, absensi, hari kerja, masa percobaan, cuti, dan lembur tidak boleh ada di
   kontrak freelancer.
7. **Teks pustaka yang memuat wadah lain** (ditemukan e2e; semuanya dicatat di CATATAN PENYUSUN):
   - Entri apa pun yang menyebut daftar wadah ("karyawan PKWT, PKWTT, dan freelancer",
     "(untuk karyawan) atau (untuk freelancer)"): tulis hanya wadah kontrak ini.
   - **PKWT: tidak boleh ada "masa percobaan" di kontrak** (aturan umum: hapus setiap
     kemunculannya di teks pustaka, bukan hanya dua entri di bawah) (Art. 58 UU 13/2003, batal demi
     hukum; gate G1 menahannya). Hapus frasa "termasuk selama masa percobaan bila ada"
     (P-PJ-04 ketat) dan "masa percobaan," dari P-HKI-06 ketat ("masa uji coba atau proyek
     percontohan" tetap).
   - **UMK: satu kalimat verifikasi saja** di Pasal Upah. Kalimat verifikasi di teks P-PJ-04
     ("pada tanggal penandatanganan … dari keputusan Gubernur yang berlaku") **diganti**
     kalimat dari langkah 2 (tanggal ambil dan sumber dari brief). Jangan ada dua kalimat
     verifikasi dengan tanggal atau sumber berbeda.
   - **Perjumpaan utang (P-GR-03) untuk PKWT dan PKWTT:** keluarkan upah, THR, uang kompensasi,
     dan hak wajib lain dari objek perjumpaan (batas potongan upah tidak ada di pustaka);
     tulis kalimat "Perjumpaan tidak dilakukan terhadap upah, tunjangan hari raya, uang
     kompensasi, atau hak lain yang wajib dibayar menurut peraturan". Hanya sisa imbalan non-wajib
     yang boleh diperjumpakan. Catat penyesuaian itu. Freelancer: teks pustaka apa adanya.
   - **Forum sengketa di entri lain (P-RHS-06 dan sejenisnya):** untuk PKWT dan PKWTT
     buang setiap kalimat yang membuka arbitrase atau "alternatif penyelesaian sengketa" bagi
     perselisihan hubungan kerja (P-FS-01: urutannya musyawarah, bipartit, mediasi, PHI, tidak
     diganti arbitrase). Rujuk ke pasal forum kontrak ini saja. Catat penyesuaian itu.
   - **Cabang non-kompetisi yang tidak diminta brief** (misalnya larangan "memiliki
     kepentingan di pihak ketiga") boleh dibuang; kegiatan yang tersisa harus tetap spesifik.
     Catat pembuangannya. Cara bayar (misalnya transfer bank) dari brief boleh ditambahkan
     satu frasa di Pasal Upah.
   - **Non-kompetisi:** penyesuaian kegiatan, lama, wilayah dari brief berlaku untuk **semua**
     entri NK yang dipasang (P-NK-01, 02, 03), bukan hanya P-NK-01. Setiap larangan harus
     menyebut kegiatan, lama, dan wilayah yang spesifik; larangan bersaing selama perjanjian
     (P-NK-02) memakai kegiatan dan wilayah yang sama dengan brief.
   - **Rujukan antar pasal** di teks pustaka ("Pasal Penyelesaian Sengketa", "Pasal Ganti
     Rugi", dll.): ganti dengan **judul pasal yang benar-benar ada** di kontrak ini. Tidak
     boleh ada rujukan yang menggantung.
   - **Pasal 1 dari template** memakai baris dasar template apa adanya (boleh lebih luas dari
     field `Dasar hukum` entrinya), asal id-nya ada di pustaka.
8. **Pustaka tidak punya teks untuk sebuah slot** (id tidak ada, atau entri tidak berlaku
   untuk wadah ini): STOP, jangan mengarang pasal. Katakan id mana yang bermasalah.

## Langkah 4 — baris dasar di bawah setiap pasal

Di bawah **setiap** judul `## Pasal N …`, baris pertama berikutnya adalah:

```
> **Catatan penyusun — dasar:** P-XXX-NN; <dasar hukum>
```

- `P-XXX-NN` adalah id klausul dari slot pasal itu. `<dasar hukum>` disalin **dari
  field `Dasar hukum` entri itu**, kata demi kata. Pasal yang tidak ada di entri tidak
  ditambah.
- Pasal yang berisi teks tetap dari template **dan** satu slot (Upah, Imbalan dan Pajak):
  baris dasar tetap langsung di bawah judul dan memakai id slot-nya; teks tetap
  mengikuti di bawahnya.
- Pasal 1 pada template sudah membawa baris dasarnya; periksa bahwa id-nya ada di pustaka.
- `P-AA-03`, `P-CL-01`, `P-CL-02`: field `Dasar hukum` berisi "hasil riset …, tidak ada
  pasal eksplisit". Salin begitu, jangan diganti pasal.
- Baris dasar dan teks klausul dipisah satu baris kosong. Setiap `## Pasal` punya satu baris
  dasar; jumlah keduanya sama persis.

## Langkah 5 — penomoran

- **Penomoran ulang penuh** setiap kali ada pasal dilepas: `Pasal 1, 2, 3, …` berurutan,
  di kontrak dan di Lampiran I (Lampiran I mulai dari Pasal 1 lagi). Jangan pernah
  `2a.`, `4a.` atau pasal bersisipan: Markdown tidak mendukungnya.
- Rujukan antar pasal ditulis dengan **nama** pasal ("Pasal Ganti Rugi"), seperti di teks
  pustaka, bukan nomor, supaya tidak rusak waktu penomoran berubah. Jika memakai nomor,
  hitung ulang setelah penomoran akhir.

## Langkah 6 — Lampiran I, blok wali, tanda tangan

1. **Lampiran I**: isi `../../templates/lampiran-ip.md` dengan langkah 3 dan 4, lalu
   tempel di tempat `{{LAMPIRAN_I}}` pada kontrak. Berlaku untuk PKWT, PKWTT, dan
   freelancer. Ganti kalimat "Pemilihan varian …" di pembuka dengan kalimat konkret: varian
   mana yang dipakai dan alasannya (ada atau tidak ada akses source code dan data klien).
2. **Blok wali, usia di bawah 21 DAN belum kawin** (KUHPerdata Art. 330; Status kawin dari brief): ganti `{{BLOK_WALI_JIKA_<21}}`
   di **kontrak dan di Lampiran I** dengan:

   ```
   **Mengetahui dan menyetujui**, bahwa Pihak Kedua belum genap 21 (dua puluh satu) tahun, dan Wali menyatakan mengetahui dan menyetujui Perjanjian ini beserta Lampiran I:

   | **WALI PIHAK KEDUA** |
   |:--:|
   | <br><br><br><br> |
   | **<nama wali>**<br>(<hubungan> Pihak Kedua) |
   ```

   Usia 21 ke atas, atau di bawah 21 tetapi sudah kawin atau pernah kawin (dianggap dewasa menurut Art. 330): **hapus** slot itu bersih-bersih, tanpa baris kosong berlebih, tanpa blok wali, dan jangan menulis kalimat "belum genap 21 (dua puluh satu) tahun" apa pun.
3. **Tanda tangan PT**: tabel `INDUSIA` dan `PIHAK KEDUA` dari template diisi nama dan
   jabatan penandatangan dari vault. Dasar kewenangan sudah ada di komparisi (langkah 2).
4. Cek usia terhadap isi: kontrak untuk calon di bawah 21 dan belum kawin tidak boleh memuat
   P-NK-01 atau P-NK-03 atau teks pembatasan pasca-kerja yang setara. Blok wali tidak
   memperbaikinya (gate G4 dan G5 menahannya).

## Langkah 7 — bagian `# CATATAN PENYUSUN`

Isi `{{CATATAN_PENYUSUN}}` di template dengan daftar poin berikut, dalam bahasa Indonesia
gampang. Bagian ini akan dibuang saat PDF dan DOCX dibuat, tetapi **dibaca penelaah
manusia**, jadi lengkap.

1. **Asumsi dan celah**: setiap `[ASUMSI]` di brief yang bukan fakta penentu hukum, setiap
   butir "Hal yang belum diketahui", dan jawaban Ali di `## Tambahan saat draf`.
2. **Penyesuaian oleh penyusun**: pasal yang dilepas, penyesuaian non-kompetisi, penggantian
   kata di kontrak freelancer, tempat tanda tangan dan nomor kontrak yang disusun penyusun.
3. **Dokumen pendukung yang disebut klausul tetapi belum ada**: misalnya surat pernyataan
   penghasilan tunggal (P-PJ-01), daftar Ciptaan Terdahulu (P-HKI-05), pernyataan
   penanganan data klien (P-DK-01), lembar pemahaman keamanan data (P-DK-04).
4. **Tanggal verifikasi**: satu butir `- File hukum yang dirujuk dan tanggal verifikasinya:
   <domain> <verified:>; …` yang memuat **setiap** file `../../references/hukum/*.md` yang
   dipakai (nilai `verified:` dibaca dari frontmatter file itu saat dijalankan, bukan dari
   ingatan). `signing-authority` dan `ketenagakerjaan` selalu ada. Bila wadah PKWT, tambahkan
   peringatan bahwa status UU Ketenagakerjaan baru harus dicek ulang sebelum PKWT
   diterbitkan (butir "Status UU Ketenagakerjaan baru" di `ketenagakerjaan.md`).
5. **Klausul pilihan penyusun yang dasarnya lemah**: baca field `Risiko` setiap klausul yang
   dipasang. Jika `Risiko` memuat tanda dasar lemah ("pilihan penyusun", "desain penyusun",
   "tidak ada pasal", "tidak menemukan", "sumber sekunder", "belum diverifikasi"), tulis
   satu butir: id klausul, nama pasal, dan satu kalimat risikonya. Contohnya selalu ada
   untuk P-AA-03, P-CL-01, P-CL-02, dan P-HKI-04 bila dipasang.
6. **Kontradiksi wadah** (bila brief mencatatnya) dan peringatan bahwa gate G1 yang memutuskan.
7. **Baris terakhir file** (satu baris, persis bentuk ini, dengan `<tanggal>` = tanggal hari
   ini format `YYYY-MM-DD`):

   ```
   <!-- GATE-STATUS -->Draf ini DISUSUN per <tanggal>; status pemeriksaan aturan: menunggu kontrak-gate. Tinjauan advokat disarankan sebelum tanda tangan.
   ```

### Mekanisme GATE-STATUS (satu-satunya)

`kontrak-draft` **tidak boleh** menulis "lolos pemeriksaan aturan": kalimat itu benar hanya
sesudah gate PASS. Draf menulis baris di atas, diawali penanda `<!-- GATE-STATUS -->`.
`kontrak-gate` menganggap baris itu normal, bukan temuan. Setelah ada PASS yang berlaku,
`kontrak-finish` mengganti **seluruh baris** yang berpenanda itu, **pada salinan kerjanya
saja**, dengan:

```
Draf ini lolos pemeriksaan aturan per <reviewed_at dari review.md>. Tinjauan advokat disarankan sebelum tanda tangan.
```

`kontrak.md` tidak diubah oleh `kontrak-finish`, supaya `kontrak_sha256` di `review.md` tetap
cocok. Bagian `# CATATAN PENYUSUN` dibuang dari PDF dan DOCX apa pun penggantinya.

## Langkah 8 — periksa sendiri sebelum berhenti

Jalankan dan perbaiki sampai bersih (semua di folder kerja):

```bash
grep -c '{{' kontrak.md                        # harus 0
grep -ci dijamin kontrak.md                    # harus 0
grep -nE '^[0-9]+[a-z]\. |^## Pasal [0-9]+[a-z]' kontrak.md   # harus kosong
awk '/^## Pasal/{if(h&&!g)print "tanpa dasar: " h; h=$0; g=0; next} /^> \*\*Catatan penyusun — dasar:\*\* P-/{g=1} /^# /{if(h&&!g)print "tanpa dasar: " h; h=""} END{if(h&&!g)print "tanpa dasar: " h}' kontrak.md   # harus kosong
grep -c '^# LAMPIRAN I' kontrak.md             # harus 1
grep -c 'mengetahui dan menyetujui' kontrak.md # 2 bila usia di bawah 21 dan belum kawin, 0 bila tidak
grep -c 'sejak Perjanjian berakhir, Pihak Kedua tidak akan' kontrak.md   # harus 0 bila di bawah 21 dan belum kawin
grep -c 'GATE-STATUS' kontrak.md               # harus 1
grep -c 'lolos pemeriksaan' kontrak.md         # harus 0
```

Freelancer, tambahan (bagian sebelum CATATAN PENYUSUN saja):

```bash
sed '/^# CATATAN PENYUSUN/,$d' kontrak.md | grep -niE 'jam kerja|absensi|hari kerja|masa percobaan|cuti|lembur'   # harus kosong
```

Lalu: setiap id `P-XXX-NN` di baris dasar ada di `../../references/pasal/*.md`; tidak ada
persentase untuk BPJS atau pajak; angka UMK (bila ada) disertai tanggal verifikasi.

## Revisi setelah BLOCKING

Jika `review.md` berstatus BLOCKING: baca tabel temuan, perbaiki **kontrak.md** (tulis ulang
penuh dari template dan pustaka, bukan menambal), dan jangan mengubah fakta di brief demi
meloloskan gate. Temuan yang butuh fakta baru: tanya Ali (aturan 2). Jangan menghapus
pasal wajib untuk menghindari temuan. Setelah itu jalankan langkah 8 lagi.

## Penutup

Tunjukkan ke Ali ringkasan: wadah dan varian yang dipakai (standar atau ketat) dengan
alasannya, jumlah pasal di kontrak dan di Lampiran I, pasal yang dilepas, dan semua
butir CATATAN PENYUSUN yang butuh keputusan manusia. Katakan bahwa draf **belum diperiksa**.

Setelah itu **berhenti**. Arahkan ke `kontrak-gate` (skill berikutnya), yang menulis
`review.md`. Tidak ada PDF atau DOCX sebelum ada PASS yang berlaku (`kontrak-finish`).
