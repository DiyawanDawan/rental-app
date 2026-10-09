# Task Execution Plan - Integrasi Modul Dompet Digital / Saldo Dompet (Customer & Mitra) v1

Dokumen ini adalah checklist dan panduan teknis langkah demi langkah (*step-by-step execution plan*) untuk mengeksekusi integrasi dan sinkronisasi modul Dompet Digital (*Wallet & Top-up*) antara Backend Express ([`Backend/src/routes/wallet.ts`](file:///d:/Retal-Apps/Backend/src/routes/wallet.ts)) dan Frontend Mobile Flutter ([`travelindo/lib/features/wallet`](file:///d:/Retal-Apps/travelindo/lib/features/wallet)).

> [!NOTE]
> **Batasan Ruang Lingkup**: Dokumen ini secara ketat **hanya mencakup endpoint pengguna Customer & Mitra** (`/wallet/balance`, `/wallet/transactions`, `/wallet/topup`, `/wallet/topup/:id`). Webhook endpoint (`/payments/webhook`) berjalan di sisi server backend dan tidak diintegrasikan langsung ke aplikasi mobile client.

Dokumen acuan perencanaan arsitektur: [`travelindo/docs/PLANNING_WALLET_V1.md`](file:///d:/Retal-Apps/travelindo/docs/PLANNING_WALLET_V1.md)

---

## Ringkasan Roadmap & Progress Tracker

- [x] **Fase 1: Standarisasi Data Layer & DTO Model (`lib/features/wallet/data/models`)**
- [x] **Fase 2: Endpoint Constants & Remote Data Source (`lib/core/network` & `lib/features/wallet/data`)**
- [x] **Fase 3: Repository & State Management Layer (`lib/features/wallet/data` & `lib/features/wallet/application`)**
- [x] **Fase 4: Peningkatan UI & Presentation Layer (`lib/features/wallet/presentation`)**
- [x] **Fase 5: Verifikasi Integrasi, Static Analysis & Definition of Done (DoD)**

---

## Fase 1: Standarisasi Data Layer & DTO Model

File target:
- [`travelindo/lib/features/wallet/data/models/wallet_balance_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/wallet_balance_model.dart) *(File baru)*
- [`travelindo/lib/features/wallet/data/models/wallet_topup_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/wallet_topup_model.dart) *(File baru)*
- [`travelindo/lib/features/wallet/data/models/create_topup_input.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/create_topup_input.dart) *(File baru)*
- [`travelindo/lib/features/wallet/data/models/wallet_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/models/wallet_model.dart) *(Refactoring `TransactionModel`)*

### Tasks:
- [ ] **1.1. Buat Model Bertipe `WalletBalanceModel`**
  - Buat file `wallet_balance_model.dart` di folder `lib/features/wallet/data/models/`.
  - Struktur data sesuai respons `GET /wallet/balance`:
    ```dart
    class WalletBalanceModel {
      const WalletBalanceModel({
        required this.balance,
        required this.totalEarned,
        required this.totalWithdrawn,
        this.updatedAt,
      });

      final double balance;
      final double totalEarned;
      final double totalWithdrawn;
      final String? updatedAt;

      factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
        return WalletBalanceModel(
          balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
          totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
          totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
          updatedAt: json['updatedAt']?.toString(),
        );
      }

      Map<String, dynamic> toJson() => {
        'balance': balance,
        'totalEarned': totalEarned,
        'totalWithdrawn': totalWithdrawn,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
    }
    ```

- [ ] **1.2. Refactoring `TransactionModel` di `wallet_model.dart`**
  - Sesuaikan field agar memetakan respons `GET /wallet/transactions`:
    - Tambahkan `category`, `balanceBefore`, dan `balanceAfter`.
    - Buat helper boolean `isCredit` berdasarkan `type` (`CREDIT`, `TOPUP`, `EARNING`, `REFUND`).
    - Pertahankan field `status` dengan nilai *fallback* `'COMPLETED'` demi menjaga *backwards compatibility*.
    ```dart
    class TransactionModel {
      const TransactionModel({
        required this.id,
        required this.amount,
        required this.type,
        required this.category,
        required this.balanceBefore,
        required this.balanceAfter,
        required this.description,
        required this.createdAt,
        this.status = 'COMPLETED',
      });

      final String id;
      final double amount;
      final String type;
      final String category;
      final double balanceBefore;
      final double balanceAfter;
      final String description;
      final String createdAt;
      final String status;

      bool get isCredit =>
          type == 'CREDIT' || type == 'TOPUP' || type == 'EARNING' || type == 'REFUND';

      factory TransactionModel.fromJson(Map<String, dynamic> json) {
        return TransactionModel(
          id: json['id']?.toString() ?? '',
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          type: json['type']?.toString() ?? '',
          category: json['category']?.toString() ?? '',
          balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
          balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
          description: json['description']?.toString() ?? '',
          createdAt: json['createdAt']?.toString() ?? '',
          status: json['status']?.toString() ?? 'COMPLETED',
        );
      }

      Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'category': category,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'description': description,
        'createdAt': createdAt,
        'status': status,
      };
    }
    ```

- [ ] **1.3. Buat Model Bertipe `WalletTopupModel`**
  - Buat file `wallet_topup_model.dart` di folder `lib/features/wallet/data/models/`.
  - Struktur data sesuai respons `POST /wallet/topup` dan `GET /wallet/topup/:id`:
    ```dart
    class WalletTopupModel {
      const WalletTopupModel({
        required this.id,
        required this.amount,
        required this.status,
        this.channelCode,
        this.paymentUrl,
        this.createdAt,
      });

      final String id;
      final double amount;
      final String status;
      final String? channelCode;
      final String? paymentUrl;
      final String? createdAt;

      bool get isPending => status.toUpperCase() == 'PENDING';
      bool get isSuccess => status.toUpperCase() == 'SUCCESS';
      bool get isFailed => status.toUpperCase() == 'FAILED';
      bool get isExpired => status.toUpperCase() == 'EXPIRED';
      bool get isCancelled => status.toUpperCase() == 'CANCELLED';

      bool get isTerminal => isSuccess || isFailed || isExpired || isCancelled;

      factory WalletTopupModel.fromJson(Map<String, dynamic> json) {
        return WalletTopupModel(
          id: json['id']?.toString() ?? '',
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          status: json['status']?.toString() ?? 'PENDING',
          channelCode: json['channelCode']?.toString(),
          paymentUrl: json['paymentUrl']?.toString(),
          createdAt: json['createdAt']?.toString(),
        );
      }

      Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'status': status,
        if (channelCode != null) 'channelCode': channelCode,
        if (paymentUrl != null) 'paymentUrl': paymentUrl,
        if (createdAt != null) 'createdAt': createdAt,
      };
    }
    ```

- [ ] **1.4. Buat DTO Input `CreateTopupInput`**
  - Buat file `create_topup_input.dart` di folder `lib/features/wallet/data/models/`:
    ```dart
    class CreateTopupInput {
      const CreateTopupInput({
        required this.amount,
        required this.channelCode,
        this.channelProperties,
      });

      final double amount;
      final String channelCode;
      final Map<String, dynamic>? channelProperties;

      Map<String, dynamic> toJson() => {
        'amount': amount.toInt(),
        'channelCode': channelCode,
        if (channelProperties != null && channelProperties!.isNotEmpty)
          'channelProperties': channelProperties,
      };
    }
    ```

---

## Fase 2: Endpoint Constants & Remote Data Source

File target:
- [`travelindo/lib/core/network/api_endpoints.dart`](file:///d:/Retal-Apps/travelindo/lib/core/network/api_endpoints.dart)
- [`travelindo/lib/features/wallet/data/wallet_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/wallet_remote_datasource.dart)

### Tasks:
- [ ] **2.1. Daftarkan URL Endpoint di `ApiEndpoints`**
  - Buka `lib/core/network/api_endpoints.dart` dan tambahkan konstanta endpoint top-up:
    ```dart
    // Payments & Wallet
    static const String walletBalance = '/wallet/balance';
    static const String walletTransactions = '/wallet/transactions';
    static const String walletTopup = '/wallet/topup';
    static String walletTopupStatus(String id) => '/wallet/topup/$id';
    ```

- [ ] **2.2. Perbarui `WalletRemoteDataSource`**
  - Ubah `getBalance()` untuk mengembalikan `Future<ApiResponse<WalletBalanceModel>>`:
    ```dart
    Future<ApiResponse<WalletBalanceModel>> getBalance() async {
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.walletBalance);
      return ApiResponse<WalletBalanceModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => WalletBalanceModel.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );
    }
    ```
  - Tambahkan parameter query pada `getTransactions({int page = 1, int limit = 10})`:
    ```dart
    Future<ApiResponse<List<TransactionModel>>> getTransactions({
      int page = 1,
      int limit = 10,
    }) async {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.walletTransactions,
        queryParameters: {'page': page, 'limit': limit},
      );
      return ApiResponse<List<TransactionModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => json is List
            ? json.whereType<Map<String, dynamic>>().map(TransactionModel.fromJson).toList()
            : <TransactionModel>[],
      );
    }
    ```
  - Perbarui `createTopup(CreateTopupInput input)` agar mengembalikan `Future<ApiResponse<WalletTopupModel>>`:
    ```dart
    Future<ApiResponse<WalletTopupModel>> createTopup(CreateTopupInput input) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.walletTopup,
        data: input.toJson(),
      );
      return ApiResponse<WalletTopupModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => WalletTopupModel.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );
    }
    ```
  - Perbarui `getTopupStatus(String id)` agar mengembalikan `Future<ApiResponse<WalletTopupModel>>`:
    ```dart
    Future<ApiResponse<WalletTopupModel>> getTopupStatus(String id) async {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.walletTopupStatus(id),
      );
      return ApiResponse<WalletTopupModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => WalletTopupModel.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );
    }
    ```

---

## Fase 3: Repository & State Management Layer

File target:
- [`travelindo/lib/features/wallet/data/wallet_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/data/wallet_repository.dart)
- [`travelindo/lib/features/wallet/application/wallet_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/application/wallet_service.dart)

### Tasks:
- [ ] **3.1. Selaraskan Metode di `WalletRepository`**
  - Teruskan model strongly typed dari remote data source:
    ```dart
    Future<ApiResponse<WalletBalanceModel>> getBalance() => _remoteDataSource.getBalance();

    Future<ApiResponse<List<TransactionModel>>> getTransactions({
      int page = 1,
      int limit = 10,
    }) =>
        _remoteDataSource.getTransactions(page: page, limit: limit);

    Future<ApiResponse<WalletTopupModel>> createTopup(CreateTopupInput input) =>
        _remoteDataSource.createTopup(input);

    Future<ApiResponse<WalletTopupModel>> getTopupStatus(String id) =>
        _remoteDataSource.getTopupStatus(id);
    ```

- [ ] **3.2. Sempurnakan State Management di `WalletService`**
  - Simpan objek `WalletBalanceModel? _walletBalance`.
  - Sediakan getter alias:
    ```dart
    WalletBalanceModel? get walletBalance => _walletBalance;
    double get balance => _walletBalance?.balance ?? 0.0;
    double get totalEarned => _walletBalance?.totalEarned ?? 0.0;
    double get totalWithdrawn => _walletBalance?.totalWithdrawn ?? 0.0;
    ```
  - Dukung *pagination state* pada riwayat transaksi:
    - `int _currentPage = 1;`
    - `bool _hasMoreTransactions = true;`
    - `bool _isLoadingMore = false;`
    - Metode `loadMoreTransactions()`.
  - Sempurnakan implementasi pembuatan dan *polling status* top-up:
    ```dart
    Future<WalletTopupModel?> createTopup(CreateTopupInput input) async {
      try {
        final response = await _repository.createTopup(input);
        return response.data;
      } catch (error) {
        _message = userFacingError(error);
        notifyListeners();
        return null;
      }
    }

    Future<WalletTopupModel?> checkTopupStatus(String topupId) async {
      try {
        final response = await _repository.getTopupStatus(topupId);
        return response.data;
      } catch (_) {
        return null;
      }
    }
    ```

---

## Fase 4: Peningkatan UI & Presentation Layer

File target:
- [`travelindo/lib/features/wallet/presentation/pages/wallet_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/presentation/pages/wallet_page.dart)
- [`travelindo/lib/features/wallet/presentation/pages/wallet_topup_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/wallet/presentation/pages/wallet_topup_page.dart)
- [`travelindo/lib/core/widgets/lists/transaction_tile.dart`](file:///d:/Retal-Apps/travelindo/lib/core/widgets/lists/transaction_tile.dart)

### Tasks:
- [ ] **4.1. Tingkatkan Kartu Saldo & Tampilan Dashboard (`WalletPage`)**
  - Tampilkan kartu saldo modern dengan tipografi jelas.
  - Tampilkan rincian metrik: Total Pemasukan (`+Rp ...`) dan Total Pengeluaran (`-Rp ...`).
  - Sediakan 3 segmented filter tab: **Semua**, **Masuk**, **Keluar**.
  - Tampilkan rincian saldo sesudah transaksi (*balanceAfter*) pada transaksi riwayat.
  - Hubungkan *Pull-to-Refresh* agar menyegarkan saldo dan riwayat secara atomik.

- [ ] **4.2. Sempurnakan Form & Alur Top-up (`WalletTopupPage`)**
  - Tambahkan deretan chip pilihan cepat nominal: Rp 20.000, Rp 50.000, Rp 100.000, Rp 200.000, Rp 500.000, Rp 1.000.000.
  - Tambahkan validasi batas minimum Rp 10.000 dan maksimum Rp 10.000.000 secara responsif.
  - Perbaiki pemilihan kanal pembayaran dengan logo dan nama jelas.
  - Tambahkan *modal bottom sheet polling* dengan proteksi *timeout* (maksimal 3 menit / 45 kali request) dan pembatalan otomatis saat pengguna menutup halaman (*dispose*).
  - Tampilkan notifikasi keberhasilan dan perbarui data dompet saat status `SUCCESS`.

- [ ] **4.3. Update `TransactionTile` untuk Kategori Lengkap**
  - Tampilkan label kategori transaksi (`BOOKING`, `TOPUP`, `WITHDRAWAL`, `EARNING`, `REFUND`) dengan visual yang informatif.

---

## Fase 5: Verifikasi, Static Analysis & Definition of Done (DoD)

### Checklist Pengujian & Acceptance:
1. [ ] **Verifikasi Saldo Aktif**:
   - Saldo berhasil dibaca dari backend tanpa error parsing `0.0`.
   - Angka `totalEarned` dan `totalWithdrawn` tampil akurat pada halaman dompet.
2. [ ] **Verifikasi Transaksi Paginasi**:
   - Riwayat mutasi memuat data transaksi lengkap dengan `amount`, `balanceBefore`, `balanceAfter`, dan tanda arah mutasi (+/-).
   - Filter tab (Semua, Masuk, Keluar) menyaring daftar transaksi secara benar.
3. [ ] **Verifikasi Top-up Flow**:
   - Request `POST /wallet/topup` mengirim nominal integer dan kanal valid ke backend.
   - Redirect URL Xendit berhasil dibuka melalui browser / aplikasi eksternal.
   - Polling berhasil mendeteksi perubahan status dari `PENDING` menjadi `SUCCESS`.
   - Polling berhenti secara aman saat mencapai status terminal atau jika terjadi *timeout*.
4. [ ] **Analisis Statis & Kualitas Kode**:
   - Jalankan `flutter analyze` dan pastikan tidak ada pesan error maupun peringatan baru di paket `travelindo`.
