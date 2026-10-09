import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/multipart_upload_helper.dart';
import '../../../core/network/upload_executor.dart';
import '../../../core/network/upload_resilience.dart';
import '../../../core/utils/image_prepare_util.dart';
import 'models/mitra_booking_model.dart';
import 'models/mitra_driver_model.dart';
import 'models/mitra_profile_model.dart';
import 'models/mitra_stats_model.dart';
import 'models/mitra_subscription_model.dart';
import 'models/mitra_vehicle_model.dart';
import 'models/vehicle_geofence_model.dart';
import 'models/mitra_review_model.dart';
import '../../../core/network/paginated_response.dart';

class MitraRemoteDataSource {
  const MitraRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse<MitraProfileModel>> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraProfile,
    );

    return ApiResponse<MitraProfileModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraProfileModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<MitraStatsModel>> getStats() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraStats,
    );

    return ApiResponse<MitraStatsModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraStatsModel.fromJson(json as Map<String, dynamic>),
    );
  }

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
      response.data ?? <String, dynamic>{},
      (json) => MitraVehicleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<MitraBookingModel>>> getBookings({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraBookings,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    return ApiResponse<List<MitraBookingModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as List)
          .whereType<Map<String, dynamic>>()
          .map(MitraBookingModel.fromJson)
          .toList(),
    );
  }

  Future<PaginatedResponse<MitraDriverModel>> getDrivers({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraDrivers,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PaginatedResponse<MitraDriverModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraDriverModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<MitraDriverModel>> createDriver(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraDrivers,
      data: data,
    );
    return ApiResponse<MitraDriverModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraDriverModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteDriver(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.mitraDriver(id),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> assignDriver(
    String bookingId,
    String? driverId,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.mitraAssignDriver(bookingId),
      data: {'driverId': driverId},
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<MitraProfileModel>> updateProfile(
    Map<String, dynamic> data, {
    String? bannerPath,
  }) async {
    final fields = Map<String, dynamic>.from(data);
    fields.remove('banner');

    if (bannerPath != null && bannerPath.isNotEmpty) {
      final prepared = await ImagePrepareUtil.prepareForUpload(bannerPath);
      final formData = await MultipartUploadHelper.buildProfileForm(
        fields,
        bannerPath: prepared,
      );
      await UploadExecutor(_apiClient).uploadMultipart(
        endpoint: ApiEndpoints.mitraProfile,
        formData: formData,
        usePatch: true,
      );
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mitraProfile,
      );
      return ApiResponse<MitraProfileModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => MitraProfileModel.fromJson(json as Map<String, dynamic>),
      );
    }

    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.mitraProfile,
      data: fields,
    );

    return ApiResponse<MitraProfileModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraProfileModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> approveBooking(
    String bookingId, {
    String? notes,
    String? driverId,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.bookingApprove(bookingId),
      data: {
        if (notes != null) 'notes': notes,
        if (driverId != null) 'driverId': driverId,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> rejectBooking(
    String bookingId, {
    String? reason,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.bookingReject(bookingId),
      data: {if (reason != null) 'notes': reason},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> handoverBooking(
    String bookingId, {
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.bookingHandover(bookingId),
      data: data,
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> returnBooking(
    String bookingId, {
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.bookingReturn(bookingId),
      data: data,
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<MitraVehicleModel>> createVehicle(
    Map<String, dynamic> data, {
    required List<String> photoPaths,
    UploadProgressCallback? onPhotoProgress,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.vehicles,
      data: data,
    );

    final vehicle = ApiResponse<MitraVehicleModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraVehicleModel.fromJson(json as Map<String, dynamic>),
    );

    if (vehicle.data?.id.isEmpty ?? true) {
      return vehicle;
    }

    final vehicleId = vehicle.data!.id;
    final executor = UploadExecutor(_apiClient);

    try {
      await executor.uploadPhotosToVehicle(
        vehicleId: vehicleId,
        paths: photoPaths,
        onPhotoProgress: onPhotoProgress,
      );
    } catch (error) {
      try {
        await _apiClient.delete<Map<String, dynamic>>(
          ApiEndpoints.vehicleById(vehicleId),
        );
      } catch (_) {}
      rethrow;
    }

    return vehicle;
  }

  Future<ApiResponse<MitraVehicleModel>> updateVehicle(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.vehicleById(id),
      data: data,
    );

    return ApiResponse<MitraVehicleModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraVehicleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> updateVehicleStatus(
    String id,
    String status,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.vehicleStatus(id),
      data: {'status': status},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> uploadVehiclePhotos(
    String id,
    List<String> paths, {
    UploadProgressCallback? onPhotoProgress,
  }) async {
    await UploadExecutor(_apiClient).uploadPhotosToVehicle(
      vehicleId: id,
      paths: paths,
      onPhotoProgress: onPhotoProgress,
    );

    return ApiResponse<void>.fromJson(<String, dynamic>{}, (_) {});
  }

  Future<ApiResponse<void>> uploadBookingDocument(
    String bookingId, {
    required String field,
    required String filePath,
    Map<String, String> extraFields = const {},
  }) async {
    await UploadExecutor(_apiClient).uploadNamedDocument(
      endpoint: ApiEndpoints.bookingUploadDocs(bookingId),
      fieldName: field,
      filePath: filePath,
      extraFields: extraFields,
    );

    return ApiResponse<void>.fromJson(<String, dynamic>{}, (_) {});
  }

  Future<ApiResponse<void>> setVehiclePricing(
    String id,
    Map<String, dynamic> pricing,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.vehiclePricing(id),
      data: pricing,
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

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

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

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

  Future<ApiResponse<double>> getBalance() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraBalance,
    );

    return ApiResponse<double>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<ApiResponse<void>> requestWithdraw(double amount) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraWithdraw,
      data: {'amount': amount},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> updateBankInfo(Map<String, dynamic> data) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.mitraProfileBankInfo,
      data: data,
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getEarningsHistory() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraEarningsHistory,
    );

    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getPayoutHistory() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraPayoutHistory,
    );

    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getEarnings() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraEarnings,
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<void>> requestPayout(
    double amount,
    String bankAccountId,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraPayoutRequest,
      data: {
        'amount': amount,
        if (bankAccountId.isNotEmpty) 'bankAccountId': bankAccountId,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<String>> uploadVehicleImage(String path) async {
    final prepared = await ImagePrepareUtil.prepareForUpload(path);
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(prepared),
    });

    final response = await UploadResilience.withRetry(
      () => _apiClient.upload<Map<String, dynamic>>(
        ApiEndpoints.vehicleUpload,
        formData: formData,
      ),
    );

    return ApiResponse<String>.fromJson(response.data ?? <String, dynamic>{}, (
      json,
    ) {
      final map = json as Map<String, dynamic>;
      return map['url']?.toString() ?? map['path']?.toString() ?? '';
    });
  }

  Future<ApiResponse<void>> deleteVehicle(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.vehicleById(id),
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> restoreVehicle(String id) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.vehicleRestore(id),
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTravelSchedules() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.travelMitraSchedules,
    );

    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTravelSchedule(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.travelMitraScheduleById(id),
      data: data,
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> cancelTravelSchedule(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.travelMitraScheduleById(id),
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createTravelSchedule(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.travelSchedules,
      data: data,
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteVehiclePhoto(
    String vehicleId,
    String photoId,
  ) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.vehiclePhotoById(vehicleId, photoId),
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }


  Future<ApiResponse<List<Map<String, dynamic>>>> getOperatingHours() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.operatingHours,
    );

    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as List).whereType<Map<String, dynamic>>().toList(),
    );
  }

  Future<ApiResponse<void>> updateOperatingHours(
    List<Map<String, dynamic>> hours,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.operatingHours,
      data: {'hours': hours},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyTourPackages() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.tourPackagesMitraMe,
    );
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createTourPackage(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.tourPackages,
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTourPackage(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.tourPackageById(id),
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<void>> deleteTourPackage(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.tourPackageById(id),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTourDestinations() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.tourDestinations,
    );
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createTourDestination(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.tourDestinations,
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTourDestination(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.tourDestinationById(id),
      data: data,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<void>> updateVehicleAmenities(
    String vehicleId,
    List<String> amenityIds,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.vehicleAmenitiesUpdate(vehicleId),
      data: {'amenityIds': amenityIds},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<MitraSubscriptionModel>> getSubscription() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraSubscription,
    );
    return ApiResponse<MitraSubscriptionModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => MitraSubscriptionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> upgradeSubscription() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraSubscriptionUpgrade,
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> cancelSubscription() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraSubscriptionCancel,
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<ActiveTrackingUnitModel>>> getActiveTracking() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraTrackingActive,
    );
    return ApiResponse<List<ActiveTrackingUnitModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as List)
          .whereType<Map<String, dynamic>>()
          .map(ActiveTrackingUnitModel.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<void>> pairGpsDevice(
    String vehicleId, {
    required String deviceId,
    String? vendor,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraVehicleGpsDevice(vehicleId),
      data: {'deviceId': deviceId, if (vendor != null) 'vendor': vendor},
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> unpairGpsDevice(String vehicleId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.mitraVehicleGpsDevice(vehicleId),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<VehicleGeofenceModel>>> getVehicleGeofences(
    String vehicleId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraVehicleGeofence(vehicleId),
    );
    return ApiResponse<List<VehicleGeofenceModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleGeofenceModel.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<VehicleGeofenceModel>> upsertVehicleGeofence(
    String vehicleId, {
    String? id,
    required String name,
    required double centerLat,
    required double centerLng,
    required int radiusM,
    bool isActive = true,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraVehicleGeofence(vehicleId),
      data: {
        if (id != null) 'id': id,
        'name': name,
        'centerLat': centerLat,
        'centerLng': centerLng,
        'radiusM': radiusM,
        'isActive': isActive,
      },
    );
    return ApiResponse<VehicleGeofenceModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => VehicleGeofenceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteVehicleGeofence(
    String vehicleId,
    String geofenceId,
  ) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.mitraVehicleGeofenceItem(vehicleId, geofenceId),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }
}
