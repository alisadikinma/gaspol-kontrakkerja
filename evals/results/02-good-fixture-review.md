## Verdict: PASS

reviewed_at: 2026-10-03
kontrak_sha256: 6db0c3bbdd6aaba32198c8967fd0adb7ac63572ea9f8aa9c8ff8b831cc0a729e

| Gate | Status | Evidence | Fix |
|---|---|---|---|
| G1 Wadah | PASS | Wadah PKWT sesuai brief. Pasal 1: "bertempat kerja di kantor INDUSIA, Jalan Contoh Nomor 1, Kota Batam"; komparisi: "bergerak di bidang usaha pengembangan perangkat lunak", "berjenis kelamin laki-laki". Tidak ada masa percobaan; pekerjaan "berbasis proyek tersebut"; 12 Oktober 2026 sampai 11 Oktober 2027. | — |
| G2 Dasar hukum | PASS | 37 judul `## Pasal` (15 kontrak + 22 Lampiran I) dan 37 baris "Catatan penyusun — dasar"; semua id P-XXX-NN ada di `references/pasal/*.md`. Pasal 10 menyebut Art. 1307 hanya di baris dasar P-GR-01 (bersama 1309); teks memakai "Pasal 1309 KUH Perdata". | — |
| G3 Jebakan terlarang | PASS | Pasal 9: "INDUSIA tidak akan menahan, menyimpan, atau menjadikan jaminan ijazah, kartu tanda penduduk, paspor"; Pasal 2: "Upah Pihak Kedua tidak lebih rendah dari upah minimum kabupaten atau kota (UMK)", Rp 6.500.000 > UMK Rp 4.000.000 (brief, 2026-10-03); Pasal 4, 5 menjaga BPJS dan uang kompensasi; Pasal 10 batas "1 (satu) bulan upah"; Lampiran Pasal 12 "tidak dibatasi jangka waktu". | — |
| G4 Non-kompetisi | PASS | Lampiran Pasal 13: "Tujuan klausul ini adalah melindungi rahasia dagang INDUSIA"; hanya larangan selama Perjanjian. Tidak ada pembatasan pasca-kerja (P-NK-01/03) untuk Pihak Kedua usia 19 tahun, belum kawin. | — |
| G5 Usia | PASS | Lahir 15 Maret 2007, usia 19 pada 3 Oktober 2026, sama dengan komparisi "berusia 19 tahun"; belum kawin (brief). Blok "Mengetahui dan menyetujui" wali Ani Contoh (ibu kandung) ada di kontrak dan Lampiran I. Tidak ada kalimat "telah dewasa". | — |
| G6 HKI | PASS | Lampiran I ada. Pasal 7 memuat semua butir (a) sampai (m) dan "seluruh proyek, seluruh pelanggan, dan seluruh lini bisnis"; Pasal 8 "mengalihkan"; Pasal 9 "persetujuan ... untuk tidak menggunakan hak moralnya ... bukan pengalihan hak moral"; Pasal 10 konfirmasi pengalihan + lisensi cadangan; Pasal 17 garansi GPL/AGPL. | — |
| G7 Penegakan | PASS | Lampiran Pasal 2: "upaya layak INDUSIA ... Pasal 3 Undang-Undang Nomor 30 Tahun 2000"; Pasal 12: "Pasal 1425 sampai Pasal 1427 KUH Perdata"; Pasal 14: "Pengadilan Hubungan Industrial yang berwenang". | — |
| G8 Angka & kesegaran | PASS | Upah Rp 6.500.000 "sesuai yang disepakati Para Pihak pada tanggal Perjanjian ini"; UMK tanpa angka, "diverifikasi pada tanggal 3 Oktober 2026"; tidak ada persentase BPJS atau pajak. Semua file `references/hukum/*.md` `verified: 2026-10-03` (0 hari), sama dengan CATATAN PENYUSUN. | — |
| G9 Penandatangan | PASS | Komparisi: "Siti Fiktif, selaku Direktur Utama, berdasarkan akta pendirian dan anggaran dasar ... disahkan Menteri Hukum dan HAM serta keputusan RUPS", cocok dengan brief dan `signing-authority.md` (UU 40/2007 Art. 98); identitas Pihak Kedua lengkap (nama, tanggal lahir, KTP, alamat); Pasal 8, 11, 15 berbentuk "ini pemberitahuan, bukan ancaman"; kata "dijamin" tidak ada. | — |

Catatan: PASS hanya berarti pemeriksaan aturan lolos per 2026-10-03, bukan jaminan. Tinjauan advokat disarankan sebelum tanda tangan. Langkah berikutnya `kontrak-finish`.
