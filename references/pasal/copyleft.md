# Pasal: Copyleft dan perangkat lunak sumber terbuka (CL)

Catatan pemakai: UU 28/2014 tidak mengatur open source atau copyleft secara eksplisit (hasil riset ask-hki (e)). Tidak ada dasar undang-undang untuk "garansi kebersihan copyleft"; pasal-pasal di bawah adalah janji kontrak (garansi kontraktual) yang bersandar pada ketentuan umum program komputer dan lisensi, bukan pada pasal yang melarang penggunaan GPL atau AGPL.

Cara baca varian: "Sama dengan varian standar, ditambah ..." berarti varian ketat = isi varian standar utuh + butir tambahan; kontrak-draft menulis keduanya utuh, bukan mengutip kata "sama dengan".

## P-CL-01 Garansi tidak ada komponen GPL atau AGPL tanpa persetujuan
**Dasar hukum:** hasil riset ask-hki (e); UU 28/2014 Art. 1 angka 8, Art. 40(1) huruf s, Art. 80(1)
**Tujuan:** Mencegah kode dengan lisensi copyleft kuat (GPL, AGPL, dan sejenisnya) masuk ke produk INDUSIA atau klien tanpa keputusan sadar, karena lisensi itu dapat memaksa pembukaan source code Hasil Karya.
**Berlaku untuk:** PKWT, PKWTT, FL
**Varian standar:** Pihak Kedua menjanjikan bahwa Hasil Karya tidak memuat, menautkan, atau menyalin komponen yang berlisensi GPL, AGPL, atau lisensi sejenis yang mewajibkan pembukaan source code Hasil Karya atau karya turunannya, kecuali dengan persetujuan tertulis INDUSIA sebelum komponen itu dimasukkan. Janji ini adalah garansi kontraktual antara Para Pihak; undang-undang tidak mengatur kewajiban ini secara khusus. Pihak Kedua wajib memberi tahu INDUSIA sebelum memakai komponen berlisensi selain lisensi permisif yang umum.
**Varian ketat:** Sama dengan varian standar, ditambah: larangan berlaku juga untuk pustaka berlisensi "source-available" atau non-komersial, layanan yang syaratnya melarang pemakaian komersial, dan kode yang dihasilkan alat AI yang syarat pemakaiannya membatasi hak INDUSIA. Pihak Kedua wajib menjalankan pemindaian lisensi yang ditentukan INDUSIA sebelum menyerahkan Hasil Karya dan menyerahkan hasilnya. Komponen yang dimasukkan tanpa persetujuan wajib diganti Pihak Kedua atas biaya sendiri dalam waktu yang ditetapkan INDUSIA.
**Pengecualian wajib:** Komponen yang disetujui tertulis oleh INDUSIA, dan komponen berlisensi permisif (misalnya MIT, BSD, Apache) yang dicatat dalam daftar P-CL-02, tidak dilarang. Klausul tidak boleh dibaca sebagai larangan memakai sumber terbuka secara umum.
**Risiko:** Tidak ada pasal atau putusan yang menyelesaikan akibat copyleft dalam hukum Indonesia; yang ada hanya lisensi (Art. 80(1)). Tanpa garansi kontrak, INDUSIA tidak punya pegangan menuntut Pihak Kedua yang memasukkan komponen terlarang. Garansi ini tidak memberi INDUSIA kepastian bebas copyleft; kewajiban pemeriksaan tetap pada INDUSIA sebelum diserahkan ke klien.
**Verified:** 2026-10-03

## P-CL-02 Daftar lisensi pihak ketiga
**Dasar hukum:** hasil riset ask-hki (e); UU 28/2014 Art. 82 dan Art. 83
**Tujuan:** Memastikan setiap komponen pihak ketiga dalam Hasil Karya tercatat beserta lisensinya, sehingga INDUSIA bisa memenuhi syarat lisensi dan membuktikan asal-usul kode.
**Berlaku untuk:** PKWT, PKWTT, FL
**Varian standar:** Pihak Kedua wajib mencatat setiap pustaka, kerangka kerja, aset, dan potongan kode pihak ketiga yang ia masukkan ke Hasil Karya, termasuk nama, versi, sumber, dan lisensinya, dan menyerahkan catatan itu bersama Hasil Karya. Pihak Kedua wajib mematuhi syarat lisensi komponen itu, termasuk kewajiban menyertakan pemberitahuan hak cipta dan teks lisensi.
**Varian ketat:** Sama dengan varian standar, ditambah: catatan dibuat dalam format yang ditentukan INDUSIA (misalnya daftar komponen perangkat lunak yang dapat dibaca mesin), diperbarui setiap perubahan dependensi, dan Pihak Kedua tidak memasukkan komponen baru ke cabang rilis sebelum dicatat. Pihak Kedua memberi tahu INDUSIA dalam 2 (dua) hari kerja bila suatu komponen diketahui berubah lisensi.
**Pengecualian wajib:** Pustaka standar bahasa pemrograman dan alat bangun yang tidak menjadi bagian Hasil Karya yang diserahkan boleh tidak dicatat. INDUSIA tidak boleh mensyaratkan pencatatan yang tidak bisa dipenuhi secara wajar oleh freelancer berskala kecil tanpa memberi format yang jelas.
**Risiko:** Tanpa catatan, asal-usul kode sulit dibuktikan dan kewajiban atribusi lisensi dilanggar tanpa sengaja. Lisensi yang diberikan lewat perjanjian tertulis tidak boleh mengambil alih seluruh hak pencipta dan harus dicatatkan agar berakibat terhadap pihak ketiga; INDUSIA harus membaca syarat komponen sebelum menyetujuinya. Catatan ini adalah kewajiban kontrak, bukan kewajiban undang-undang.
**Verified:** 2026-10-03
