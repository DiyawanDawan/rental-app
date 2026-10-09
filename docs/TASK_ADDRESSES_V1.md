# Task Execution Plan - Integrasi Frontend Address & Regional Module v1

Dokumen ini adalah checklist dan panduan teknis langkah demi langkah untuk mengeksekusi integrasi modul Alamat & Wilayah pada aplikasi Flutter **Travelindo** dengan API backend yang telah diperbarui.

Dokumen acuan perencanaan arsitektur: [`travelindo/docs/PLANNING_ADDRESSES_V1.md`](file:///d:/Retal-Apps/travelindo/docs/PLANNING_ADDRESSES_V1.md)

---

## Ringkasan Roadmap & Progress Tracker

- [x] **Fase 1: Standarisasi Model Data & DTO (`lib/features/customer/data/models`)**
- [x] **Fase 2: Pembaruan Remote DataSource & Repository Layer (`customer_remote_datasource.dart` & `customer_repository.dart`)**
- [x] **Fase 3: Regional Caching & State Management (`reference_data_cache.dart` & `customer_service.dart`)**
- [x] **Fase 4: Komponen UI & Cascading Regional Selector (`lib/features/customer/presentation/widgets`)**
- [x] **Fase 5: Pembaruan & Pembuatan Halaman UI Alamat (`address_list_page.dart` & `address_form_page.dart`)**
- [x] **Fase 6: Registrasi Routing & Integrasi Transaksi Pemesanan (`router.dart` & `create_booking_page.dart`)**
- [ ] **Fase 7: Testing, Quality Assurance & Definition of Done (DoD)**

---

## Fase 1: Standarisasi Model Data & DTO

File target:
- [`lib/features/customer/data/models/address_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/address_model.dart)
- [`lib/features/customer/data/models/region_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/region_model.dart) (File Baru)

### Tasks:
- [ ] **1.1. Perbarui `AddressModel` agar Cocok dengan Backend Flat DTO**
  - Ganti field legacy (`name`, `city`, `province`) dengan field backend lengkap:
    - `id`: String (UUID)
    - `userId`: String (UUID)
    - `fullAddress`: String
    - `zipCode`: String?
    - `countryId`: String
    - `countryName`: String?
    - `provinceId`: String?
    - `provinceName`: String?
    - `regencyId`: String?
    - `regencyName`: String?
    - `districtId`: String?
    - `districtName`: String?
    - `villageId`: String?
    - `villageName`: String?
    - `latitude`: double?
    - `longitude`: double?
    - `createdAt`: DateTime?
    - `updatedAt`: DateTime?
  - Tambahkan helper getters:
    - `formattedHierarchy`: Menggabungkan Desa, Kecamatan, Kota, Provinsi, Negara.
    - `hasCoordinates`: Cek apakah `latitude` dan `longitude` tidak null.
  - Perbarui parser `AddressModel.fromJson` dan serializer `toJson`.

- [ ] **1.2. Buat Model Entitas Wilayah `RegionItemModel`**
  - Buat model generik `RegionItemModel` untuk menampung item dropdown wilayah:
    ```dart
    class RegionItemModel {
      final String id;
      final String name;
      final String? code;
      final String? parentId;
      final String? type; // 'DESA' | 'KELURAHAN'
      ...
    }
    ```

- [ ] **1.3. Buat DTO Input untuk Create & Update Alamat**
  - Buat `CreateAddressInput` dan `UpdateAddressInput` untuk memastikan payload yang dikirim ke backend valid dan terstruktur:
    - `countryId` (wajib)
    - `provinceId`, `regencyId`, `districtId`, `villageId` (opsional)
    - `fullAddress` (wajib, min 5 karakter)
    - `zipCode`, `latitude`, `longitude` (opsional)

---

## Fase 2: Pembaruan Remote DataSource & Repository Layer

File target:
- [`lib/features/customer/data/customer_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_remote_datasource.dart)
- [`lib/features/customer/data/customer_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_repository.dart)

### Tasks:
- [ ] **2.1. Refactor `getAddressRegions` di Remote DataSource**
  - Ubah signature agar mendukung parameter cascading:
    ```dart
    Future<ApiResponse<List<RegionItemModel>>> getAddressRegions({
      String? countryId,
      String? provinceId,
      String? regencyId,
      String? districtId,
    });
    ```
  - Parse response menggunakan `RegionItemModel.fromJson`.

- [ ] **2.2. Perbarui `getMyAddresses`**
  - Pastikan deserializer memetakan List of `AddressModel` dengan tepat dari `response.data`.

- [ ] **2.3. Implementasikan `getAddressById`**
  - Panggil `GET /addresses/:id` dan kembalikan `ApiResponse<AddressModel>`.

- [ ] **2.4. Refactor `createAddress`**
  - Kirim payload terstandarisasi (`CreateAddressInput.toJson()`) ke `POST /addresses`.
  - Kembalikan `ApiResponse<AddressModel>` yang dibuat.

- [ ] **2.5. Implementasikan `updateAddress`**
  - Panggil `PATCH /addresses/:id` dengan data parsial.
  - Kembalikan `ApiResponse<AddressModel>`.

- [ ] **2.6. Perbarui `deleteAddress`**
  - Panggil `DELETE /addresses/:id`.
  - Tangani `DioException` 400 dengan pesan error spesifik jika alamat masih memiliki relasi aktif (misal booking aktif).

- [ ] **2.7. Sinkronisasikan Interface & Implementasi di `CustomerRepository`**
  - Tambahkan kontrak method di `CustomerRepository` dan delegasikan ke `CustomerRemoteDataSource`.

---

## Fase 3: Regional Caching & State Management

File target:
- [`lib/core/cache/reference_data_cache.dart`](file:///d:/Retal-Apps/travelindo/lib/core/cache/reference_data_cache.dart)
- [`lib/features/customer/application/customer_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/application/customer_service.dart)

### Tasks:
- [ ] **3.1. Tambahkan Regional Caching pada `ReferenceDataCache`**
  - Tambahkan konstanta TTL `static const regionsTtl = Duration(days: 7);`.
  - Buat method `getRegions(...)` dengan cache key berbasis hierarki:
    `regions:${countryId ?? ''}:${provinceId ?? ''}:${regencyId ?? ''}:${districtId ?? ''}`.

- [ ] **3.2. Integrasikan Alamat ke dalam `CustomerService`**
  - Tambahkan state alamat:
    - `List<AddressModel> _myAddresses = []`
    - `List<AddressModel> get myAddresses => List.unmodifiable(_myAddresses)`
    - `AddressModel? _selectedAddress`
  - Buat action methods dengan reaktivitas `notifyListeners()`:
    - `Future<List<AddressModel>> loadMyAddresses()`
    - `Future<AddressModel?> getAddressById(String id)`
    - `Future<bool> createAddress(Map<String, dynamic> data)`
    - `Future<bool> updateAddress(String id, Map<String, dynamic> data)`
    - `Future<bool> deleteAddress(String id)`
    - `Future<List<RegionItemModel>> fetchRegions(...)`

---

## Fase 4: Komponen UI & Cascading Regional Selector

File target:
- [`lib/features/customer/presentation/widgets/cascading_region_picker.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/widgets/cascading_region_picker.dart) (File Baru)
- [`lib/features/customer/presentation/widgets/address_card.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/widgets/address_card.dart) (File Baru)

### Tasks:
- [ ] **4.1. Buat Widget Pemilih Wilayah Modal `CascadingRegionPicker`**
  - Modal Bottom Sheet dengan kolom pencarian instan (search bar).
  - Menampilkan daftar wilayah secara dinamis dengan scroll halus.
  - Memiliki indikator loading saat memuat data wilayah turunan.
  - Menangani reset otomatis hierarki anak jika entitas induk diganti (misal: jika Provinsi diganti, pilihan Kota/Kecamatan/Desa otomatis di-reset).

- [ ] **4.2. Buat Widget `AddressCard` Elegan**
  - Mengikuti palet warna Travelindo (Navy `#1E3A5F`, Orange `#FF6B35`, Teal `#26A69A`).
  - Menampilkan:
    - Alamat lengkap (`fullAddress`) & kode pos.
    - Hierarki administratif lengkap (Kecamatan, Kota, Provinsi, Negara).
    - Status koordinat GPS (Badge "GPS Terpasang" / Teal Pin).
    - Tombol aksi: Edit (ikon pensil), Hapus (ikon tempat sampah dengan warna merah kritis), dan tombol "Pilih" saat berada di alur booking.

---

## Fase 5: Pembaruan & Pembuatan Halaman UI Alamat

File target:
- [`lib/features/customer/presentation/pages/address_list_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/address_list_page.dart)
- [`lib/features/customer/presentation/pages/address_form_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/address_form_page.dart) (File Baru)

### Tasks:
- [ ] **5.1. Rombak `AddressListPage`**
  - Ganti tampilan list lama dengan `StaggeredListItem` dan `AddressCard` baru.
  - Integrasikan dengan `CustomerService` untuk pull-to-refresh (`RefreshIndicator`).
  - Tampilkan `AppEmptyState` yang bersahabat jika pengguna belum memiliki alamat.
  - Tambahkan Floating Action Button (FAB) atau App Bar Action untuk navigasi ke `AddressFormPage`.
  - Terapkan dialog konfirmasi sebelum menghapus alamat, serta tampilkan SnackBar / AlertDialog ramah bila backend mengembalikan error keterkaitan data (status 400).

- [ ] **5.2. Buat Halaman Lengkap `AddressFormPage`**
  - Mendukung dua mode: **Tambah Alamat Baru** (`address == null`) dan **Edit Alamat** (`address != null`).
  - Formulir input terstruktur:
    1. **Pilih Wilayah Administratif**:
       - Dropdown/Field Negara (default: Indonesia).
       - Dropdown/Field Provinsi.
       - Dropdown/Field Kota / Kabupaten.
       - Dropdown/Field Kecamatan.
       - Dropdown/Field Desa / Kelurahan.
    2. **Detail Alamat & Kode Pos**:
       - Kolom `fullAddress` (Alamat jalan, nomor rumah, RT/RW, patokan) - validasi min 5 karakter.
       - Kolom `zipCode` (Kode pos opsional).
    3. **Penyematan Titik Peta (GPS)**:
       - Tombol terintegrasi ke `LocationPickerPage`.
       - Menampilkan koordinat latitude/longitude terpilih dan pratinjau alamat dari reverse geocode.
    4. **Tombol Simpan (CTA)**:
       - Berwarna Orange Travelindo (`#FF6B35`) dengan loading indicator saat proses kirim data.

---

## Fase 6: Registrasi Routing & Integrasi Transaksi Pemesanan

File target:
- [`lib/config/routes.dart`](file:///d:/Retal-Apps/travelindo/lib/config/routes.dart)
- [`lib/app/router.dart`](file:///d:/Retal-Apps/travelindo/lib/app/router.dart)
- [`lib/features/customer/presentation/pages/create_booking_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/create_booking_page.dart)

### Tasks:
- [ ] **6.1. Daftarkan Rute Form Alamat di `routes.dart` & `router.dart`**
  - Tambahkan konstanta `static const String addressForm = '/addresses/form';` di `AppRoutePaths`.
  - Daftarkan `GoRoute` untuk `addressForm` yang menerima argumen opsional `AddressModel? initialAddress`.

- [ ] **6.2. Integrasikan Alamat Tersimpan ke `CreateBookingPage`**
  - Pada bagian opsi "Pengantaran ke Alamat / Delivery Address", sediakan tombol **"Pilih dari Alamat Tersimpan"**.
  - Saat alamat dipilih, otomatis isi koordinat lat/lng dan alamat lengkap ke alur perhitungan biaya sewa kendaraan.

---

## Fase 7: Testing, Quality Assurance & Definition of Done (DoD)

### Tasks:
- [ ] **7.1. Static Code Analysis & Linting**
  - Jalankan analisis sintaks Dart (`flutter analyze` atau linter analyzer) dan pastikan tidak ada error kompilasi.

- [ ] **7.2. Verifikasi Skenario Integrasi End-to-End (E2E)**
  - [ ] **Skenario 1**: Ambil data wilayah cascading: Tanpa query -> Negara -> Provinsi -> Kota/Kabupaten -> Kecamatan -> Kelurahan.
  - [ ] **Skenario 2**: Tambah alamat baru dengan kombinasi wilayah valid -> pastikan status 201 dan response masuk ke daftar.
  - [ ] **Skenario 3**: Tambah alamat baru dengan hierarki salah (misal kecamatan kota lain) -> pastikan validasi backend 400 ditangani dengan pesan ramah.
  - [ ] **Skenario 4**: Buka halaman daftar alamat (`/addresses`) -> pastikan semua alamat muncul dengan hierarki lengkap (Kecamatan, Kota, Provinsi).
  - [ ] **Skenario 5**: Buka form edit alamat -> ubah alamat lengkap / kode pos -> pastikan status 200 dan data terbarui seketika.
  - [ ] **Skenario 6**: Hapus alamat -> pastikan dialog konfirmasi muncul -> jika dihapus, item hilang dari daftar.
  - [ ] **Skenario 7**: Uji `ReferenceDataCache` -> wilayah yang telah diambil tidak melakukan request ulang ke network (cache hit).

---

## Definition of Done (DoD)

1. Model data alamat frontend 100% selaras dengan skema database dan DTO Backend.
2. Tidak ada error `400 Bad Request` akibat ketidaksesuaian struktur JSON saat create maupun update alamat.
3. Pengguna dapat memilih wilayah secara hierarkis (Negara -> Provinsi -> Kota -> Kecamatan -> Desa).
4. Pengguna dapat menyematkan titik peta GPS melalui integrasi `LocationPickerPage`.
5. Seluruh operasi CRUD (Create, Read, Update, Delete) alamat berfungsi sempurna pada antarmuka frontend.
6. Desain antarmuka mematuhi standar desain Travelindo (Navy, Orange, Teal, Putih tulang).
7. Alur pemesanan (`CreateBookingPage`) dapat memanfaatkan alamat tersimpan pengguna.
