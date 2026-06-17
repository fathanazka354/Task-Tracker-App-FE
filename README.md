# Task Tracker — Flutter App

Aplikasi Flutter untuk manajemen task sederhana, dibangun dengan **Clean Architecture**, **BLoC** state management, dan **GetIt** dependency injection.

---

## Demo

[Tonton Demo Aplikasi di Google Drive](https://drive.google.com/file/d/1vU3_DdpwQA4HkKoPjL0uNNqtx7iRj0-z/view?usp=share_link)

---

## Daftar Isi

- [Demo](#demo)
- [Cara Menjalankan Project](#cara-menjalankan-project)
- [Architecture Explanation](#architecture-explanation)
- [State Management Explanation](#state-management-explanation)
- [Alasan Memilih Approach Ini](#alasan-memilih-approach-ini)

---

## Cara Menjalankan Project

### Prasyarat

Sebelum menjalankan, pastikan sudah terinstall:

| Tool | Versi | Catatan |
|------|-------|---------|
| Flutter SDK | >= 3.10.0 | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| Dart SDK | >= 3.0.0 | Sudah termasuk dalam Flutter SDK |
| Android Studio | Terbaru | Untuk Android Emulator |
| Xcode | Terbaru | Khusus macOS, untuk iOS Simulator |

Verifikasi instalasi:
```bash
flutter doctor
```

### Langkah 1 — Pastikan Backend Berjalan

App ini membutuhkan backend Golang. Jalankan backend terlebih dahulu (lihat `../backend/README.md`):

```bash
cd ../backend
docker-compose up -d
```

### Langkah 2 — Konfigurasi URL Backend

Buka `lib/core/constants/app_constants.dart` dan sesuaikan `baseUrl` berdasarkan target device:

```dart
// Android Emulator  → http://10.0.2.2:8080/api/v1
// iOS Simulator     → http://localhost:8080/api/v1
// Physical Device   → http://<IP_LOKAL_MAC>:8080/api/v1
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
```

> **Physical device?** Cari IP lokal Mac dengan: `ipconfig getifaddr en0`

### Langkah 3 — Install & Jalankan

```bash
# Masuk ke folder app
cd task-tracker-app/app

# Install semua dependencies
flutter pub get

# Jalankan di device/emulator yang aktif
flutter run
```

#### Menjalankan di Platform Tertentu

```bash
# Android spesifik
flutter run -d android

# iOS spesifik (pastikan Simulator sudah buka)
flutter run -d ios

# Lihat semua device yang tersedia
flutter devices
```

#### Build APK

```bash
# APK debug
flutter build apk --debug

# APK release
flutter build apk --release
```

### Langkah 4 — Jalankan Tests

```bash
# Generate mock files (WAJIB dijalankan sebelum unit test pertama kali)
flutter pub run build_runner build --delete-conflicting-outputs

# Jalankan semua test
flutter test

# Jalankan dengan laporan coverage
flutter test --coverage
```

### Catatan Penting

- Jika terjadi error cache setelah perubahan besar, lakukan **Hot-Restart** (bukan Hot-Reload)
- Jika menambahkan package baru di `pubspec.yaml`, jalankan `flutter pub get` kembali
- Jika mock sudah usang (unit test error), generate ulang dengan `build_runner build`

---

## Architecture Explanation

App ini mengikuti **Clean Architecture** yang memisahkan kode ke dalam 3 layer dengan aturan ketergantungan satu arah — layer luar boleh bergantung ke layer dalam, tapi tidak sebaliknya.

```
┌──────────────────────────────────────┐
│          PRESENTATION LAYER          │
│  BLoC │ Pages │ Widgets              │
│  (Bergantung ke Flutter & domain)    │
├──────────────────────────────────────┤
│            DATA LAYER                │
│  Models │ DataSources │ Repo Impl    │
│  (Bergantung ke domain + packages)   │
├──────────────────────────────────────┤
│           DOMAIN LAYER               │
│  Entities │ Use Cases │ Repo Interface│
│  (Pure Dart — tidak bergantung apapun)│
└──────────────────────────────────────┘
```

### Domain Layer (`lib/domain/`)

**Inti bisnis aplikasi** — tidak bergantung ke Flutter, Dio, SharedPreferences, atau library apapun. Bisa ditest tanpa emulator.

```
domain/
├── entities/
│   ├── task_entity.dart         # TaskEntity, TaskStatus, PaginatedTasks
├── repositories/
│   └── task_repository.dart     # Abstract interface (kontrak akses data)
└── usecases/
    ├── get_tasks_usecase.dart          # Ambil list task dengan pagination
    ├── get_task_detail_usecase.dart    # Ambil satu task by ID
    ├── create_task_usecase.dart        # Buat task baru
    └── update_task_status_usecase.dart # Update status task
```

Setiap use case hanya punya **satu tanggung jawab** dan satu method `call()`:

```dart
class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);

  Future<PaginatedTasks> call(GetTasksParams params) {
    return repository.getTasks(page: params.page, perPage: params.perPage);
  }
}
```

### Data Layer (`lib/data/`)

Mengimplementasikan kontrak dari domain layer. Tahu cara berbicara dengan API dan storage lokal.

```
data/
├── datasources/
│   ├── local/
│   │   └── task_local_datasource.dart   # Cache via SharedPreferences
│   └── remote/
│       └── task_remote_datasource.dart  # HTTP calls via Dio
├── models/
│   ├── task_model.dart                  # TaskModel extends TaskEntity + JSON
│   └── paginated_response_model.dart    # Mapping response API ke PaginatedTasks
└── repositories/
    └── task_repository_impl.dart        # Orchestrasi remote + local
```

**Strategy offline-first di `TaskRepositoryImpl`:**

```dart
Future<PaginatedTasks> getTasks({...}) async {
  try {
    final result = await remoteDataSource.getTasks(...);
    await localDataSource.cacheTasks(result.data); // simpan ke cache
    return result.toEntity();
  } catch (e) {
    if (e is NetworkFailure) {
      final cached = await localDataSource.getCachedTasks();
      if (cached.isNotEmpty) return PaginatedTasks(tasks: cached, ...);
    }
    rethrow;
  }
}
```

### Presentation Layer (`lib/presentation/`)

UI dan state management. Hanya tahu cara menampilkan state dan mendispatch event ke BLoC.

```
presentation/
├── bloc/
│   ├── task_list/     # TaskListBloc + TaskListEvent + TaskListState
│   ├── task_detail/   # TaskDetailBloc + TaskDetailEvent + TaskDetailState
│   └── add_task/      # AddTaskBloc + AddTaskEvent + AddTaskState
├── pages/
│   ├── task_list_page.dart    # Daftar task + infinite scroll + pull-to-refresh
│   ├── task_detail_page.dart  # Detail task + tombol toggle status
│   └── add_task_page.dart     # Form tambah task + validasi
└── widgets/
    ├── task_card.dart          # Card preview task di list
    ├── status_badge.dart       # Badge Done/Pending
    ├── loading_widget.dart     # Spinner dengan optional message
    ├── empty_state_widget.dart # Tampilan saat list kosong
    └── error_state_widget.dart # Tampilan saat terjadi error
```

### Dependency Injection (`lib/core/di/injection.dart`)

Menggunakan **GetIt** sebagai service locator. Semua dependency dideklarasikan di satu tempat:

```dart
// Singleton: satu instance dipakai di seluruh app
sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(...));

// Factory: instance BARU setiap kali diminta
// Penting untuk BLoC supaya tidak ada state bocor antar navigasi
sl.registerFactory(() => TaskListBloc(getTasksUseCase: sl()));
```

---

## State Management Explanation

### BLoC Pattern

BLoC memisahkan **event** (apa yang pengguna lakukan) dari **state** (kondisi UI saat ini).

```
Widget
  │
  │ add(Event)
  ▼
BLoC
  │ emit(State)
  ▼
Widget (rebuild)
```

UI tidak pernah mengubah state langsung — hanya boleh dispatch event. BLoC yang memutuskan state apa yang di-emit sebagai responnya.

### 3 BLoC Independen

Setiap fitur punya BLoC sendiri — tidak ada satu BLoC raksasa yang mengurus segalanya.

#### `TaskListBloc`

Mengurus halaman daftar task.

| Event | Kapan Di-dispatch | State yang Di-emit |
|-------|------------------|-------------------|
| `LoadTasksEvent` | Buka halaman pertama kali | `TaskListLoading` → `TaskListLoaded` atau `TaskListError` |
| `LoadMoreTasksEvent` | Scroll mendekati bawah list | `isLoadingMore: true` → append data ke list |
| `RefreshTasksEvent` | Pull-to-refresh | `TaskListLoaded` baru tanpa loading spinner |
| `TaskStatusUpdatedEvent` | Status berubah dari halaman detail | Update task di list secara optimistis |

#### `TaskDetailBloc`

Mengurus halaman detail task.

| Event | Kapan Di-dispatch | State yang Di-emit |
|-------|------------------|-------------------|
| `LoadTaskDetailEvent` | Buka halaman detail | `TaskDetailLoading` → `TaskDetailLoaded` |
| `ToggleTaskStatusEvent` | Tekan tombol Done/Pending | `isUpdating: true` → `TaskStatusUpdateSuccess` |

#### `AddTaskBloc`

Mengurus form tambah task.

| Event | Kapan Di-dispatch | State yang Di-emit |
|-------|------------------|-------------------|
| `SubmitAddTaskEvent` | Submit form | `AddTaskLoading` → `AddTaskSuccess` atau `AddTaskError` |
| `ResetAddTaskEvent` | Reset form | `AddTaskInitial` |

### Pemetaan State ke UI

Setiap state memetakan ke tampilan yang berbeda secara eksplisit:

```dart
BlocBuilder<TaskListBloc, TaskListState>(
  builder: (context, state) {
    if (state is TaskListLoading) {
      return LoadingWidget(message: 'Loading tasks...');
    }
    if (state is TaskListError && state.cachedTasks.isEmpty) {
      return ErrorStateWidget(message: state.message, onRetry: ...);
    }
    if (state is TaskListLoaded) {
      if (state.tasks.isEmpty) return EmptyStateWidget(...);
      return ListView.builder(...);
    }
    return SizedBox.shrink();
  },
)
```

---

## Alasan Memilih Approach Ini

### Mengapa Clean Architecture?

Tanpa arsitektur yang jelas, logika bisnis akan tercampur di dalam widget. Akibatnya:
- Susah ditest — harus render widget hanya untuk test logika
- Susah di-refactor — perubahan di satu tempat merusak tempat lain
- Susah dikerjakan tim — tidak ada boundary yang jelas

Dengan clean architecture, perubahan di layer data (misalnya ganti library HTTP) tidak menyentuh domain maupun presentation. Setiap layer bisa ditest secara independen.

### Mengapa BLoC, Bukan Provider atau Riverpod?

**Dibandingkan Provider:**  
Provider lebih fleksibel tapi tidak memiliki konvensi yang ketat. BLoC memaksa semua perubahan state lewat event eksplisit — lebih mudah di-debug dan di-trace alur datanya, terutama saat app berkembang.

**Dibandingkan Riverpod:**  
Riverpod sangat powerful tapi memiliki learning curve yang lebih tinggi dan konsep yang lebih abstrak (providers, notifiers, hooks). BLoC lebih verbose tapi lebih linear dan mudah dipahami engineer baru yang bergabung ke project.

**Kelebihan utama BLoC di project ini:**
- Setiap state adalah class → mudah handle semua kondisi di UI (loading, error, empty, loaded)
- `bloc_test` package menyediakan DSL yang sangat bersih: `blocTest('description', build: ..., act: ..., expect: ...)`
- Event tersimpan sebagai history — bisa di-replay untuk debugging

### Mengapa GetIt untuk DI?

GetIt adalah service locator sederhana tanpa code generation. Alternatif seperti `injectable` atau `riverpod` memerlukan setup lebih kompleks.

Perbedaan penting dalam penggunaannya:
- `registerLazySingleton` untuk services yang dibagi (Dio, SharedPreferences, repositories, use cases) — dibuat sekali, dipakai terus
- `registerFactory` untuk BLoC — dibuat baru setiap kali halaman dibuka, menghindari state lama dari sesi navigasi sebelumnya

### Mengapa Dio?

Dio menyediakan interceptor, timeout konfigurasi, dan error handling yang lebih structured dibandingkan `http` package bawaan. LogInterceptor bawaan Dio juga sangat membantu saat debugging — semua request dan response tercetak otomatis di console.
