# Task Execution Plan - Integrasi Modul Rekening Bank (Customer & Mitra) v3

Dokumen ini adalah checklist dan panduan teknis langkah demi langkah untuk mengeksekusi integrasi dan penyelarasan modul Rekening Bank antara Backend ([`Backend/src/routes/banks.ts`](file:///d:/Retal-Apps/Backend/src/routes/banks.ts)) dan Frontend Mobile Flutter ([`travelindo/lib/features/wallet`](file:///d:/Retal-Apps/travelindo/lib/features/wallet)).

> [!NOTE]
> **Batasan Ruang Lingkup**: Dokumen ini secara ketat **hanya mencakup endpoint pengguna Customer & Mitra** (`/banks/supported`, `/banks/my-accounts/*`). Route `/banks/admin/*` TIDAK diikutsertakan karena ditujukan khusus untuk CMS / Backoffice Admin Web.

Dokumen acuan perencanaan arsitektur: [`travelindo/docs/PLANNING_BANKS_V3.md`](file:///d:/Retal-Apps/travelindo/docs/PLANNING_BANKS_V3.md)

---

## Ringkasan Roadmap & Progress Tracker

- [x] **Fase 1: Standarisasi Data Layer & DTO Model (`lib/features/wallet/data/models`)**
- [x] **Fase 2: Remote DataSource & Repository Layer (`lib/features/wallet/data`)**
- [x] **Fase 3: Caching & State Management (`lib/core/cache` & `lib/features/wallet/application`)**
- [x] **Fase 4: Peningkatan UI & Presentation Layer (`lib/features/wallet/presentation`)**
- [ ] **Fase 5: Verifikasi Integrasi Mitra Payout & Definition of Done (DoD)**

---

## Fase 1: Standarisasi Data Layer & DTO Model

File target:
- [`travelindo/lib/features/wallet/data/models/supported_bank_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/supported_bank_model.dart) *(File baru)*
- [`travelindo/lib/features/wallet/data/models/wallet_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/wallet_model.dart)
- [`travelindo/lib/features/wallet/data/models/add_bank_account_input.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/add_bank_account_input.dart) *(File baru)*

### Tasks:
- [x] **1.1. Buat Model Bertipe `SupportedBankModel`**
  - Buat file `supported_bank_model.dart` di folder `lib/features/wallet/data/models/`.
  - Struktur data sesuai respons `GET /banks/supported`:
    ```dart
    class SupportedBankModel {
      const SupportedBankModel({
        required this.id,
        required this.code,
        required this.name,
        this.logoUrl,
        this.isActive = true,
      });

      final String id;
      final String code;
      final String name;
      final String? logoUrl;
      final bool isActive;

      factory SupportedBankModel.fromJson(Map<String, dynamic> json) {
        return SupportedBankModel(
          id: json['id']?.toString() ?? '',
          code: json['code']?.toString() ?? '',
          name: json['name']?.toString() ?? '',
          logoUrl: json['logoUrl']?.toString(),
          isActive: json['isActive'] != false,
        );
      }

      Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'isActive': isActive,
      };
    }
    ```

- [x] **1.2. Refactor `BankAccountModel` di `wallet_model.dart`**
  - Perbaiki field `accountHolder` menjadi `accountName` dan `isPrimary` menjadi `isMain`.
  - Tambahkan field `userId`, `bankId`, `bankCode`, `bankLogoUrl`, dan `createdAt`.
  - Pertahankan getter `accountHolder` dan `isPrimary` sebagai alias *backward compatibility*:
    ```dart
    class BankAccountModel {
      const BankAccountModel({
        required this.id,
        required this.userId,
        required this.bankId,
        required this.accountName,
        required this.accountNumber,
        required this.isMain,
        required this.bankName,
        this.bankCode,
        this.bankLogoUrl,
        this.createdAt,
      });

      final String id;
      final String userId;
      final String bankId;
      final String accountName;
      final String accountNumber;
      final bool isMain;
      final String bankName;
      final String? bankCode;
      final String? bankLogoUrl;
      final String? createdAt;

      String get accountHolder => accountName;
      bool get isPrimary => isMain;

      factory BankAccountModel.fromJson(Map<String, dynamic> json) {
        return BankAccountModel(
          id: json['id']?.toString() ?? '',
          userId: json['userId']?.toString() ?? '',
          bankId: json['bankId']?.toString() ?? '',
          accountName: json['accountName']?.toString() ?? json['accountHolder']?.toString() ?? '',
          accountNumber: json['accountNumber']?.toString() ?? '',
          isMain: json['isMain'] == true || json['isPrimary'] == true,
          bankName: json['bankName']?.toString() ?? '',
          bankCode: json['bankCode']?.toString(),
          bankLogoUrl: json['bankLogoUrl']?.toString(),
          createdAt: json['createdAt']?.toString(),
        );
      }
    }
    ```

- [x] **1.3. Buat Input DTO `AddBankAccountInput`**
  - Buat file `add_bank_account_input.dart` di `lib/features/wallet/data/models/` untuk memastikan payload `POST /banks/my-accounts` selalu valid sesuai schema Zod backend:
    ```dart
    class AddBankAccountInput {
      const AddBankAccountInput({
        required this.bankId,
        required this.accountNumber,
        required this.accountName,
        this.isMain = false,
      });

      final String bankId;
      final String accountNumber;
      final String accountName;
      final bool isMain;

      Map<String, dynamic> toJson() => {
        'bankId': bankId,
        'accountNumber': accountNumber.trim(),
        'accountName': accountName.trim(),
        'isMain': isMain,
      };
    }
    ```

---

## Fase 2: Remote DataSource & Repository Layer

File target:
- [`travelindo/lib/core/network/api_endpoints.dart`](file:///d:/Retal-Apps/travelindo/lib/core/network/api_endpoints.dart)
- [`travelindo/lib/features/wallet/data/wallet_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/wallet_remote_datasource.dart)
- [`travelindo/lib/features/wallet/data/wallet_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/wallet_repository.dart)

### Tasks:
- [x] **2.1. Standarisasi Helper di `ApiEndpoints`**
  - Tambahkan helper URL eksplisit untuk penghapusan rekening:
    ```dart
    static String bankAccountById(String id) => '/banks/my-accounts/$id';
    ```

- [x] **2.2. Pembaruan `WalletRemoteDataSource`**
  - Ganti `Future<ApiResponse<List<Map<String, dynamic>>>> getSupportedBanks()` menjadi:
    ```dart
    Future<ApiResponse<List<SupportedBankModel>>> getSupportedBanks() async {
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.banksSupported);
      return ApiResponse<List<SupportedBankModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => json is List
            ? json.whereType<Map<String, dynamic>>().map(SupportedBankModel.fromJson).toList()
            : <SupportedBankModel>[],
      );
    }
    ```
  - Perbarui `addBankAccount` agar menerima `AddBankAccountInput`:
    ```dart
    Future<ApiResponse<BankAccountModel>> addBankAccount(AddBankAccountInput input) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.bankAccounts,
        data: input.toJson(),
      );
      return ApiResponse<BankAccountModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => BankAccountModel.fromJson(json is Map<String, dynamic> ? json : <String, dynamic>{}),
      );
    }
    ```
  - Perbarui `deleteBankAccount` untuk menggunakan `ApiEndpoints.bankAccountById(id)`:
    ```dart
    Future<ApiResponse<void>> deleteBankAccount(String id) async {
      final response = await _apiClient.delete<Map<String, dynamic>>(ApiEndpoints.bankAccountById(id));
      return ApiResponse<void>.fromJson(response.data ?? <String, dynamic>{}, (_) {});
    }
    ```
  - Perbarui `setPrimaryBankAccount` untuk mengembalikan `BankAccountModel`:
    ```dart
    Future<ApiResponse<BankAccountModel>> setPrimaryBankAccount(String id) async {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.bankAccountPrimary(id),
      );
      return ApiResponse<BankAccountModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => BankAccountModel.fromJson(json is Map<String, dynamic> ? json : <String, dynamic>{}),
      );
    }
    ```

- [x] **2.3. Pembaruan `WalletRepository`**
  - Sinkronkan method repository dengan tipe data baru:
    ```dart
    Future<ApiResponse<List<SupportedBankModel>>> getSupportedBanks() =>
        _remoteDataSource.getSupportedBanks();

    Future<ApiResponse<BankAccountModel>> addBankAccount(AddBankAccountInput input) =>
        _remoteDataSource.addBankAccount(input);

    Future<ApiResponse<BankAccountModel>> setPrimaryBankAccount(String id) =>
        _remoteDataSource.setPrimaryBankAccount(id);
    ```

---

## Fase 3: Caching & State Management

File target:
- [`travelindo/lib/core/cache/reference_data_cache.dart`](file:///d:/Retal-Apps/travelindo/lib/core/cache/reference_data_cache.dart)
- [`travelindo/lib/features/wallet/application/wallet_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/application/wallet_service.dart)

### Tasks:
- [x] **3.1. Refactor Cache Bank di `ReferenceDataCache`**
  - Perbarui method `getBanks()` agar mengembalikan `Future<List<SupportedBankModel>>`:
    ```dart
    Future<List<SupportedBankModel>> getBanks() {
      return _getOrFetch<List<SupportedBankModel>>(
        'banks',
        banksTtl,
        () async {
          final response = await _walletRepository.getSupportedBanks();
          return response.data ?? [];
        },
      );
    }
    ```

- [x] **3.2. Peningkatan State Management `WalletService`**
  - Tambahkan getter dan penanganan error yang komprehensif:
    ```dart
    bool _isBankLoading = false;
    bool _isBankActionLoading = false;
    String? _bankErrorMessage;

    bool get isBankLoading => _isBankLoading;
    bool get isBankActionLoading => _isBankActionLoading;
    String? get bankErrorMessage => _bankErrorMessage;
    ```
  - Perbarui `loadBankAccounts()` dengan penanganan error dan status loading.
  - Perbarui `addBankAccount(AddBankAccountInput input)`:
    - Set `_isBankActionLoading = true`.
    - Tangani error dengan `_bankErrorMessage = userFacingError(e)`.
    - Panggil `loadBankAccounts()` setelah berhasil.
    - Kembalikan `bool` status sukses.
  - Perbarui `deleteBankAccount(String id)` dan `setPrimaryBankAccount(String id)` dengan pola yang sama.
  - Perbarui `getSupportedBanks()` agar mengembalikan `Future<List<SupportedBankModel>>`.

---

## Fase 4: Peningkatan UI & Presentation Layer

File target:
- [`travelindo/lib/features/wallet/presentation/pages/bank_account_list_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/presentation/pages/bank_account_list_page.dart)
- [`travelindo/lib/features/wallet/presentation/widgets/add_bank_account_bottom_sheet.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/presentation/widgets/add_bank_account_bottom_sheet.dart) *(Widget baru)*

### Tasks:
- [x] **4.1. Buat Komponen Bottom Sheet Modern `AddBankAccountBottomSheet`**
  - Buat widget `AddBankAccountBottomSheet` di folder `lib/features/wallet/presentation/widgets/`:
    - Dropdown / Selector Bank didukung dari `WalletService.getSupportedBanks()` lengkap dengan logo dan nama resmi bank.
    - Input nomor rekening (numeric keyboard, validasi 5-30 karakter).
    - Input nama pemilik rekening (text capitalization words, validasi 2-100 karakter).
    - Switch toggle "Jadikan Rekening Utama" (otomatis ON jika user belum memiliki rekening tersimpan).
    - Tombol simpan dengan loading state (`ElevatedButton` dengan indicator).
    - Error feedback yang informatif menggunakan `SnackbarUtils`.

- [x] **4.2. Refactoring Halaman `BankAccountListPage`**
  - Ganti `_showAddDialog` lama dengan memanggil `showModalBottomSheet(context: context, builder: (_) => const AddBankAccountBottomSheet())`.
  - Tampilkan logo bank di `ListTile.leading` menggunakan `Image.network` jika `bank.bankLogoUrl` ada, atau fallback `Icon(LucideIcons.landmark)`.
  - Tampilkan label/badge "Utama" (*badge teal*) di samping `bank.bankName` jika `bank.isMain == true`.
  - Perbaiki tampilan subtitle:
    ```dart
    subtitle: Text('${bank.accountNumber}\na.n. ${bank.accountName}', style: AppTextStyles.bodySmall),
    ```
  - Tambahkan dialog konfirmasi sebelum menghapus:
    ```dart
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rekening?'),
        content: Text('Apakah Anda yakin ingin menghapus rekening ${bank.bankName} (${bank.accountNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.deleteBankAccount(bank.id);
    }
    ```
  - Perbarui tombol aksi "Jadikan Utama" dengan feedback visual yang jelas.

---

## Fase 5: Verifikasi Integrasi Mitra Payout & Definition of Done (DoD)

File target:
- [`travelindo/lib/features/mitra/presentation/pages/mitra_earnings_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_earnings_page.dart)

### Tasks:
- [ ] **5.1. Verifikasi Kompatibilitas di `MitraEarningsPage`**
  - Pastikan dropdown pilihan rekening di dialog penarikan dana mitra (`Tarik Saldo`) membaca `b.bankName` dan `b.accountNumber` dengan benar dari `WalletService.bankAccounts`.
  - Pastikan tombol "Tambah Rekening Baru" pada dialog tersebut dapat membuka `AddBankAccountBottomSheet` atau menavigasi ke `BankAccountListPage`.

- [ ] **5.2. Eksekusi Analisis Statis Kode Flutter**
  - Jalankan perintah di terminal:
    ```bash
    flutter analyze lib/features/wallet lib/features/mitra/presentation/pages/mitra_earnings_page.dart lib/core/cache/reference_data_cache.dart
    ```
  - Pastikan 0 errors dan 0 warnings baru.

- [ ] **5.3. Checklist Acceptance Criteria**
  - [ ] Response `GET /banks/supported` ter-cache dengan aman di `ReferenceDataCache`.
  - [ ] Response `GET /banks/my-accounts` menampilkan nama pemilik rekening dan badge utama secara akurat.
  - [ ] Request `POST /banks/my-accounts` mengirimkan UUID `bankId` yang valid dan nama pemilik rekening, sukses 201 Created.
  - [ ] Hapus rekening dilindungi konfirmasi visual.
  - [ ] Set rekening utama memperbarui urutan dan badge seketika.
  - [ ] Seluruh route admin tetap terisolasi di sisi backend web.
