# Task Execution Plan - Integrasi Modul Ulasan / Reviews (Customer & Mitra) v1

Dokumen ini adalah checklist dan panduan teknis langkah demi langkah (*step-by-step execution plan*) untuk mengeksekusi integrasi dan sinkronisasi modul Ulasan (*Reviews & Ratings*) antara Backend Express ([`Backend/src/routes/reviews.ts`](file:///d:/Retal-Apps/Backend/src/routes/reviews.ts)) dan Frontend Mobile Flutter ([`travelindo/lib/features/`](file:///d:/Retal-Apps/travelindo/lib/features/)).

> [!NOTE]
> Dokumen acuan perencanaan arsitektur: [`travelindo/docs/PLANNING_REVIEWS_V1.md`](file:///d:/Retal-Apps/travelindo/docs/PLANNING_REVIEWS_V1.md)

---

## Ringkasan Roadmap & Progress Tracker

- [ ] **Fase 1: Penyelarasan Backend & Skema Validasi (`Backend/src`)**
- [ ] **Fase 2: Standarisasi Data Layer & Model DTO (`travelindo/lib/features/*/data/models`)**
- [ ] **Fase 3: Remote DataSource & Repository Layer (`travelindo/lib/features/*/data`)**
- [ ] **Fase 4: Service & State Management Layer (`travelindo/lib/features/*/application`)**
- [ ] **Fase 5: Form, UI & Presentation Layer (`travelindo/lib/features/*/presentation`)**
- [ ] **Fase 6: Verifikasi Integrasi, Static Analysis & Definition of Done (DoD)**

---

## Fase 1: Penyelarasan Backend & Skema Validasi

File target:
- [`Backend/src/services/review.service.ts`](file:///d:/Retal-Apps/Backend/src/services/review.service.ts)
- [`Backend/src/validations/review.validation.ts`](file:///d:/Retal-Apps/Backend/src/validations/review.validation.ts)
- [`Backend/src/routes/reviews.ts`](file:///d:/Retal-Apps/Backend/src/routes/reviews.ts)

### Tasks:

- [ ] **1.1. Perbarui Status Booking yang Sah untuk Review di `review.service.ts`**
  - Buka [`Backend/src/services/review.service.ts`](file:///d:/Retal-Apps/Backend/src/services/review.service.ts).
  - Perbaiki validasi status booking agar mengizinkan status `RETURNED` maupun `COMPLETED`:
    ```typescript
    // Backend/src/services/review.service.ts
    const allowedStatuses = ['RETURNED', 'COMPLETED'];
    if (!booking.status || !allowedStatuses.includes(booking.status)) {
      throw new AppError(
        'Review hanya dapat diberikan setelah kendaraan dikembalikan atau pesanan selesai',
        400,
      );
    }
    ```
  - Sertakan `customer.avatarUrl` pada kueri `getMitraReviews` dan konversikan ke URL publik CDN.

- [ ] **1.2. Lengkapi Validasi Zod di `review.validation.ts`**
  - Buka [`Backend/src/validations/review.validation.ts`](file:///d:/Retal-Apps/Backend/src/validations/review.validation.ts).
  - Tambahkan sub-rating opsional ke `submitReviewSchema`.
  - Buat skema baru `replyReviewSchema` dan `editReviewSchema`:
    ```typescript
    import { z } from 'zod';

    export const submitReviewSchema = z.object({
      body: z.object({
        bookingId: z.string().uuid('ID booking tidak valid'),
        rating: z.number().int().min(1).max(5, 'Rating antara 1–5'),
        comment: z.string().optional(),
        ratingCleanliness: z.number().int().min(1).max(5).optional(),
        ratingService: z.number().int().min(1).max(5).optional(),
        ratingCondition: z.number().int().min(1).max(5).optional(),
      }),
    });

    export const getVehicleReviewsSchema = z.object({
      params: z.object({ vehicleId: z.string().uuid('ID kendaraan tidak valid') }),
    });

    export const getMitraReviewsSchema = z.object({
      params: z.object({ mitraId: z.string().uuid('ID mitra tidak valid') }),
    });

    export const reviewIdSchema = z.object({
      params: z.object({ id: z.string().uuid('ID review tidak valid') }),
    });

    export const replyReviewSchema = z.object({
      params: z.object({ id: z.string().uuid('ID review tidak valid') }),
      body: z.object({
        replyText: z.string().trim().min(1, 'Teks balasan ulasan wajib diisi'),
      }),
    });

    export const editReviewSchema = z.object({
      params: z.object({ id: z.string().uuid('ID review tidak valid') }),
      body: z.object({
        rating: z.number().int().min(1).max(5, 'Rating antara 1–5').optional(),
        comment: z.string().optional(),
      }),
    });
    ```

- [ ] **1.3. Pasangkan Middleware Validasi di `Backend/src/routes/reviews.ts`**
  - Buka [`Backend/src/routes/reviews.ts`](file:///d:/Retal-Apps/Backend/src/routes/reviews.ts).
  - Terapkan `validate(v.editReviewSchema)` pada `router.patch('/:id')`.
  - Terapkan `validate(v.replyReviewSchema)` pada `router.post('/:id/reply')`.

---

## Fase 2: Standarisasi Data Layer & Model DTO Frontend Flutter

File target:
- [`travelindo/lib/features/mitra/data/models/mitra_review_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/models/mitra_review_model.dart) *(File baru)*
- [`travelindo/lib/features/customer/data/models/review_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/review_model.dart)
- [`travelindo/lib/features/customer/data/models/vehicle_review_aggregate_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/models/vehicle_review_aggregate_model.dart) *(File baru)*

### Tasks:

- [ ] **2.1. Buat Model Bertipe `MitraReviewItemModel` & Paginasi**
  - Buat file `lib/features/mitra/data/models/mitra_review_model.dart`.
  - Menangani item ulasan mitra dengan format aman dan parsing tanggal:
    ```dart
    class MitraReviewItemModel {
      const MitraReviewItemModel({
        required this.id,
        required this.rating,
        this.comment,
        this.mitraReply,
        this.createdAt,
        this.vehicleBrand,
        this.vehicleModel,
        this.customerName,
        this.customerAvatarUrl,
      });

      final String id;
      final int rating;
      final String? comment;
      final String? mitraReply;
      final DateTime? createdAt;
      final String? vehicleBrand;
      final String? vehicleModel;
      final String? customerName;
      final String? customerAvatarUrl;

      String get vehicleName => [vehicleBrand, vehicleModel]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ');

      bool get hasReply => mitraReply != null && mitraReply!.trim().isNotEmpty;

      factory MitraReviewItemModel.fromJson(Map<String, dynamic> json) {
        return MitraReviewItemModel(
          id: json['id']?.toString() ?? '',
          rating: (json['rating'] as num?)?.toInt() ?? 0,
          comment: json['comment']?.toString(),
          mitraReply: json['mitraReply']?.toString() ?? json['reply']?.toString(),
          createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
          vehicleBrand: json['vehicleBrand']?.toString(),
          vehicleModel: json['vehicleModel']?.toString(),
          customerName: json['customerName']?.toString() ?? json['customer']?['fullName']?.toString(),
          customerAvatarUrl: json['customerAvatarUrl']?.toString() ?? json['customer']?['avatarUrl']?.toString(),
        );
      }
    }

    class MitraReviewPaginatedModel {
      const MitraReviewPaginatedModel({
        required this.reviews,
        required this.total,
        required this.page,
        required this.limit,
        required this.totalPages,
      });

      final List<MitraReviewItemModel> reviews;
      final int total;
      final int page;
      final int limit;
      final int totalPages;

      factory MitraReviewPaginatedModel.fromJson(Map<String, dynamic> json) {
        final list = (json['reviews'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(MitraReviewItemModel.fromJson)
                .toList() ??
            [];
        return MitraReviewPaginatedModel(
          reviews: list,
          total: (json['total'] as num?)?.toInt() ?? list.length,
          page: (json['page'] as num?)?.toInt() ?? 1,
          limit: (json['limit'] as num?)?.toInt() ?? 20,
          totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
        );
      }
    }
    ```

- [ ] **2.2. Perbarui `ReviewModel` Customer & Buat `VehicleReviewAggregateModel`**
  - Buat file `lib/features/customer/data/models/vehicle_review_aggregate_model.dart`:
    ```dart
    import 'review_model.dart';

    class VehicleReviewAggregateModel {
      const VehicleReviewAggregateModel({
        required this.reviews,
        required this.averageRating,
        required this.totalReviews,
      });

      final List<ReviewModel> reviews;
      final double averageRating;
      final int totalReviews;

      factory VehicleReviewAggregateModel.fromJson(Map<String, dynamic> json) {
        final rawReviews = json['reviews'] as List? ?? [];
        return VehicleReviewAggregateModel(
          reviews: rawReviews
              .whereType<Map<String, dynamic>>()
              .map(ReviewModel.fromJson)
              .toList(),
          averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
          totalReviews: (json['totalReviews'] as num?)?.toInt() ?? rawReviews.length,
        );
      }
    }
    ```
  - Tambahkan sub-rating opsional pada `ReviewModel` di `lib/features/customer/data/models/review_model.dart`:
    ```dart
    final int? ratingCleanliness;
    final int? ratingService;
    final int? ratingCondition;
    ```

---

## Fase 3: Endpoint Constants & Remote Data Source

File target:
- [`travelindo/lib/core/network/api_endpoints.dart`](file:///d:/Retal-Apps/travelindo/lib/core/network/api_endpoints.dart)
- [`travelindo/lib/features/mitra/data/mitra_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_remote_datasource.dart)
- [`travelindo/lib/features/customer/data/customer_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_remote_datasource.dart)

### Tasks:

- [ ] **3.1. Perbaiki Payload `replyReview` di `MitraRemoteDataSource`**
  - Buka [`travelindo/lib/features/mitra/data/mitra_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_remote_datasource.dart).
  - Ubah payload dari `{'reply': reply}` menjadi `{'replyText': reply}`:
    ```dart
    Future<ApiResponse<void>> replyReview(String reviewId, String reply) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.reviewReply(reviewId),
        data: {'replyText': reply},
      );

      return ApiResponse<void>.fromJson(
        response.data ?? <String, dynamic>{},
        (_) {},
      );
    }
    ```

- [ ] **3.2. Perbaiki Deserialisasi `getMitraReviews` di `MitraRemoteDataSource`**
  - Ubah method `getMitraReviews` agar mendukung paginasi dan mengembalikan `MitraReviewPaginatedModel`:
    ```dart
    Future<ApiResponse<MitraReviewPaginatedModel>> getMitraReviews({
      int page = 1,
      int limit = 20,
    }) async {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mitraReviews,
        queryParameters: {'page': page, 'limit': limit},
      );

      return ApiResponse<MitraReviewPaginatedModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => MitraReviewPaginatedModel.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );
    }
    ```

- [ ] **3.3. Tambahkan Method `editReview` & Update `submitReview` di `CustomerRemoteDataSource`**
  - Buka [`travelindo/lib/features/customer/data/customer_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_remote_datasource.dart).
  - Perbarui `submitReview` untuk mengirimkan sub-rating opsional:
    ```dart
    Future<ApiResponse<void>> submitReview({
      required String bookingId,
      required int rating,
      String? comment,
      int? ratingCleanliness,
      int? ratingService,
      int? ratingCondition,
    }) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.reviews,
        data: {
          'bookingId': bookingId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
          if (ratingCleanliness != null) 'ratingCleanliness': ratingCleanliness,
          if (ratingService != null) 'ratingService': ratingService,
          if (ratingCondition != null) 'ratingCondition': ratingCondition,
        },
      );

      return ApiResponse<void>.fromJson(
        response.data ?? <String, dynamic>{},
        (_) {},
      );
    }
    ```
  - Tambahkan method `editReview`:
    ```dart
    Future<ApiResponse<void>> editReview({
      required String reviewId,
      int? rating,
      String? comment,
    }) async {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.reviewById(reviewId),
        data: {
          if (rating != null) 'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );

      return ApiResponse<void>.fromJson(
        response.data ?? <String, dynamic>{},
        (_) {},
      );
    }
    ```

- [ ] **3.4. Ambil Data Agregat Review di `getVehicleReviewsAggregate`**
  - Tambahkan method untuk mengambil objek agregat penuh:
    ```dart
    Future<ApiResponse<VehicleReviewAggregateModel>> getVehicleReviewsAggregate(
      String vehicleId,
    ) async {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.reviewVehicle(vehicleId),
      );

      return ApiResponse<VehicleReviewAggregateModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => VehicleReviewAggregateModel.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        ),
      );
    }
    ```

---

## Fase 4: Service & State Management Layer

File target:
- [`travelindo/lib/features/mitra/data/mitra_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/data/mitra_repository.dart)
- [`travelindo/lib/features/mitra/application/mitra_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/application/mitra_service.dart)
- [`travelindo/lib/features/customer/data/customer_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/data/customer_repository.dart)
- [`travelindo/lib/features/customer/application/customer_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/application/customer_service.dart)

### Tasks:

- [ ] **4.1. Perbarui `MitraRepository` & `MitraService` dengan Star Distribution**
  - Buka [`travelindo/lib/features/mitra/application/mitra_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/application/mitra_service.dart).
  - Simpan ulasan dalam bentuk `List<MitraReviewItemModel> _reviews`.
  - Hitung sebaran bintang di `loadReviewsSummary`:
    ```dart
    List<MitraReviewItemModel> _reviews = [];
    List<MitraReviewItemModel> get reviews => List.unmodifiable(_reviews);

    Future<void> loadReviewsSummary({int page = 1}) async {
      _setLoading();
      try {
        final response = await _repository.getMitraReviews(page: page);
        final paginated = response.data;
        if (paginated == null) {
          _reviews = [];
          _markLoaded();
          return;
        }

        _reviews = paginated.reviews;

        final distribution = {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
        double sumRating = 0;
        for (final r in _reviews) {
          final star = r.rating.clamp(1, 5).toString();
          distribution[star] = (distribution[star] ?? 0) + 1;
          sumRating += r.rating;
        }

        final avgRating = _reviews.isEmpty ? 0.0 : sumRating / _reviews.length;

        _reviewsSummary = {
          'total': paginated.total,
          'totalReviews': paginated.total,
          'average': avgRating,
          'averageRating': avgRating,
          'distribution': distribution,
          'page': paginated.page,
          'totalPages': paginated.totalPages,
        };
        _markLoaded();
      } catch (error) {
        _setFailure(error);
      }
    }
    ```

- [ ] **4.2. Perbarui `CustomerRepository` & `CustomerService` untuk Pengiriman & Edit Review**
  - Buka [`travelindo/lib/features/customer/application/customer_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/application/customer_service.dart).
  - Tambahkan delegasi ke `editReview`:
    ```dart
    Future<bool> editReview({
      required String reviewId,
      int? rating,
      String? comment,
    }) async {
      try {
        await _repository.editReview(reviewId: reviewId, rating: rating, comment: comment);
        return true;
      } catch (e) {
        return false;
      }
    }
    ```

---

## Fase 5: Form, UI & Presentation Layer

File target:
- [`travelindo/lib/features/customer/presentation/pages/booking_detail_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/booking_detail_page.dart)
- [`travelindo/lib/features/customer/presentation/pages/submit_review_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/submit_review_page.dart)
- [`travelindo/lib/features/mitra/presentation/pages/mitra_reviews_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_reviews_page.dart)
- [`travelindo/lib/features/mitra/presentation/widgets/mitra_review_summary_card.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/widgets/mitra_review_summary_card.dart)

### Tasks:

- [ ] **5.1. Hubungkan Tombol "Beri Review & Rating" pada Status Selesai di `BookingDetailPage`**
  - Buka [`travelindo/lib/features/customer/presentation/pages/booking_detail_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/booking_detail_page.dart).
  - Ganti pengecekan `if (booking.status == 'COMPLETED')` menjadi:
    ```dart
    if (['RETURNED', 'COMPLETED'].contains(booking.status))
      ElevatedButton.icon(
        onPressed: () => context.push(
          '/bookings/${booking.id}/review?vehicleName=${Uri.encodeComponent(booking.vehicle?.name ?? 'Kendaraan')}',
        ),
        icon: const Icon(LucideIcons.star),
        label: const Text('Beri Review & Rating'),
      ),
    ```

- [ ] **5.2. Tingkatkan `SubmitReviewPage` dengan Sub-rating Bintang**
  - Buka [`travelindo/lib/features/customer/presentation/pages/submit_review_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/customer/presentation/pages/submit_review_page.dart).
  - Tambahkan pemilih bintang untuk 3 aspek: Kebersihan Unit, Keramahan Layanan, dan Kondisi Mesin/Fisik.
  - Sediakan feedback validasi jika rating belum dipilih.

- [ ] **5.3. Perbarui `MitraReviewsPage` dengan Model Bertipe & Avatar Pengulas**
  - Buka [`travelindo/lib/features/mitra/presentation/pages/mitra_reviews_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/mitra/presentation/pages/mitra_reviews_page.dart).
  - Gunakan `MitraReviewItemModel` dan tampilkan nama kendaraan (`review.vehicleName`), nama customer (`review.customerName`), avatar customer (`review.customerAvatarUrl`), tanggal ulasan terformat, dan badge status apakah ulasan sudah dibalas atau belum.

- [ ] **5.4. Sempurnakan `MitraReviewSummaryCard` di Dashboard**
  - Pastikan kartu membaca map `summary['distribution']` yang sudah dipasok dari `MitraService`.

---

## Fase 6: Verifikasi Integrasi, Static Analysis & Definition of Done

### Tasks:

- [ ] **6.1. Verifikasi Kompilasi Backend**
  - Jalankan build TypeScript pada Backend:
    ```powershell
    cd d:\Retal-Apps\Backend
    npm run build
    ```
- [ ] **6.2. Verifikasi Analisis Statis Flutter**
  - Jalankan `flutter analyze` pada repositori travelindo:
    ```powershell
    cd d:\Retal-Apps\travelindo
    flutter analyze
    ```
- [ ] **6.3. Verifikasi Checklist Definition of Done (DoD)**
  - [ ] Customer dapat mengirim review pada booking berstatus `RETURNED` dan `COMPLETED`.
  - [ ] Mitra dapat mengirim balasan dan teks balasan tersimpan permanen di database.
  - [ ] Mitra review list tidak lagi kosong dan menampilkan nama armada serta customer.
  - [ ] Star distribution bar pada dashboard mitra menampilkan persentase bintang yang tepat.
