# Task Tracker App

Task Tracker App adalah aplikasi sederhana untuk manajemen tugas (To-Do List) yang dibangun menggunakan Flutter. Aplikasi ini menggunakan arsitektur Clean Architecture, BLoC pattern untuk state management, dan GetIt untuk dependency injection.

## Persiapan Awal (Prerequisites)

Sebelum menjalankan aplikasi ini, pastikan kamu telah menginstal perangkat lunak berikut di komputer kamu:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stabil terbaru disarankan)
- [Android Studio](https://developer.android.com/studio) (Untuk menjalankan di Android Emulator)
- [Xcode](https://developer.apple.com/xcode/) (Hanya untuk pengguna macOS, jika ingin menjalankan di iOS Simulator)
- Pastikan semua dependensi Flutter sudah berstatus "hijau" dengan menjalankan perintah:
  ```bash
  flutter doctor
  ```

## Cara Menjalankan Projek

1. **Clone repositori** atau pastikan kamu berada di direktori aplikasi:
   ```bash
   cd task-tracker-app/app
   ```

2. **Unduh semua dependensi paket (libraries)** yang dibutuhkan oleh proyek ini:
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi:**
   Pastikan kamu telah menjalankan Emulator Android atau iOS Simulator, ataupun menyambungkan perangkat fisik (HP) via kabel USB/Wi-Fi Debugging.
   
   Untuk menjalankan aplikasi pada perangkat atau emulator yang aktif, jalankan:
   ```bash
   flutter run
   ```

### Menjalankan di Platform Spesifik (Jika ada banyak device aktif)

- **Android:**
  ```bash
  flutter run -d android
  ```

- **iOS:**
  Jika ini pertama kalinya kamu menjalankan di iOS, buka folder ios dan instal pod-nya:
  ```bash
  cd ios
  pod install
  cd ..
  flutter run -d ios
  ```

## Struktur Projek

Projek ini menerapkan konsep Clean Architecture:
- `lib/core/` : Berisi komponen-komponen dasar seperti DI (Dependency Injection), konstanta, tema aplikasi, dan utilitas.
- `lib/data/` : Menangani proses pengambilan data (API, lokal/SharedPreferences, dan implementasi repository).
- `lib/domain/` : Merupakan core business logic (Use Cases, Entities, dan abstrak repository).
- `lib/presentation/` : Menangani UI, state management (BLoC), widgets, dan pages.

## Catatan

- Jika kamu menambahkan package baru di `pubspec.yaml`, jangan lupa jalankan `flutter pub get` lagi.
- Jika terjadi error pada cache provider, disarankan melakukan _Hot-Restart_ bukan sekadar _Hot-Reload_.
