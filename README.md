# Catatan — Praktikum 2

Aplikasi catatan dasar sesuai Modul Praktikum 2. Pengguna menulis judul dan
isi catatan, melihat daftar, mengetuk catatan untuk mengedit, dan menekan ikon
tempat sampah untuk menghapus langsung.

## Menjalankan

Jalankan dari folder proyek ini dengan HP Android atau emulator Android aktif:

```sh
flutter pub get
flutter devices
flutter run -d <id-perangkat-android>
```

Target pengujian utama: Android. Implementasi `sqflite` ini juga mendukung
iOS/macOS, tetapi tidak menjalankan database di Chrome, Edge, Windows, atau Linux.

## Struktur

```text
lib/
  main.dart                 # Menjalankan aplikasi
  models/note.dart          # Data id, title, content
  db/database_helper.dart   # Membuka database dan operasi CRUD
  screens/home_screen.dart  # Daftar catatan dan hapus
  screens/note_form.dart    # Form tambah/edit dengan validasi
  theme/app_theme.dart      # Warna, tipografi, dan bentuk komponen
```

Database lokal `notes.db` menggunakan tabel `notes` versi 1:

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL
);
```

Catatan terbaru tampil di atas. Data tetap ada setelah aplikasi ditutup.
Menghapus aplikasi atau membersihkan data aplikasi akan menghapus database lokal.
Tahap ini belum mencakup pencarian, konfirmasi hapus, tanggal, kategori,
atau pilihan warna catatan.

## Desain

Arahan UI/UX Pro Max: satu kolom, tipografi jelas, jarak yang cukup, kontrol
sentuh minimal 48 dp. Latar krem dan aksen cokelat memakai tema terang tetap.
Teks antarmuka mengikuti stop-slop: singkat, spesifik, tanpa slogan promosi.
Font menggunakan font bawaan Flutter tanpa unduhan saat aplikasi berjalan.

## Pengujian

```sh
flutter analyze
flutter test
flutter build apk --debug
```

Tes database memakai SQLite lokal melalui `sqflite_common_ffi` sebagai dependensi
pengujian. Tes memeriksa CRUD, urutan catatan, dan data setelah database dibuka
kembali. Tes widget memeriksa alur tambah/edit/hapus, validasi, serta ukuran
layar dan teks besar.

Referensi:
- [Penyimpanan SQLite di Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Validasi form Flutter](https://docs.flutter.dev/cookbook/forms/validation)
