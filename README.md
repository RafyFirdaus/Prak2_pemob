# Aplikasi Catatan

Proyek Praktikum 2 mata kuliah Pemrograman Mobile. Aplikasi ini menggunakan
Flutter dan SQLite untuk menyimpan catatan di perangkat. Pengguna dapat
mengakses catatan tanpa internet dan membukanya kembali setelah menutup aplikasi.

## Fitur

- Menambah catatan berisi judul dan isi.
- Menampilkan daftar catatan, dengan catatan terbaru di atas.
- Mengedit catatan dengan mengetuknya pada daftar.
- Menghapus catatan melalui dialog konfirmasi.
- Mencari catatan berdasarkan judul menggunakan SQL `LIKE`.
- Menampilkan tanggal dan waktu pembuatan catatan.
- Memilih kategori: Umum, Tugas, Kuliah, atau Pribadi.

Setiap kategori memiliki warna penanda. Aplikasi menolak judul dan isi yang kosong.
Untuk catatan lama yang belum memiliki tanggal, aplikasi menampilkan
"Tanggal tidak tersedia".

## Kebutuhan

- Flutter SDK dengan Dart yang sesuai dengan `pubspec.yaml` (Dart ^3.13.5).
- Android SDK.
- Emulator Android atau HP Android dengan USB debugging aktif.

Dependensi utama:

| Package | Kegunaan |
| --- | --- |
| `sqflite` | Menyimpan dan mengelola data SQLite |
| `path` | Menyusun lokasi file database |

## Menjalankan aplikasi

Buka terminal di folder yang berisi `pubspec.yaml`, lalu pasang dependensi:

```sh
flutter pub get
```

Hubungkan HP atau jalankan emulator, lalu lihat perangkat yang tersedia:

```sh
flutter devices
```

Jalankan aplikasi menggunakan ID perangkat Android dari hasil perintah tersebut:

```sh
flutter run -d <id-perangkat>
```

Gunakan perangkat Android untuk menjalankan praktikum ini. Konfigurasi database
proyek belum mendukung Chrome, Edge, Windows, atau Linux.

## Struktur proyek

```text
lib/
  main.dart                  # Entry point aplikasi
  models/
    note.dart                # Model catatan dan konversi data
  db/
    database_helper.dart     # Database, migrasi, dan operasi CRUD
  screens/
    home_screen.dart         # Daftar, pencarian, dan hapus catatan
    note_form.dart           # Form tambah dan edit catatan
  theme/
    app_theme.dart           # Tema dan warna kategori
```

## Database

Aplikasi menyimpan data pada file `notes.db`, menggunakan tabel `notes`
dengan struktur berikut:

| Kolom | Tipe | Keterangan |
| --- | --- | --- |
| `id` | INTEGER | Primary key, bertambah otomatis |
| `title` | TEXT | Judul catatan |
| `content` | TEXT | Isi catatan |
| `created_at` | TEXT | Tanggal dibuat dalam format ISO 8601 |
| `category` | TEXT | Kategori catatan, default `Umum` |

Database menggunakan versi 2. Saat pengguna memperbarui aplikasi dari versi 1,
`onUpgrade` menambahkan kolom `created_at` dan `category` tanpa menghapus catatan.
Catatan lama memiliki tanggal kosong karena versi sebelumnya belum mencatat waktu
pembuatan. Mengedit catatan tidak mengganti tanggal dibuat.

Data tersimpan selama pengguna tidak menghapus data aplikasi atau mencopot aplikasi.

## Pemeriksaan dan build

Periksa kode:

```sh
flutter analyze
```

Buat APK debug untuk pengujian:

```sh
flutter build apk --debug
```

Hasil APK berada di `build/app/outputs/flutter-apk/app-debug.apk`.

Untuk memeriksa penyimpanan, buat catatan lalu tutup dan buka kembali aplikasi.
Coba juga edit catatan, pencarian judul, pilihan kategori, serta tombol Batal dan
Hapus pada dialog konfirmasi.
