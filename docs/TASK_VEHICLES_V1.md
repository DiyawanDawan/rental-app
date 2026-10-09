# Task Execution Plan - Integrasi Modul Kendaraan / Armada (Customer & Mitra) v1

Dokumen ini adalah checklist dan panduan teknis langkah demi langkah (*step-by-step execution plan*) untuk mengeksekusi integrasi dan sinkronisasi modul Kendaraan (*Vehicles & Fleet Management*) antara Backend Express ([`Backend/src/routes/vehicles.ts`](file:///d:/Retal-Apps/Backend/src/routes/vehicles.ts)) dan Frontend Mobile Flutter ([`travelindo/lib/features/`](file:///d:/Retal-Apps/travelindo/lib/features/)).

> [!NOTE]
> Dokumen acuan perencanaan arsitektur: [`travelindo/docs/PLANNING_VEHICLES_V1.md`](file:///d:/Retal-Apps/travelindo/docs/PLANNING_VEHICLES_V1.md)

---

## Ringkasan Roadmap & Progress Tracker

- [x] **Fase 1: Enum & Data Layer — Model DTO (Customer & Mitra)** ✅
- [x] **Fase 2: Fix Kritis Availability Calendar & Status Armada** ✅
- [x] **Fase 3: Endpoint Constants & Remote Data Source** ✅
- [x] **Fase 4: Repository, Service & State Management Layer** ✅
- [x] **Fase 5: Peningkatan Form, UI & Presentation Layer** ✅ *(5.1–5.3 done; 5.4 pending)*
- [ ] **Fase 6: Verifikasi Integrasi, Static Analysis & Definition of Done**

---

## Fase 1: Enum & Data Layer — Model DTO

File target:
- [`travelindo/lib/features/mitra/data/models/vehicle_enums.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/models/vehicle_enums.dart) *(File baru)*
- [`travelindo/lib/features/customer/data/models/vehicle_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/vehicle_model.dart) *(Refactoring)*
- [`travelindo/lib/features/customer/data/models/vehicle_blocked_date_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/vehicle_blocked_date_model.dart) *(File baru)*
- [`travelindo/lib/features/mitra/data/models/vehicle_input_dto.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/models/vehicle_input_dto.dart) *(File baru)*
- [`travelindo/lib/features/mitra/data/models/mitra_vehicle_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/models/mitra_vehicle_model.dart) *(Update field)*

### Tasks:

- [ ] **1.1. Buat File Enum Bertipe Kuat `vehicle_enums.dart`**
  - Buat file `lib/features/mitra/data/models/vehicle_enums.dart`.
  - Definisikan empat enum: `VehicleStatusEnum`, `VehicleTypeEnum`, `TransmissionTypeEnum`, `RentalTypeEnum`.
  - Setiap enum harus punya field `value` (string sama persis dengan Prisma enum), `label` (bahasa Indonesia), dan factory method `fromString(String? val)`.
  - **Poin Kritis**: `VehicleStatusEnum` harus memiliki nilai `pendingApproval` dengan value `'PENDING_APPROVAL'` (underscore, bukan spasi).
  ```dart
  enum VehicleStatusEnum {
    available('AVAILABLE', 'Aktif & Tersedia'),
    unavailable('UNAVAILABLE', 'Nonaktif'),
    maintenance('MAINTENANCE', 'Dalam Perawatan'),
    pendingApproval('PENDING_APPROVAL', 'Menunggu Verifikasi');

    const VehicleStatusEnum(this.value, this.label);
    final String value;
    final String label;

    bool get isOperational => this == VehicleStatusEnum.available;

    static VehicleStatusEnum fromString(String? val) =>
      VehicleStatusEnum.values.firstWhere(
        (e) => e.value == val,
        orElse: () => VehicleStatusEnum.unavailable,
      );
  }
  ```

- [ ] **1.2. Buat Model Kalender Blocked `VehicleBlockedDateModel`**
  - Buat file `lib/features/customer/data/models/vehicle_blocked_date_model.dart`.
  - Parse field `blockedDate` dari ISO 8601 string ke `DateTime` dengan `DateTime.tryParse`.
  - Sediakan getter `dateString` yang mengembalikan format `YYYY-MM-DD`.
  ```dart
  class VehicleBlockedDateModel {
    const VehicleBlockedDateModel({required this.blockedDate, this.reason});
    final DateTime blockedDate;
    final String? reason;
    String get dateString => blockedDate.toIso8601String().split('T')[0];

    factory VehicleBlockedDateModel.fromJson(Map<String, dynamic> json) {
      final rawDate = json['blockedDate']?.toString() ?? '';
      return VehicleBlockedDateModel(
        blockedDate: DateTime.tryParse(rawDate) ?? DateTime.now(),
        reason: json['reason']?.toString(),
      );
    }
  }
  ```

- [ ] **1.3. Refactoring `VehicleModel` Customer — Tambahkan Field yang Hilang**
  - Edit [`travelindo/lib/features/customer/data/models/vehicle_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/vehicle_model.dart).
  - Tambahkan field yang hilang ke constructor dan `fromJson`:
    ```dart
    // Field baru yang wajib ditambahkan:
    final int? year;
    final String? licensePlate;
    final String? color;
    final int? seatingCapacity;
    final double? priceWithDriver;
    final double? priceFullPackage;
    final double? depositAmount;
    final String? rentalType;     // default: 'RENTAL'
    final String? status;         // default: 'AVAILABLE'
    final String? fuelType;
    final List<Map<String, dynamic>> amenities; // default: const []
    ```
  - Perbarui `VehiclePhotoModel.fromJson` untuk juga membaca field `id` dan `caption`.
  - Tambahkan helper getters:
    - `List<String> get allPhotoUrls` — mengembalikan seluruh URL foto untuk galeri.
    - `bool get hasDriverOption` — `priceWithDriver != null && priceWithDriver! > 0`.
    - `bool get hasFullPackage` — `priceFullPackage != null && priceFullPackage! > 0`.
    - `bool get isAvailable` — `status == 'AVAILABLE'`.

- [ ] **1.4. Buat Input DTO Armada `VehicleInputDto`**
  - Buat file `lib/features/mitra/data/models/vehicle_input_dto.dart`.
  - Sediakan method `toJson()` yang hanya menyertakan field opsional jika nilainya tidak null/kosong.
  ```dart
  class VehicleInputDto {
    const VehicleInputDto({
      required this.name, required this.brand, required this.model,
      required this.type, required this.year, required this.transmission,
      required this.licensePlate, required this.color,
      required this.seatingCapacity, required this.pricePerDay,
      this.rentalType = 'RENTAL', this.isInstantBooking = false,
      this.priceWithDriver, this.priceFullPackage, this.depositAmount, this.description,
    });
    // ... field declarations ...

    Map<String, dynamic> toJson() => {
      'name': name, 'brand': brand, 'model': model, 'type': type, 'year': year,
      'transmission': transmission, 'licensePlate': licensePlate,
      'color': color, 'seatingCapacity': seatingCapacity, 'pricePerDay': pricePerDay,
      'rentalType': rentalType, 'isInstantBooking': isInstantBooking,
      if (priceWithDriver != null && priceWithDriver! > 0) 'priceWithDriver': priceWithDriver,
      if (priceFullPackage != null && priceFullPackage! > 0) 'priceFullPackage': priceFullPackage,
      if (depositAmount != null && depositAmount! >= 0) 'depositAmount': depositAmount,
      if (description != null && description!.trim().isNotEmpty) 'description': description!.trim(),
    };
  }
  ```

- [ ] **1.5. Update `MitraVehicleModel` — Perbaiki Field Kapasitas**
  - Edit [`travelindo/lib/features/mitra/data/models/mitra_vehicle_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/models/mitra_vehicle_model.dart).
  - Hapus field `@Default(0) int capacity` yang ambigu. Pertahankan hanya `int? seatingCapacity`.
  - Tambahkan `String? rentalType` dan `@Default(false) bool isInstantBooking`.
  - Jalankan `flutter pub run build_runner build --delete-conflicting-outputs` untuk regenerasi file `.g.dart` dan `.freezed.dart`.

---

## Fase 2: Fix Kritis — Availability Calendar & Status Armada

File target:
- [`travelindo/lib/features/customer/presentation/widgets/vehicle_availability_calendar.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/widgets/vehicle_availability_calendar.dart)
- [`travelindo/lib/features/mitra/presentation/pages/mitra_vehicles_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicles_page.dart)

### Tasks:

- [ ] **2.1. Fix Bug Kalender — Parse `VehicleBlockedDateModel` dengan Benar**
  - Edit [`vehicle_availability_calendar.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/widgets/vehicle_availability_calendar.dart).
  - Ubah `_availabilityFuture` dari `Future<List<String>>` menjadi `Future<List<VehicleBlockedDateModel>>`.
  - Panggil `CustomerService.getVehicleAvailability` yang mengembalikan `Future<List<VehicleBlockedDateModel>>` (lihat Fase 3.1).
  - Di `_CalendarGrid`, ubah perbandingan tanggal dari `unavailableDates.contains(dateStr)` menjadi `blockedDates.any((b) => b.dateString == dateStr)`.
  - Tambahkan tooltip/dialog alasan jika user mengetuk tanggal blocked:
    ```dart
    // Di _CalendarGrid, bungkus setiap Cell dengan GestureDetector
    GestureDetector(
      onTap: isUnavailable
        ? () {
            final entry = blockedDates.firstWhere((b) => b.dateString == dateStr);
            if (entry.reason != null && entry.reason!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tidak tersedia: ${entry.reason}')),
              );
            }
          }
        : null,
      child: Text(day.toString(), ...),
    )
    ```

- [ ] **2.2. Fix Bug Fatal Status Armada — Ganti String `'ACTIVE'`/`'INACTIVE'` dengan Enum**
  - Edit [`mitra_vehicles_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicles_page.dart).
  - Ubah seluruh referensi string hardcoded ke nilai enum:
    ```dart
    // SEBELUM (SALAH):
    value: vehicle.status == 'ACTIVE',
    onChanged: (value) {
      service.updateVehicleStatus(vehicle.id, value ? 'ACTIVE' : 'INACTIVE');
    }

    // SESUDAH (BENAR):
    value: VehicleStatusEnum.fromString(vehicle.status).isOperational,
    onChanged: (value) {
      service.updateVehicleStatus(
        vehicle.id,
        value ? VehicleStatusEnum.available.value : VehicleStatusEnum.unavailable.value,
      );
    }
    ```
  - Ubah badge status armada (`ActiveStatusBadge`) untuk menampilkan label dan warna berdasarkan `VehicleStatusEnum`:
    ```dart
    // Gunakan StatusBadge generik yang mendukung semua 4 status
    final statusEnum = VehicleStatusEnum.fromString(vehicle.status);
    StatusBadge(
      label: statusEnum.label,
      color: _statusColor(statusEnum),
    )

    Color _statusColor(VehicleStatusEnum s) => switch (s) {
      VehicleStatusEnum.available => AppColors.emerald,
      VehicleStatusEnum.maintenance => AppColors.amber,
      VehicleStatusEnum.pendingApproval => AppColors.sky,
      VehicleStatusEnum.unavailable => AppColors.neutral,
    };
    ```

---

## Fase 3: Endpoint Constants & Remote Data Source

File target:
- [`travelindo/lib/core/network/api_endpoints.dart`](file:///d:/Retal-Apps/travelindo/lib/core/network/api_endpoints.dart)
- [`travelindo/lib/features/customer/data/customer_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_remote_datasource.dart)
- [`travelindo/lib/features/mitra/data/mitra_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_remote_datasource.dart)

### Tasks:

- [ ] **3.1. Pastikan Konstanta URL di `ApiEndpoints` Lengkap**
  - Verifikasi endpoint berikut sudah ada di [`api_endpoints.dart`](file:///d:/Retal-Apps/travelindo/lib/core/network/api_endpoints.dart):
    ```dart
    // Vehicles (sudah ada — verifikasi):
    static const String vehicles = '/vehicles';
    static const String mitraVehicles = '/vehicles/mitra/vehicles';
    static String vehicleById(String id) => '/vehicles/$id';
    static String vehicleAvailability(String id) => '/vehicles/$id/availability';
    static String vehicleStatus(String id) => '/vehicles/$id/status';
    static String vehicleRestore(String id) => '/vehicles/$id/restore';
    static String vehiclePhotos(String id) => '/vehicles/$id/photos';
    static String vehiclePhotoRegister(String id) => '/vehicles/$id/photos/register';
    static String vehiclePhotoById(String vehicleId, String photoId) =>
        '/vehicles/$vehicleId/photos/$photoId';
    static String vehiclePricing(String id) => '/vehicles/$id/pricing';
    static String vehicleBlockedDates(String id) => '/vehicles/$id/blocked-dates';
    static const String vehicleFavorites = '/vehicles/favorites';
    static String vehicleFavorite(String id) => '/vehicles/$id/favorite';
    ```
  - Tambahkan jika ada yang kurang.

- [ ] **3.2. Update `CustomerRemoteDataSource.getVehicles` — Parameter Baru**
  - Edit signature method `getVehicles` di [`customer_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_remote_datasource.dart).
  - Tambahkan parameter yang sebelumnya hilang:
    ```dart
    Future<PaginatedResponse<VehicleModel>> getVehicles({
      String? search, String? type, String? brand, String? transmission,
      String? sort, String? rentalType, String? regencyId,
      bool? isInstantBooking, bool? withDriver,
      double? minPrice, double? maxPrice, double? minRating,
      List<String>? amenityIds,
      String? dateStart, String? dateEnd,    // ← filter ketersediaan
      double? lat, double? lng, double? radiusKm,
      int page = 1, int limit = 10,
    }) async {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.vehicles,
        queryParameters: {
          'page': page, 'limit': limit,
          if (search?.isNotEmpty == true) 'search': search,
          if (type?.isNotEmpty == true) 'type': type,
          if (brand?.isNotEmpty == true) 'brand': brand,
          if (transmission?.isNotEmpty == true) 'transmission': transmission,
          if (sort?.isNotEmpty == true) 'sort': sort,
          if (rentalType?.isNotEmpty == true) 'rentalType': rentalType,
          if (regencyId?.isNotEmpty == true) 'regencyId': regencyId,
          if (isInstantBooking != null) 'isInstantBooking': isInstantBooking.toString(),
          if (withDriver != null) 'withDriver': withDriver.toString(),
          if (minPrice != null) 'minPrice': minPrice.round(),
          if (maxPrice != null) 'maxPrice': maxPrice.round(),
          if (minRating != null) 'minRating': minRating,
          if (amenityIds?.isNotEmpty == true) 'amenityIds': amenityIds!.join(','),
          if (dateStart?.isNotEmpty == true) 'dateStart': dateStart,
          if (dateEnd?.isNotEmpty == true) 'dateEnd': dateEnd,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (radiusKm != null) 'radiusKm': radiusKm,
        },
      );
      return PaginatedResponse<VehicleModel>.fromJson(
        response.data ?? {},
        (json) => VehicleModel.fromJson(json as Map<String, dynamic>),
      );
    }
    ```

- [ ] **3.3. Fix `CustomerRemoteDataSource.getVehicleAvailability` — Parse ke `VehicleBlockedDateModel`**
  - Edit method `getVehicleAvailability` di [`customer_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_remote_datasource.dart).
  - Ubah tipe kembalian dari `ApiResponse<List<String>>` ke `ApiResponse<List<VehicleBlockedDateModel>>`.
  ```dart
  Future<ApiResponse<List<VehicleBlockedDateModel>>> getVehicleAvailability(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vehicleAvailability(id),
    );
    return ApiResponse<List<VehicleBlockedDateModel>>.fromJson(
      response.data ?? {},
      (json) => (json as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleBlockedDateModel.fromJson)
          .toList(),
    );
  }
  ```

- [ ] **3.4. Update `MitraRemoteDataSource.getVehicles` — Gunakan `PaginatedResponse` + Query Params**
  - Edit method `getVehicles` di [`mitra_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_remote_datasource.dart).
  - Tambahkan parameter filter dan ubah tipe kembalian ke `PaginatedResponse<MitraVehicleModel>`:
  ```dart
  Future<PaginatedResponse<MitraVehicleModel>> getVehicles({
    String? status, String? type, String? search,
    int page = 1, int limit = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraVehicles,
      queryParameters: {
        'page': page, 'limit': limit,
        if (status?.isNotEmpty == true) 'status': status,
        if (type?.isNotEmpty == true) 'type': type,
        if (search?.isNotEmpty == true) 'search': search,
      },
    );
    return PaginatedResponse<MitraVehicleModel>.fromJson(
      response.data ?? {},
      (json) => MitraVehicleModel.fromJson(json as Map<String, dynamic>),
    );
  }
  ```

- [ ] **3.5. Tambahkan Method `restoreVehicle` di `MitraRemoteDataSource`**
  - Tambahkan method baru di [`mitra_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_remote_datasource.dart):
  ```dart
  Future<ApiResponse<void>> restoreVehicle(String id) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.vehicleRestore(id),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? {},
      (_) {},
    );
  }
  ```

- [ ] **3.6. Update `MitraRemoteDataSource.setVehicleBlockedDates` — Tambahkan `reason`**
  - Edit method `setVehicleBlockedDates` di [`mitra_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_remote_datasource.dart).
  - Tambahkan parameter `reason`:
  ```dart
  Future<ApiResponse<void>> setVehicleBlockedDates(
    String id,
    List<String> dates, {
    String? reason,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.vehicleBlockedDates(id),
      data: {
        'blockedDates': dates,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return ApiResponse<void>.fromJson(response.data ?? {}, (_) {});
  }
  ```

---

## Fase 4: Repository, Service & State Management Layer

File target:
- [`travelindo/lib/features/customer/data/customer_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_repository.dart)
- [`travelindo/lib/features/customer/application/customer_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/application/customer_service.dart)
- [`travelindo/lib/features/mitra/data/mitra_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_repository.dart)
- [`travelindo/lib/features/mitra/application/mitra_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/application/mitra_service.dart)

### Tasks:

- [ ] **4.1. Update `CustomerRepository.getVehicles` — Tambah Parameter Baru**
  - Edit [`customer_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_repository.dart).
  - Mirror semua parameter baru dari `CustomerRemoteDataSource.getVehicles` (Fase 3.2).

- [ ] **4.2. Update `CustomerRepository.getVehicleAvailability` — Tipe Return Baru**
  - Ubah tipe kembalian dari `Future<ApiResponse<List<String>>>` ke `Future<ApiResponse<List<VehicleBlockedDateModel>>>`.

- [ ] **4.3. Update `CustomerService.getVehicleAvailability`**
  - Edit method `getVehicleAvailability` di `customer_service.dart`.
  - Ubah tipe kembalian dari `Future<List<String>>` ke `Future<List<VehicleBlockedDateModel>>`.
  ```dart
  Future<List<VehicleBlockedDateModel>> getVehicleAvailability(String vehicleId) async {
    final response = await _repository.getVehicleAvailability(vehicleId);
    return response.data ?? [];
  }
  ```

- [ ] **4.4. Update `MitraRepository.getVehicles` — Sinkron Tipe `PaginatedResponse`**
  - Edit [`mitra_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_repository.dart).
  - Ubah signature method `getVehicles` agar menerima parameter filter dan mengembalikan `PaginatedResponse<MitraVehicleModel>`.

- [ ] **4.5. Tambah Method `restoreVehicle` di `MitraRepository`**
  ```dart
  Future<ApiResponse<void>> restoreVehicle(String id) =>
      _remoteDataSource.restoreVehicle(id);
  ```

- [ ] **4.6. Update `MitraRepository.setVehicleBlockedDates` — Tambah `reason`**
  - Teruskan parameter `reason` ke remote data source.

- [ ] **4.7. Update `MitraService.loadVehicles` — Gunakan `PaginatedResponse`**
  - Edit method `loadVehicles` di [`mitra_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/application/mitra_service.dart).
  - Tambahkan dukungan filter dan ubah logic penanganan paginated response:
  ```dart
  Future<void> loadVehicles({
    String? status, String? type, String? search,
    int page = 1, int limit = 20,
  }) async {
    _setLoading();
    try {
      final response = await _repository.getVehicles(
        status: status, type: type, search: search,
        page: page, limit: limit,
      );
      _vehicles = response.data;
      _message = response.meta?.message;
      _setIdle();
    } catch (e) {
      _setError(e.toString());
    }
  }
  ```

- [ ] **4.8. Tambah Method `restoreVehicle` di `MitraService`**
  ```dart
  Future<bool> restoreVehicle(String id) async {
    _setLoading();
    try {
      final response = await _repository.restoreVehicle(id);
      final success = response.meta?.success == true;
      if (success) await loadVehicles();
      _setIdle();
      return success;
    } catch (e) {
      _lastFailure = Failure.fromException(e);
      _setError(e.toString());
      return false;
    }
  }
  ```

- [ ] **4.9. Update `MitraService.setVehicleBlockedDates` — Tambah Parameter `reason`**
  ```dart
  Future<bool> setVehicleBlockedDates(
    String id,
    List<String> dates, {
    String? reason,
  }) async {
    _setLoading();
    try {
      final response = await _repository.setVehicleBlockedDates(id, dates, reason: reason);
      final success = response.meta?.success == true;
      if (success) await loadVehicles();
      _setIdle();
      return success;
    } catch (e) {
      _lastFailure = Failure.fromException(e);
      _setError(e.toString());
      return false;
    }
  }
  ```

---

## Fase 5: Peningkatan Form, UI & Presentation Layer

File target:
- [`travelindo/lib/features/mitra/presentation/pages/mitra_vehicle_form_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicle_form_page.dart)
- [`travelindo/lib/features/mitra/presentation/pages/mitra_vehicle_blocked_dates_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicle_blocked_dates_page.dart)
- [`travelindo/lib/features/customer/presentation/pages/vehicle_detail_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/vehicle_detail_page.dart)

### Tasks:

- [ ] **5.1. Perbaiki Form Tambah/Edit Armada Mitra — Field Bisnis**
  - Edit [`mitra_vehicle_form_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicle_form_page.dart).
  - Tambahkan state dan controller baru:
    ```dart
    String _rentalType = 'RENTAL';
    bool _isInstantBooking = false;
    final _driverPriceController = TextEditingController();
    final _fullPackagePriceController = TextEditingController();
    final _depositController = TextEditingController();
    ```
  - Tambahkan Widget UI di dalam form:
    1. **Segmented Button Tipe Sewa**:
       ```dart
       SegmentedButton<String>(
         segments: const [
           ButtonSegment(value: 'RENTAL', label: Text('Lepas Kunci')),
           ButtonSegment(value: 'SHUTTLE', label: Text('Shuttle')),
           ButtonSegment(value: 'BOTH', label: Text('Keduanya')),
         ],
         selected: {_rentalType},
         onSelectionChanged: (v) => setState(() => _rentalType = v.first),
       )
       ```
    2. **Switch Instant Booking** dengan tooltip penjelasan:
       ```dart
       SwitchListTile(
         title: const Text('Pemesanan Instan'),
         subtitle: const Text('Customer bisa memesan tanpa persetujuan manual'),
         value: _isInstantBooking,
         onChanged: (v) => setState(() => _isInstantBooking = v),
       )
       ```
    3. **Field Harga Opsional** (sopir, all-in, deposit) di bawah harga harian.
  - Update method `_submit()` untuk menggunakan `VehicleInputDto.toJson()`:
    ```dart
    final dto = VehicleInputDto(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      type: _type,
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      transmission: _transmission,
      licensePlate: _plateController.text.trim(),
      color: _colorController.text.trim(),
      seatingCapacity: int.tryParse(_capacityController.text) ?? 4,
      pricePerDay: double.tryParse(_priceController.text) ?? 0,
      rentalType: _rentalType,
      isInstantBooking: _isInstantBooking,
      priceWithDriver: double.tryParse(_driverPriceController.text),
      priceFullPackage: double.tryParse(_fullPackagePriceController.text),
      depositAmount: double.tryParse(_depositController.text),
      description: _descriptionController.text.trim(),
    );
    final data = dto.toJson();
    ```

- [ ] **5.2. Tambahkan Field Alasan Pemblokiran di Halaman Blocked Dates**
  - Edit [`mitra_vehicle_blocked_dates_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicle_blocked_dates_page.dart).
  - Tambahkan `TextEditingController _reasonController`.
  - Tambahkan `TextFormField` untuk input alasan di atas tombol simpan:
    ```dart
    TextFormField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Alasan Pemblokiran',
        hintText: 'Contoh: Servis berkala, Dipakai keluarga',
        prefixIcon: Icon(LucideIcons.messageSquare),
      ),
    )
    ```
  - Update panggilan `_save()` untuk menyertakan alasan:
    ```dart
    final success = await service.setVehicleBlockedDates(
      widget.vehicleId,
      _blockedDates,
      reason: _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : null,
    );
    ```

- [ ] **5.3. Tambahkan Tombol Pulihkan Armada di `MitraVehiclesPage`**
  - Edit [`mitra_vehicles_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_vehicles_page.dart).
  - Tambahkan tombol "Pulihkan" yang hanya muncul jika `vehicle.status == 'UNAVAILABLE'`:
    ```dart
    if (vehicle.status == VehicleStatusEnum.unavailable.value)
      TextButton.icon(
        onPressed: () async {
          final ok = await context.read<MitraService>().restoreVehicle(vehicle.id);
          if (context.mounted) {
            SnackbarUtils.showSuccess(context, ok
              ? 'Kendaraan diajukan untuk verifikasi ulang'
              : 'Gagal memulihkan kendaraan');
          }
        },
        icon: Icon(LucideIcons.refreshCw, size: 16.sp, color: AppColors.sky),
        label: Text('Pulihkan', style: AppTextStyles.labelLarge.copyWith(color: AppColors.sky)),
      ),
    ```

- [ ] **5.4. Perbaiki Galeri Foto Kendaraan di Halaman Detail Customer**
  - Edit [`vehicle_detail_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/vehicle_detail_page.dart).
  - Update method `_galleryUrls` untuk mengembalikan **seluruh** foto:
    ```dart
    List<String> _galleryUrls(VehicleModel vehicle) {
      if (vehicle.photos.isEmpty) return const [];
      return vehicle.allPhotoUrls
          .map((url) => cacheBustImageUrl(url, version: vehicle.id))
          .toList();
    }
    ```
  - Tambahkan info detail kendaraan yang sebelumnya tidak tampil di bawah heading:
    ```dart
    // Chip detail teknis
    Wrap(
      spacing: AppSpacing.xs,
      children: [
        if (vehicle.year != null) _DetailChip(label: '${vehicle.year}'),
        if (vehicle.color != null) _DetailChip(label: vehicle.color!),
        if (vehicle.seatingCapacity != null)
          _DetailChip(
            icon: LucideIcons.users,
            label: '${vehicle.seatingCapacity} kursi',
          ),
        if (vehicle.fuelType != null)
          _DetailChip(label: vehicle.fuelType!),
        if (vehicle.isInstantBooking)
          _DetailChip(
            icon: LucideIcons.zap,
            label: 'Instant Booking',
            color: AppColors.amber,
          ),
      ],
    ),
    // Blok harga berlapis
    if (vehicle.hasDriverOption)
      _PriceRow(
        label: '+ Dengan Sopir',
        price: vehicle.priceWithDriver!,
      ),
    if (vehicle.hasFullPackage)
      _PriceRow(
        label: '+ Paket Lengkap (BBM & Tol)',
        price: vehicle.priceFullPackage!,
      ),
    if (vehicle.depositAmount != null && vehicle.depositAmount! > 0)
      _PriceRow(
        label: 'Deposit Jaminan (refundable)',
        price: vehicle.depositAmount!,
        isDeposit: true,
      ),
    ```

---

## Fase 6: Verifikasi Integrasi, Static Analysis & Definition of Done

### Tasks:

- [ ] **6.1. Jalankan Build Runner untuk Regenerasi Kode Freezed**
  ```bash
  cd d:\Retal-Apps\travelindo
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
  Pastikan tidak ada error pada file `.freezed.dart` dan `.g.dart` di `mitra/data/models/`.

- [ ] **6.2. Jalankan Static Analysis**
  ```bash
  flutter analyze
  ```
  Tidak boleh ada error. Peringatan (*warnings*) yang bisa diterima: `deprecated API`, `unused_import` (hapus jika ada).

- [ ] **6.3. Checklist Pengujian Fungsional Manual**

  **Skenario Mitra — Manajemen Armada**:
  - [ ] Menambahkan armada baru dengan `rentalType: 'SHUTTLE'` dan `isInstantBooking: true`.
  - [ ] Toggle switch status di daftar armada: AVAILABLE ↔ UNAVAILABLE (tidak boleh kirim `'ACTIVE'`).
  - [ ] Toggle status ke MAINTENANCE dari form edit.
  - [ ] Soft-delete armada, lalu gunakan tombol "Pulihkan" → status berubah ke `PENDING_APPROVAL`.
  - [ ] Menetapkan blocked dates dengan alasan "Servis AC" → alasan tersimpan di backend.
  - [ ] Upload foto baru via halaman galeri foto armada.
  - [ ] Mengatur harga sopir dan deposit dari halaman pricing.

  **Skenario Customer — Eksplorasi Kendaraan**:
  - [ ] Membuka kalender ketersediaan unit → tanggal blocked tampil dicoret.
  - [ ] Mengetuk tanggal blocked → tooltip alasan muncul (jika ada alasan).
  - [ ] Halaman detail kendaraan menampilkan semua foto galeri (bukan hanya 1 foto).
  - [ ] Halaman detail menampilkan info tahun, warna, kapasitas, opsi sopir, deposit.
  - [ ] Filter pencarian dengan rentang tanggal `dateStart` dan `dateEnd` bekerja.
  - [ ] Toggle favorit kendaraan berfungsi dan persisten.

- [ ] **6.4. Konfirmasi Tidak Ada Regresi**
  - [ ] Fitur wallet tidak terpengaruh.
  - [ ] Fitur booking tidak terpengaruh.
  - [ ] Fitur profil mitra tidak terpengaruh.

- [ ] **6.5. Definition of Done (DoD) — Kriteria Selesai**
  - [ ] Semua 10 kesenjangan (*gap*) dari `PLANNING_VEHICLES_V1.md` Bagian 2 telah diperbaiki.
  - [ ] `flutter analyze` menghasilkan output: **No issues found!**
  - [ ] Build runner selesai tanpa konflik.
  - [ ] Semua skenario pengujian manual di 6.3 berhasil diverifikasi.
  - [ ] Tidak ada string status hardcoded `'ACTIVE'` atau `'INACTIVE'` yang tersisa di codebase modul kendaraan.
