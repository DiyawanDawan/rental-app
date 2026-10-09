# Perencanaan Arsitektur & Integrasi API - Modul Address & Geographic Regions v1

Dokumen ini mendefinisikan arsitektur sistem, spesifikasi kontrak API (Backend DTO), desain struktur data, dan panduan integrasi modul Alamat & Wilayah Administratif antara **Backend (Express + Prisma)** dan **Frontend (Flutter `travelindo`)**.

---

## 1. Ringkasan Eksekutif & Konteks Integrasi

### 1.1 Latar Belakang
Backend Travelindo telah menyelesaikan refactor standar V1 pada route [`Backend/src/routes/addresses.ts`](file:///d:/Retal-Apps/Backend/src/routes/addresses.ts), controller [`Backend/src/controllers/address.controller.ts`](file:///d:/Retal-Apps/Backend/src/controllers/address.controller.ts), dan service [`Backend/src/services/address.service.ts`](file:///d:/Retal-Apps/Backend/src/services/address.service.ts) yang mencakup:
1. **Response Envelope & DTO Standar**: Seluruh respon menggunakan format `{ meta: { success, status, message }, data }` dengan struktur data alamat yang telah di-flatten (`countryName`, `provinceName`, `regencyName`, `districtName`, `villageName`).
2. **Unified Regional Lookup**: Endpoint `GET /api/v1/addresses/regions` yang mendukung query cascading bertingkat (`countryId` -> `provinceId` -> `regencyId` -> `districtId`) dengan cache Redis 7 hari.
3. **Validasi Zod Ketat**: Skema validasi UUID, hierarki wilayah administratif, rentang koordinat latitude/longitude, dan validasi kepemilikan data.
4. **CRUD Lengkap User**: Termasuk `GET /my`, `POST /`, `GET /:id`, `PATCH /:id`, dan `DELETE /:id` (dengan proteksi foreign key).

### 1.2 Masalah pada Frontend Saat Ini (`travelindo`)
1. **Model Tidak Cocok (DTO Mismatch)**:
   - File [`lib/features/customer/data/models/address_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/address_model.dart) masih menggunakan field legacy: `name`, `address`, `city`, `province`, `isPrimary`.
   - Field esensial dari backend seperti `countryId`, `countryName`, `regencyId`, `regencyName`, `districtId`, `districtName`, `villageId`, `villageName`, `fullAddress`, `zipCode` belum dipetakan.
2. **Payload Request Tidak Sesuai**:
   - Fungsi `createAddress` di [`lib/features/customer/presentation/pages/address_list_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/address_list_page.dart) mengirimkan `{ 'name': ..., 'address': ... }`. Hal ini menyebabkan request ditolak oleh Backend dengan status `400 Bad Request` (`ID Negara tidak valid` dan `fullAddress: Required`).
3. **Ketiadaan Fitur Cascading Wilayah**:
   - Pengguna belum bisa memilih wilayah bertingkat (Negara -> Provinsi -> Kota/Kabupaten -> Kecamatan -> Desa/Kelurahan).
   - Method `getAddressRegions` di Remote DataSource hanya mengirim parameter `{ search: ... }` yang tidak dikenali backend regional lookup.
4. **Ketiadaan Operasi Detail & Update**:
   - Belum ada method `updateAddress` dan `getAddressById` di `CustomerRemoteDataSource`, `CustomerRepository`, maupun `CustomerService`.
5. **Form UI Kurang Representatif**:
   - Dialog tambah alamat masih menggunakan AlertDialog sederhana yang belum mendukung dropdown bertingkat, validasi komprehensif, dan layout modern sesuai *Travelindo Design System*.

---

## 2. Spesifikasi Kontrak API Backend (Ground Truth)

Semua endpoint beralamat di base URL: `{{AppEnv.apiV1BaseUrl}}` (misal: `http://localhost:3000/api/v1`).

### 2.1 Format Response Envelope
Setiap respon API dibungkus dalam envelope standar:
```json
{
  "meta": {
    "success": true,
    "status": 200,
    "message": "Pesan deskriptif"
  },
  "data": ...
}
```

---

### 2.2 Daftar Endpoint User & Regional

#### A. Unified Regional Lookup (Public / Cached)
Digunakan untuk dropdown bertingkat saat pengguna memilih wilayah alamat.
- **Endpoint**: `GET /addresses/regions`
- **Auth**: Tidak memerlukan autentikasi.
- **Query Parameters**:
  | Query Param | Tipe Data | Keterangan | Respon Yang Dikembalikan |
  | :--- | :--- | :--- | :--- |
  | *(kosong)* | - | Tanpa query | Daftar Negara (`Country[]`) |
  | `countryId` | UUID | ID Negara | Daftar Provinsi dalam Negara tsb (`Province[]`) |
  | `provinceId` | UUID | ID Provinsi | Daftar Kota/Kabupaten dalam Provinsi tsb (`Regency[]`) |
  | `regencyId` | UUID | ID Kota/Kab | Daftar Kecamatan dalam Kota/Kab tsb (`District[]`) |
  | `districtId`| UUID | ID Kecamatan | Daftar Desa/Kelurahan dalam Kec tsb (`Village[]`) |

- **Response Body (`data`)**:
  ```json
  [
    {
      "id": "c1f72b53-4bf0-4ff6-9db4-3ce645c71d02",
      "name": "Indonesia",
      "code": "ID",
      "continent": "Asia"
    }
  ]
  ```
  *(Catatan: Field `type` ('DESA' | 'KELURAHAN') tersedia pada level Village).*

---

#### B. Daftar Alamat Pengguna (Get My Addresses)
- **Endpoint**: `GET /addresses/my`
- **Auth**: Bearer Token (User Login).
- **Response Body (`data`)**: `AddressDto[]`
  ```json
  [
    {
      "id": "a90bb679-b1d5-45ec-9df0-94e8248c8bfa",
      "userId": "92f3e098-9031-4dca-97ce-b6f1315b9c1d",
      "fullAddress": "Jl. MH Thamrin No. 28, RT 01 / RW 05",
      "zipCode": "10350",
      "countryId": "c1f72b53-4bf0-4ff6-9db4-3ce645c71d02",
      "countryName": "Indonesia",
      "provinceId": "d3b07384-d113-4e4e-862c-80d5248888b1",
      "provinceName": "DKI Jakarta",
      "regencyId": "8b082bfb-4770-4f51-9e45-cb3e5a3fe1a2",
      "regencyName": "Jakarta Pusat",
      "districtId": "f7d7301c-d944-4298-8868-8ef73fa6c52a",
      "districtName": "Menteng",
      "villageId": "1b089c89-c43e-46aa-b2b5-555fb7c5b619",
      "villageName": "Gondangdia",
      "latitude": -6.188400,
      "longitude": 106.832700,
      "createdAt": "2026-09-25T05:10:00.000Z",
      "updatedAt": "2026-09-25T05:10:00.000Z"
    }
  ]
  ```

---

#### C. Detail Alamat (Get Address by ID)
- **Endpoint**: `GET /addresses/:id`
- **Auth**: Bearer Token.
- **Parameters**: `id` (UUID).
- **Response Body (`data`)**: `AddressDto` (tunggal).

---

#### D. Tambah Alamat Baru (Create Address)
- **Endpoint**: `POST /addresses`
- **Auth**: Bearer Token.
- **Request Body**:
  ```json
  {
    "countryId": "c1f72b53-4bf0-4ff6-9db4-3ce645c71d02",
    "provinceId": "d3b07384-d113-4e4e-862c-80d5248888b1",
    "regencyId": "8b082bfb-4770-4f51-9e45-cb3e5a3fe1a2",
    "districtId": "f7d7301c-d944-4298-8868-8ef73fa6c52a",
    "villageId": "1b089c89-c43e-46aa-b2b5-555fb7c5b619",
    "fullAddress": "Jl. MH Thamrin No. 28",
    "zipCode": "10350",
    "latitude": -6.1884,
    "longitude": 106.8327
  }
  ```
- **Validasi Backend**:
  - `countryId`: Wajib (UUID).
  - `provinceId`, `regencyId`, `districtId`, `villageId`: Opsional (UUID), tetapi jika diisi harus valid secara hierarki (misal: kecamatan harus berada di dalam kota terkait).
  - `fullAddress`: Wajib (minimal 5 karakter).
  - `latitude`: Rentang -90 s/d 90.
  - `longitude`: Rentang -180 s/d 180.
- **Response Status**: `201 Created` dengan `data: AddressDto`.

---

#### E. Update Alamat (Patch Address)
- **Endpoint**: `PATCH /addresses/:id`
- **Auth**: Bearer Token.
- **Parameters**: `id` (UUID).
- **Request Body**: Parsial dari `CreateAddress` (setidaknya satu field harus diisi).
- **Response Status**: `200 OK` dengan `data: AddressDto`.

---

#### F. Hapus Alamat (Delete Address)
- **Endpoint**: `DELETE /addresses/:id`
- **Auth**: Bearer Token.
- **Parameters**: `id` (UUID).
- **Proteksi Backend**: Menolak penghapusan (status `400`) jika alamat masih menjadi rujukan aktif pada `TravelRoute`, `MitraProfile`, atau transaksi `Booking`.
- **Response Status**: `200 OK` dengan `data: null`.

---

## 3. Desain Arsitektur Frontend Flutter (`travelindo`)

Struktur modul Address akan mengikuti pola Clean Architecture yang sudah ada pada Travelindo (`features/customer/`):

```text
travelindo/lib/features/customer/
├── data/
│   ├── models/
│   │   ├── address_model.dart             <-- [REFACTOR] Flat DTO sesuai backend
│   │   └── region_model.dart              <-- [NEW] Model entitas wilayah hierarki
│   ├── customer_remote_datasource.dart    <-- [REFACTOR] Endpoint update, detail, regions cascade
│   └── customer_repository.dart           <-- [REFACTOR] Tambah kontrak CRUD alamat & wilayah
├── application/
│   └── customer_service.dart              <-- [REFACTOR] State & method reactive manajemen alamat
└── presentation/
    ├── pages/
    │   ├── address_list_page.dart         <-- [REFACTOR] UI daftar alamat modern & card interaktif
    │   └── address_form_page.dart         <-- [NEW] Halaman form create/edit alamat lengkap
    └── widgets/
        ├── address_card.dart              <-- [NEW] Widget kartu alamat elegan dengan detail hierarki
        └── cascading_region_picker.dart   <-- [NEW] Widget modal sheet pemilih wilayah bertingkat
```

---

### 3.1 Desain Model Data (`data/models/`)

#### Model Alamat Baru (`address_model.dart`):
```dart
class AddressModel {
  const AddressModel({
    required this.id,
    required this.userId,
    required this.fullAddress,
    this.zipCode,
    required this.countryId,
    this.countryName,
    this.provinceId,
    this.provinceName,
    this.regencyId,
    this.regencyName,
    this.districtId,
    this.districtName,
    this.villageId,
    this.villageName,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String fullAddress;
  final String? zipCode;
  final String countryId;
  final String? countryName;
  final String? provinceId;
  final String? provinceName;
  final String? regencyId;
  final String? regencyName;
  final String? districtId;
  final String? districtName;
  final String? villageId;
  final String? villageName;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Helper getters untuk tampilan UI
  String get formattedHierarchy {
    final parts = [
      villageName,
      districtName,
      regencyName,
      provinceName,
      countryName,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

#### Model Wilayah (`region_model.dart`):
```dart
class RegionItemModel {
  const RegionItemModel({
    required this.id,
    required this.name,
    this.code,
    this.parentId,
    this.type,
  });

  final String id;
  final String name;
  final String? code;
  final String? parentId;
  final String? type; // 'DESA' | 'KELURAHAN' pada level village

  factory RegionItemModel.fromJson(Map<String, dynamic> json) => ...;
}
```

---

### 3.2 Strategi Caching Data Wilayah (`ReferenceDataCache`)

Data wilayah negara, provinsi, dan kota bersifat sangat statis dan jarang berubah. Untuk memaksimalkan performa dan meminimalkan latensi network:
1. Simpan hasil query wilayah ke dalam `ReferenceDataCache` dengan durasi TTL **7 hari** (sesuai backend `REGIONS_TTL`).
2. Kunci cache disusun berdasarkan parameter hierarki:
   `regions:country:{countryId}:prov:{provId}:reg:{regId}:dist:{distId}`.
3. Saat pengguna membuka dropdown, periksa cache terlebih dahulu. Jika *hit*, render seketika tanpa network spinner.

---

### 3.3 Desain Antarmuka Pengguna (UI/UX Design Guidelines)

Mengikuti panduan palet warna Travelindo (`color-pater.md`):
- **Warna Utama**: Navy `#1E3A5F` untuk Header, Judul, dan App Bar.
- **Warna Aksen / Tindakan**: Orange `#FF6B35` untuk Tombol Utama (CTA "Simpan Alamat", "Tambah Alamat Baru").
- **Warna Pendukung**: Teal `#26A69A` untuk Pin Peta, Lokasi Terpilih, dan Ikon Navigasi.
- **Latar Belakang**: Putih Tulang `#FDFBF7` / Putih Murni `#FFFFFF`.
- **Kartu Alamat**: Menggunakan `AppDecorations.floatingCard()` dengan border halus dan bayangan elegan.
- **Interaksi**:
  - Tombol **"Pilih Lokasi di Peta"**: Membuka `LocationPickerPage`, memanfaatkan GPS / Reverse Geocoding untuk mengisi koordinat dan patokan alamat secara instan.
  - **Cascading Regional Selector**: Dialog modal bottom sheet yang dilengkapi kolom pencarian instan (search filter) untuk memudahkan memilih dari ratusan kota/kecamatan di Indonesia.
  - **Safeguard Hapus**: Dialog konfirmasi peringatan sebelum menghapus alamat.

---

### 3.4 Titik Integrasi Antar-Modul (Cross-Feature Flow)

1. **Alur Pemesanan Rental Kendaraan & Travel (`CreateBookingPage`)**:
   - Memungkinkan pengguna memilih alamat pengantaran/penjemputan kendaraan langsung dari daftar alamat tersimpan miliknya, tanpa perlu mengetik ulang alamat panjang.
2. **Profil Mitra / Toko Rental (`MitraProfilePage`)**:
   - Alamat operasional toko dapat dikaitkan dengan entitas alamat yang terverifikasi secara geografis.

---

## 4. Penanganan Kesalahan (Error Handling & Edge Cases)

| Skenario | Response Code | Tindakan Frontend |
| :--- | :--- | :--- |
| Hierarki wilayah tidak valid | `400 Bad Request` | Tampilkan Snackbar peringatan: *"Kombinasi wilayah tidak valid. Silakan pilih ulang."* |
| Alamat digunakan pada booking aktif | `400 Bad Request` | Tampilkan AlertDialog informatif: *"Alamat tidak dapat dihapus karena masih digunakan pada pesanan aktif."* |
| Alamat tidak ditemukan | `404 Not Found` | Tampilkan state kosong dan arahkan kembali ke daftar alamat. |
| Koneksi internet terputus | `DioException / SocketException` | Tampilkan `AppError` dengan tombol coba lagi (*Retry*). |

---

## 5. Ringkasan & Langkah Selanjutnya

Dokumen ini menjadi acuan spesifikasi teknis untuk mengeksekusi integrasi secara bertahap sesuai checklist pada [`travelindo/docs/TASK_ADDRESSES_V1.md`](file:///d:/Retal-Apps/travelindo/docs/TASK_ADDRESSES_V1.md).
