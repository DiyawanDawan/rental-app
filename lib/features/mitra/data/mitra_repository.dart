import '../../../core/network/api_response.dart';
import '../../../core/network/paginated_response.dart';
import '../../../core/network/upload_executor.dart';
import '../../../core/storage/token_storage.dart';
import 'models/mitra_booking_model.dart';
import 'models/mitra_driver_model.dart';
import 'models/mitra_profile_model.dart';
import 'models/mitra_stats_model.dart';
import 'models/mitra_subscription_model.dart';
import 'models/vehicle_geofence_model.dart';
import 'models/mitra_vehicle_model.dart';
import 'models/mitra_review_model.dart';
import 'mitra_remote_datasource.dart';

class MitraRepository {
  const MitraRepository({
    required MitraRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  final MitraRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  Future<ApiResponse<MitraProfileModel>> getProfile() =>
      _remoteDataSource.getProfile();

  Future<ApiResponse<MitraProfileModel>> updateProfile(
    Map<String, dynamic> data, {
    String? bannerPath,
  }) => _remoteDataSource.updateProfile(data, bannerPath: bannerPath);

  Future<ApiResponse<MitraStatsModel>> getStats() =>
      _remoteDataSource.getStats();

  Future<PaginatedResponse<MitraVehicleModel>> getVehicles({
    String? status, String? type, String? search,
    int page = 1, int limit = 10,
  }) =>
      _remoteDataSource.getVehicles(
        status: status, type: type, search: search,
        page: page, limit: limit,
      );

  Future<ApiResponse<List<MitraBookingModel>>> getBookings({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) => _remoteDataSource.getBookings(
    page: page,
    limit: limit,
    status: status,
    search: search,
  );

  Future<ApiResponse<void>> approveBooking(
    String bookingId, {
    String? notes,
    String? driverId,
  }) => _remoteDataSource.approveBooking(
    bookingId,
    notes: notes,
    driverId: driverId,
  );

  Future<ApiResponse<void>> rejectBooking(String bookingId, {String? reason}) =>
      _remoteDataSource.rejectBooking(bookingId, reason: reason);

  Future<ApiResponse<void>> handoverBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) => _remoteDataSource.handoverBooking(bookingId, data: data);

  Future<ApiResponse<void>> returnBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) => _remoteDataSource.returnBooking(bookingId, data: data);

  Future<ApiResponse<MitraVehicleModel>> createVehicle(
    Map<String, dynamic> data, {
    required List<String> photoPaths,
    UploadProgressCallback? onPhotoProgress,
  }) => _remoteDataSource.createVehicle(
    data,
    photoPaths: photoPaths,
    onPhotoProgress: onPhotoProgress,
  );

  Future<ApiResponse<MitraVehicleModel>> updateVehicle(
    String id,
    Map<String, dynamic> data,
  ) => _remoteDataSource.updateVehicle(id, data);

  Future<ApiResponse<void>> updateVehicleStatus(String id, String status) =>
      _remoteDataSource.updateVehicleStatus(id, status);

  Future<ApiResponse<void>> uploadVehiclePhotos(
    String id,
    List<String> paths, {
    UploadProgressCallback? onPhotoProgress,
  }) => _remoteDataSource.uploadVehiclePhotos(
    id,
    paths,
    onPhotoProgress: onPhotoProgress,
  );

  Future<ApiResponse<void>> uploadBookingDocument(
    String bookingId, {
    required String field,
    required String filePath,
    Map<String, String> extraFields = const {},
  }) => _remoteDataSource.uploadBookingDocument(
    bookingId,
    field: field,
    filePath: filePath,
    extraFields: extraFields,
  );

  Future<ApiResponse<void>> setVehiclePricing(
    String id,
    Map<String, dynamic> pricing,
  ) => _remoteDataSource.setVehiclePricing(id, pricing);

  Future<ApiResponse<void>> setVehicleBlockedDates(
    String id,
    List<String> dates, {
    String? reason,
  }) => _remoteDataSource.setVehicleBlockedDates(id, dates, reason: reason);

  Future<ApiResponse<void>> replyReview(String reviewId, String reply) =>
      _remoteDataSource.replyReview(reviewId, reply);

  Future<ApiResponse<MitraReviewPaginatedModel>> getMitraReviews({int page = 1}) =>
      _remoteDataSource.getMitraReviews(page: page);

  Future<ApiResponse<double>> getBalance() => _remoteDataSource.getBalance();

  Future<ApiResponse<void>> requestWithdraw(double amount) =>
      _remoteDataSource.requestWithdraw(amount);

  Future<ApiResponse<void>> updateBankInfo(Map<String, dynamic> data) =>
      _remoteDataSource.updateBankInfo(data);

  Future<ApiResponse<List<Map<String, dynamic>>>> getEarningsHistory() =>
      _remoteDataSource.getEarningsHistory();

  Future<ApiResponse<List<Map<String, dynamic>>>> getPayoutHistory() =>
      _remoteDataSource.getPayoutHistory();

  Future<ApiResponse<String>> uploadVehicleImage(String path) =>
      _remoteDataSource.uploadVehicleImage(path);

  Future<ApiResponse<void>> deleteVehicle(String id) =>
      _remoteDataSource.deleteVehicle(id);

  Future<ApiResponse<void>> restoreVehicle(String id) =>
      _remoteDataSource.restoreVehicle(id);

  Future<ApiResponse<void>> deleteVehiclePhoto(
    String vehicleId,
    String photoId,
  ) => _remoteDataSource.deleteVehiclePhoto(vehicleId, photoId);

  Future<ApiResponse<List<Map<String, dynamic>>>> getTravelSchedules() =>
      _remoteDataSource.getTravelSchedules();

  Future<ApiResponse<Map<String, dynamic>>> updateTravelSchedule(
    String id,
    Map<String, dynamic> data,
  ) => _remoteDataSource.updateTravelSchedule(id, data);

  Future<ApiResponse<void>> cancelTravelSchedule(String id) =>
      _remoteDataSource.cancelTravelSchedule(id);

  Future<ApiResponse<Map<String, dynamic>>> createTravelSchedule(
    Map<String, dynamic> data,
  ) => _remoteDataSource.createTravelSchedule(data);

  Future<ApiResponse<Map<String, dynamic>>> getEarnings() =>
      _remoteDataSource.getEarnings();

  Future<ApiResponse<void>> requestPayout(
    double amount,
    String bankAccountId,
  ) => _remoteDataSource.requestPayout(amount, bankAccountId);

  Future<ApiResponse<List<Map<String, dynamic>>>> getOperatingHours() =>
      _remoteDataSource.getOperatingHours();

  Future<ApiResponse<void>> updateOperatingHours(
    List<Map<String, dynamic>> hours,
  ) => _remoteDataSource.updateOperatingHours(hours);

  Future<ApiResponse<void>> updateVehicleAmenities(
    String vehicleId,
    List<String> amenityIds,
  ) => _remoteDataSource.updateVehicleAmenities(vehicleId, amenityIds);

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyTourPackages() =>
      _remoteDataSource.getMyTourPackages();

  Future<ApiResponse<Map<String, dynamic>>> createTourPackage(
    Map<String, dynamic> data,
  ) => _remoteDataSource.createTourPackage(data);

  Future<ApiResponse<Map<String, dynamic>>> updateTourPackage(
    String id,
    Map<String, dynamic> data,
  ) => _remoteDataSource.updateTourPackage(id, data);

  Future<ApiResponse<void>> deleteTourPackage(String id) =>
      _remoteDataSource.deleteTourPackage(id);

  Future<ApiResponse<List<Map<String, dynamic>>>> getTourDestinations() =>
      _remoteDataSource.getTourDestinations();

  Future<ApiResponse<Map<String, dynamic>>> createTourDestination(
    Map<String, dynamic> data,
  ) => _remoteDataSource.createTourDestination(data);

  Future<ApiResponse<Map<String, dynamic>>> updateTourDestination(
    String id,
    Map<String, dynamic> data,
  ) => _remoteDataSource.updateTourDestination(id, data);

  Future<ApiResponse<MitraSubscriptionModel>> getSubscription() =>
      _remoteDataSource.getSubscription();

  Future<ApiResponse<void>> upgradeSubscription() =>
      _remoteDataSource.upgradeSubscription();

  Future<ApiResponse<void>> cancelSubscription() =>
      _remoteDataSource.cancelSubscription();

  Future<ApiResponse<List<ActiveTrackingUnitModel>>> getActiveTracking() =>
      _remoteDataSource.getActiveTracking();

  Future<ApiResponse<void>> pairGpsDevice(
    String vehicleId, {
    required String deviceId,
    String? vendor,
  }) => _remoteDataSource.pairGpsDevice(
    vehicleId,
    deviceId: deviceId,
    vendor: vendor,
  );

  Future<ApiResponse<void>> unpairGpsDevice(String vehicleId) =>
      _remoteDataSource.unpairGpsDevice(vehicleId);

  Future<ApiResponse<List<VehicleGeofenceModel>>> getVehicleGeofences(
    String vehicleId,
  ) => _remoteDataSource.getVehicleGeofences(vehicleId);

  Future<ApiResponse<VehicleGeofenceModel>> upsertVehicleGeofence(
    String vehicleId, {
    String? id,
    required String name,
    required double centerLat,
    required double centerLng,
    required int radiusM,
    bool isActive = true,
  }) => _remoteDataSource.upsertVehicleGeofence(
    vehicleId,
    id: id,
    name: name,
    centerLat: centerLat,
    centerLng: centerLng,
    radiusM: radiusM,
    isActive: isActive,
  );

  Future<ApiResponse<void>> deleteVehicleGeofence(
    String vehicleId,
    String geofenceId,
  ) => _remoteDataSource.deleteVehicleGeofence(vehicleId, geofenceId);

  Future<PaginatedResponse<MitraDriverModel>> getDrivers({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) => _remoteDataSource.getDrivers(
    page: page,
    limit: limit,
    status: status,
    search: search,
  );

  Future<ApiResponse<MitraDriverModel>> createDriver(
    Map<String, dynamic> data,
  ) => _remoteDataSource.createDriver(data);

  Future<ApiResponse<void>> deleteDriver(String id) =>
      _remoteDataSource.deleteDriver(id);

  Future<ApiResponse<void>> assignDriver(String bookingId, String? driverId) =>
      _remoteDataSource.assignDriver(bookingId, driverId);
}
