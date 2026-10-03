## Verdict: BLOCKING

reviewed_at: 2026-10-03
kontrak_sha256: 1809e3e582fdfb4c555421c264408eeef27f59d8a393ff5d6c23cc65321ccb3d

| Gate | Status | Evidence | Fix |
|---|---|---|---|
| G1 Wadah | BLOCKING | Kontrak Pasal 2 "Pihak Kedua menjalani masa percobaan selama 3 (tiga) bulan sejak mulai bekerja, dan penilaian akhir masa percobaan menentukan kelanjutan Perjanjian ini." Wadah di brief.md = PKWT; masa percobaan dalam PKWT batal demi hukum (Art. 58 UU 13/2003, lihat ketenagakerjaan.md). | Hapus Pasal 2 dari PKWT; jangan diganti dengan penilaian yang menentukan kelanjutan. |
| G2 Dasar hukum | BLOCKING | 39 judul `## Pasal` dan 39 baris dasar, semua id P-XXX-NN ada di references/pasal/. Tetapi Kontrak Pasal 10 Penyimpanan Ijazah bersandar pada P-AA-01 (pengembalian aset, melarang penahanan): "INDUSIA menyimpan ijazah asli Pihak Kedua selama Perjanjian berlaku" melanggar yang dilarang entri itu. | Hapus Pasal 10 atau ganti dengan pasal yang tidak menahan dokumen; jangan bersandar pada id yang melarangnya. |
| G3 Jebakan terlarang | BLOCKING | (a) Kontrak Pasal 10 "INDUSIA menyimpan ijazah asli Pihak Kedua selama Perjanjian berlaku dan mengembalikannya setelah seluruh kewajiban Pihak Kedua kepada INDUSIA selesai." (b) Kontrak Pasal 11 "Pihak Kedua membayar penalti tetap sebesar 12 (dua belas) bulan upah, terlepas dari nilai kerugian nyata." tanpa alasan tertulis pembuktian pengurangan (lebih dari sekitar 1 bulan upah). (c) Lampiran I Pasal 3 "Kewajiban kerahasiaan atas source code berlaku selama 1 (satu) tahun sejak Perjanjian berakhir. Hak INDUSIA untuk memakai, menjual, atau menerbitkan Hasil Karya juga hanya berlaku selama 1 (satu) tahun sejak Perjanjian berakhir." (batas waktu atas source code dan kepemilikan/pemakaian IP). Upah Rp 6.500.000 di atas UMK di brief.md; hak wajib (BPJS Pasal 5, kompensasi Pasal 6) tidak dihapus. | (a) Hapus penahanan ijazah. (b) Turunkan batas sekitar 1 bulan upah atau tulis alasan wajar, batasi pada kerugian nyata; rujuk Art. 1309 KUHPer (perdata.md). (c) Hapus batas waktu pada kerahasiaan source code dan pemakaian Hasil Karya (P-RHS-03, P-HKI-06). |
| G4 Non-kompetisi | PASS | — (Lampiran I Pasal 12, 13, 14 memuat tujuan rahasia dagang/kepentingan bisnis sah, kegiatan, lama, wilayah.) | — |
| G5 Usia | BLOCKING | Lahir 15 Maret 2007, usia 19 pada 3 Oktober 2026 (cocok dengan kontrak, di bawah 21). Tidak ada blok wali "mengetahui dan menyetujui" di kontrak (blok tanda tangan setelah "DEMIKIANLAH PERJANJIAN INI") maupun di Lampiran I (blok tanda tangan terakhir); nama wali Ani Contoh tidak muncul. Lampiran I Pasal 12 "Pihak Kedua menyatakan telah dewasa menurut hukum dan menandatangani klausul ini secara tertulis." bertentangan dengan usia 19 (G5/G1). | Tambah blok wali (nama Ani Contoh, hubungan ibu kandung, "mengetahui dan menyetujui") di kontrak dan Lampiran I; hapus kalimat "telah dewasa menurut hukum". |
| G6 HKI | BLOCKING | Definisi Hasil Karya (Lampiran I Pasal 7) lengkap, pengalihan eksplisit (Pasal 8), hak moral non-assertion (Pasal 9), garansi copyleft (Pasal 18), Lampiran I ada. Tetapi Lampiran I Pasal 3 "Hak INDUSIA untuk memakai, menjual, atau menerbitkan Hasil Karya juga hanya berlaku selama 1 (satu) tahun sejak Perjanjian berakhir." membatasi waktu pemakaian dan bertentangan dengan Pasal 8 "tanpa pembatasan jangka waktu". | Hapus pembatasan waktu pemakaian Hasil Karya (P-HKI-06). |
| G7 Penegakan | PASS | — (Lampiran I Pasal 2 menyebut upaya layak Pasal 3 UU 30/2000; Kontrak Pasal 13 perjumpaan utang Art. 1425; Pasal 15 ke Pengadilan Hubungan Industrial.) | — |
| G8 Angka & kesegaran | BLOCKING | Kontrak Pasal 3 "Upah Pihak Kedua tidak lebih rendah dari upah minimum kabupaten atau kota (UMK) Kota Batam sebesar Rp 4.000.000." Angka UMK tertulis tanpa tanggal verifikasi dan sumber (brief.md sendiri: "Angka UMK tidak ditulis di kontrak"). Semua hukum/*.md verified 2026-10-03 (0 hari, tidak basi). CATATAN PENYUSUN kosong, tanpa tanggal verifikasi. | Hapus angka UMK dari kalimat (rujuk UMK yang berlaku, P-PJ-04) atau sertakan tanggal dan sumber; isi tanggal verifikasi di CATATAN PENYUSUN. |
| G9 Penandatangan | PASS | — (Pembukaan: Siti Fiktif, Direktur Utama, dasar akta pendirian, pengesahan Menteri, keputusan RUPS; identitas Pihak Kedua lengkap; teks pidana Pasal 9, 12, 16 dan Lampiran I Pasal 6, 23 berbentuk pemberitahuan; tidak ada kata "dijamin".) Catatan: penandatangan fiktif sesuai brief fixture. | — |

## Daftar perbaikan

1. Pasal 2, G1: hapus masa percobaan dari PKWT.
2. Pasal 10, G2 dan G3: hapus penahanan ijazah; jangan bersandar pada P-AA-01.
3. Pasal 11, G3: penalti tetap 12 bulan upah tanpa alasan; turunkan sekitar 1 bulan atau tulis alasan, rujuk Art. 1309.
4. Lampiran I Pasal 3, G3 dan G6: hapus batas 1 tahun pada kerahasiaan source code dan pemakaian Hasil Karya.
5. Kontrak dan Lampiran I, G5: tambah blok wali (Ani Contoh, ibu kandung, "mengetahui dan menyetujui"); tanya Ali bila data wali berubah.
6. Lampiran I Pasal 12, G5: hapus "telah dewasa menurut hukum".
7. Pasal 3, G8: hapus angka UMK Rp 4.000.000 atau beri tanggal dan sumber verifikasi; tambah tanggal verifikasi di CATATAN PENYUSUN (tanya Ali untuk tanggal ambil UMK bila perlu).
