# BRIEF KONTRAK — {{KODE_KONTRAK}}

Dibuat oleh kontrak-brainstorm pada {{TANGGAL_BRIEF}}. Setiap baris fakta berakhir dengan satu tag: `[user]` (dari Ali), `[vault]` (dari catatan vault), `[riset]` (dari references/hukum), atau `[ASUMSI]` (belum dikonfirmasi). `[ASUMSI]` pada fakta yang menentukan hukum membuat gate menolak kontrak.

## Wadah
- Wadah terpilih: {{WADAH}} (PKWT / PKWTT / freelancer) [user]
- Alasan (tiga unsur: pekerjaan, upah, perintah): {{ALASAN_WADAH}} [riset]
- Dasar pemilihan: references/hukum/ketenagakerjaan.md, bagian "Wadah: hubungan kerja atau freelancer" [riset]

## Pihak Pertama (PT)
- Nama, alamat, penandatangan, dan dasar kewenangan diambil dari vault company-legal pada {{TANGGAL_BACA_VAULT}} [vault]
- Penandatangan: {{PT_PENANDATANGAN_NAMA}}, {{PT_PENANDATANGAN_JABATAN}}; dasar kewenangan: {{PT_DASAR_KEWENANGAN}} [vault]

## Pihak Kedua
- Nama lengkap: {{PIHAK_KEDUA_NAMA}} [user]
- Tanggal lahir: {{PIHAK_KEDUA_TANGGAL_LAHIR}}; usia pada tanggal tanda tangan: {{PIHAK_KEDUA_USIA}} [user]
- Status kawin: {{STATUS_KAWIN}} (belum kawin / sudah kawin / pernah kawin; Art. 330 KUHPerdata: belum dewasa = belum genap 21 tahun DAN belum kawin; yang sudah atau pernah kawin dianggap dewasa) [user]
- Jika usia di bawah 21 tahun DAN belum kawin: blok tanda tangan wali "mengetahui dan menyetujui" WAJIB, dan pembatasan pasca-kerja (non-kompetisi, larangan membujuk) tidak dipasang. Wali: {{WALI_NAMA}}, hubungan: {{WALI_HUBUNGAN}}; bila tidak berlaku tulis "tidak berlaku" [user]
- Alamat: {{PIHAK_KEDUA_ALAMAT}} [user]
- Jenis dan nomor identitas: {{PIHAK_KEDUA_JENIS_ID}} {{PIHAK_KEDUA_NO_ID}} [user]
- Punya NPWP: {{PIHAK_KEDUA_NPWP_YA_TIDAK}} [user]

## Pekerjaan
- Jabatan atau peran: {{JABATAN}} [user]
- Hasil kerja yang dibuat: {{HASIL_KERJA}} [user]
- Jam kerja, tempat, alat, dan pengawasan (uji tiga unsur): {{JAM_TEMPAT_ALAT_PENGAWASAN}} [user]
- Tempat pekerjaan (alamat atau lokasi tertulis; wajib untuk PKWT dan PKWTT, PP 35/2021 Art. 13; freelancer: tulis "tidak berlaku"): {{TEMPAT_KERJA}} [user]
- Ringkasan jam kerja dan syarat kerja yang disepakati (PKWT dan PKWTT; freelancer: "tidak berlaku"): {{KONDISI_KERJA}} [user]
- Eksklusivitas dan klien lain: {{EKSKLUSIVITAS}} [user]
- Akses ke source code dan data klien: {{TINGKAT_AKSES}} (akses ada = varian ketat) [user]
- Membuat Hasil Karya milik INDUSIA: {{BUAT_HKI_YA_TIDAK}} [user]
- Ciptaan yang sudah dimiliki sebelum kontrak: {{CIPTAAN_TERDAHULU}} [user]
- Perlu non-kompetisi: {{NK_YA_TIDAK}}; tujuan perlindungan rahasia dagang: {{NK_TUJUAN}} [user]

## Jangka waktu
- Tanggal mulai: {{TANGGAL_MULAI}} [user]
- Tanggal selesai atau penanda selesainya pekerjaan: {{TANGGAL_SELESAI}} [user]
- Alasan PKWT (pekerjaan sementara atau berbasis proyek; bukan pekerjaan tetap): {{ALASAN_PKWT}} [user]

## Imbalan
- Upah atau imbalan per bulan atau per hasil: {{UPAH_POKOK}} [user]
- Tunjangan tetap: {{TUNJANGAN_TETAP}} [user]
- UMK yang dirujuk: nilai {{UMK_NILAI}}, sumber {{UMK_SUMBER}}, diverifikasi pada tanggal {{UMK_TANGGAL_VERIFIKASI}} [riset]

## Hal yang belum diketahui
- {{DAFTAR_YANG_BELUM_DIKETAHUI}}
