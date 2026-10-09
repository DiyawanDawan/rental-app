import 'package:flutter/foundation.dart';
import 'package:travelindo/features/mitra/data/models/mitra_vehicle_model.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/error_message_util.dart';
import '../../../core/network/multipart_upload_helper.dart';
import '../../../core/services/realtime_service.dart';
import '../data/models/mitra_booking_model.dart';
import '../data/models/mitra_driver_model.dart';
import '../data/models/mitra_profile_model.dart';
import '../data/models/mitra_stats_model.dart';
import '../data/models/mitra_subscription_model.dart';
import '../data/models/vehicle_geofence_model.dart';
import '../data/models/mitra_review_model.dart';
import '../data/mitra_repository.dart';

enum MitraStatus { initial, loading, loaded, failure }

class MitraService extends ChangeNotifier {
  MitraService(this._repository, this._realTimeService);

  final MitraRepository _repository;
  final RealTimeService _realTimeService;

  MitraStatus _status = MitraStatus.initial;
  MitraProfileModel? _profile;
  MitraStatsModel? _stats;
  Map<String, dynamic>? _earnings;
  Map<String, dynamic>? _reviewsSummary;
  List<Map<String, dynamic>> _operatingHours = [];
  List<MitraVehicleModel> _vehicles = [];
  List<MitraBookingModel> _bookings = [];
  List<MitraDriverModel> _drivers = [];
  List<MitraReviewItemModel> _reviews = [];
  List<Map<String, dynamic>> _travelSchedules = [];
  List<Map<String, dynamic>> _tourPackages = [];
  MitraSubscriptionModel? _subscription;
  List<ActiveTrackingUnitModel> _activeTracking = [];
  List<Map<String, dynamic>>? _earningsHistory;
  Failure? _lastFailure;
  String? _message;
  int _uploadPhotoCurrent = 0;
  int _uploadPhotoTotal = 0;

  MitraStatus get status => _status;
  double? get uploadProgress =>
      _uploadPhotoTotal > 0 ? _uploadPhotoCurrent / _uploadPhotoTotal : null;
  String? get uploadProgressLabel => _uploadPhotoTotal > 0
      ? 'Mengunggah foto $_uploadPhotoCurrent dari $_uploadPhotoTotal'
      : null;
  MitraProfileModel? get profile => _profile;
  MitraStatsModel? get stats => _stats;
  Map<String, dynamic>? get earnings => _earnings;
  Map<String, dynamic>? get reviewsSummary => _reviewsSummary;
  List<MitraVehicleModel> get vehicles => List.unmodifiable(_vehicles);
  List<MitraBookingModel> get bookings => List.unmodifiable(_bookings);
  List<MitraDriverModel> get drivers => List.unmodifiable(_drivers);
  List<Map<String, dynamic>> get operatingHours =>
      List.unmodifiable(_operatingHours);
  List<MitraReviewItemModel> get reviews => List.unmodifiable(_reviews);
  List<Map<String, dynamic>> get travelSchedules =>
      List.unmodifiable(_travelSchedules);
  List<Map<String, dynamic>> get tourPackages =>
      List.unmodifiable(_tourPackages);
  MitraSubscriptionModel? get subscription => _subscription;
  List<ActiveTrackingUnitModel> get activeTracking =>
      List.unmodifiable(_activeTracking);
  Failure? get lastFailure => _lastFailure;
  String? get message => _message;
  List<Map<String, dynamic>>? get earningsHistory => _earningsHistory;

  Future<void> loadProfile() async {
    _setLoading();
    try {
      final response = await _repository.getProfile();
      _profile = response.data;
      _message = response.message;
      _markLoaded();

      if (_profile != null) {
        initRealTime();
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  void initRealTime() {
    if (_profile == null) return;

    _realTimeService.pusher.subscribe(
      channelName: 'private-mitra.${_profile!.id}',
      onEvent: (event) {
        if (event.eventName == 'new-booking' ||
            event.eventName == 'booking-updated') {
          loadBookings();
          loadStats();
        } else if (event.eventName == 'vehicle-updated') {
          loadVehicles();
        }
      },
    );
  }

  Future<bool> updateProfile(
    Map<String, dynamic> data, {
    String? bannerPath,
  }) async {
    _setLoading();
    try {
      final response = await _repository.updateProfile(
        data,
        bannerPath: bannerPath,
      );
      _profile = response.data;
      _message = response.message;
      _markLoaded();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadStats() async {
    _setLoading();
    try {
      final response = await _repository.getStats();
      _stats = response.data;
      _message = response.message;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> loadVehicles({
    String? status, String? type, String? search,
    int page = 1, int limit = 10,
  }) async {
    _setLoading();
    try {
      final response = await _repository.getVehicles(
        status: status, type: type, search: search,
        page: page, limit: limit,
      );
      _vehicles = response.data ?? [];
      _message = response.message;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> loadBookings({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) async {
    _setLoading();
    try {
      final response = await _repository.getBookings(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
      _bookings = response.data ?? [];
      _message = response.message;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> loadDrivers({String? search}) async {
    _setLoading();
    try {
      final response = await _repository.getDrivers(search: search);
      _drivers = response.data;
      _message = response.message;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> createDriver(Map<String, dynamic> data) async {
    _setLoading();
    try {
      await _repository.createDriver(data);
      await loadDrivers();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> deleteDriver(String id) async {
    _setLoading();
    try {
      await _repository.deleteDriver(id);
      _drivers = _drivers.where((driver) => driver.id != id).toList();
      _markLoaded();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> assignDriver(String bookingId, String? driverId) async {
    try {
      await _repository.assignDriver(bookingId, driverId);
      await loadBookings();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> approveBooking(
    String bookingId, {
    String? notes,
    String? driverId,
  }) async {
    _setLoading();
    try {
      final response = await _repository.approveBooking(
        bookingId,
        notes: notes,
        driverId: driverId,
      );
      _message = response.message;
      await loadBookings();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> rejectBooking(String bookingId, {String? reason}) async {
    _setLoading();
    try {
      final response = await _repository.rejectBooking(
        bookingId,
        reason: reason,
      );
      _message = response.message;
      await loadBookings();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> handoverBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    _setLoading();
    try {
      final response = await _repository.handoverBooking(bookingId, data);
      _message = response.message;
      await loadBookings();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> returnBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    _setLoading();
    try {
      final response = await _repository.returnBooking(bookingId, data);
      _message = response.message;
      await loadBookings();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> createVehicle(
    Map<String, dynamic> data, {
    required List<String> photoPaths,
  }) async {
    _setLoading();
    _resetUploadProgress(photoPaths.length);
    try {
      final response = await _repository.createVehicle(
        data,
        photoPaths: photoPaths,
        onPhotoProgress: _updateUploadProgress,
      );
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    } finally {
      _clearUploadProgress();
    }
  }

  Future<bool> updateVehicle(String id, Map<String, dynamic> data) async {
    _setLoading();
    try {
      final response = await _repository.updateVehicle(id, data);
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> updateVehicleStatus(String id, String status) async {
    _setLoading();
    try {
      final response = await _repository.updateVehicleStatus(id, status);
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> uploadVehiclePhotos(String id, List<String> paths) async {
    _setLoading();
    _resetUploadProgress(paths.length);
    try {
      final response = await _repository.uploadVehiclePhotos(
        id,
        paths,
        onPhotoProgress: _updateUploadProgress,
      );
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    } finally {
      _clearUploadProgress();
    }
  }

  Future<bool> uploadBookingDocument(
    String bookingId, {
    required String field,
    required String filePath,
    Map<String, String> extraFields = const {},
  }) async {
    try {
      final response = await _repository.uploadBookingDocument(
        bookingId,
        field: field,
        filePath: filePath,
        extraFields: extraFields,
      );
      _message = response.message;
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> handoverBookingWithPhoto(
    String bookingId, {
    required String photoPath,
    String notes = 'Kondisi baik',
  }) async {
    final uploaded = await uploadBookingDocument(
      bookingId,
      field: BookingDocField.handoverPhoto,
      filePath: photoPath,
      extraFields: {'handoverNotes': notes},
    );
    if (!uploaded) return false;
    return handoverBooking(bookingId, {'notes': notes});
  }

  Future<bool> returnBookingWithPhoto(
    String bookingId, {
    required String photoPath,
    String notes = 'Selesai',
  }) async {
    final uploaded = await uploadBookingDocument(
      bookingId,
      field: BookingDocField.returnedPhoto,
      filePath: photoPath,
      extraFields: {'returnedNotes': notes},
    );
    if (!uploaded) return false;
    return returnBooking(bookingId, {'notes': notes});
  }

  Future<bool> setVehiclePricing(
    String id,
    Map<String, dynamic> pricing,
  ) async {
    _setLoading();
    try {
      final response = await _repository.setVehiclePricing(id, pricing);
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> setVehicleBlockedDates(
    String id,
    List<String> dates, {
    String? reason,
  }) async {
    _setLoading();
    try {
      final response = await _repository.setVehicleBlockedDates(
        id,
        dates,
        reason: reason,
      );
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> replyReview(String reviewId, String reply) async {
    _setLoading();
    try {
      final response = await _repository.replyReview(reviewId, reply);
      _message = response.message;
      await loadReviewsSummary();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadEarnings() async {
    _setLoading();
    try {
      final response = await _repository.getEarnings();
      _earnings = response.data;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> loadEarningsHistory() async {
    try {
      final response = await _repository.getEarningsHistory();
      _earningsHistory = response.data;
      notifyListeners();
    } catch (_) {
      // non-fatal: history is supplementary
    }
  }

  Future<bool> requestPayout(double amount, String bankAccountId) async {
    _setLoading();
    try {
      final response = await _repository.requestPayout(amount, bankAccountId);
      _message = response.message;
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadOperatingHours() async {
    _setLoading();
    try {
      final response = await _repository.getOperatingHours();
      _operatingHours = response.data ?? [];
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> updateOperatingHours(List<Map<String, dynamic>> hours) async {
    _setLoading();
    try {
      final response = await _repository.updateOperatingHours(hours);
      _message = response.message;
      await loadOperatingHours();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> updateVehicleAmenities(
    String vehicleId,
    List<String> amenityIds,
  ) async {
    _setLoading();
    try {
      final response = await _repository.updateVehicleAmenities(
        vehicleId,
        amenityIds,
      );
      _message = response.message;
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

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

  Future<bool> deleteVehicle(String id) async {
    _setLoading();
    try {
      await _repository.deleteVehicle(id);
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> restoreVehicle(String id) async {
    _setLoading();
    try {
      await _repository.restoreVehicle(id);
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> deleteVehiclePhoto(String vehicleId, String photoId) async {
    _setLoading();
    try {
      await _repository.deleteVehiclePhoto(vehicleId, photoId);
      await loadVehicles();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadTravelSchedules() async {
    _setLoading();
    try {
      final response = await _repository.getTravelSchedules();
      _travelSchedules = response.data ?? [];
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> cancelTravelSchedule(String id) async {
    _setLoading();
    try {
      await _repository.cancelTravelSchedule(id);
      await loadTravelSchedules();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadTourPackages() async {
    _setLoading();
    try {
      final response = await _repository.getMyTourPackages();
      _tourPackages = response.data ?? [];
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> createTourPackage(Map<String, dynamic> data) async {
    _setLoading();
    try {
      await _repository.createTourPackage(data);
      await loadTourPackages();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> updateTourPackage(String id, Map<String, dynamic> data) async {
    _setLoading();
    try {
      await _repository.updateTourPackage(id, data);
      await loadTourPackages();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> deleteTourPackage(String id) async {
    _setLoading();
    try {
      await _repository.deleteTourPackage(id);
      await loadTourPackages();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTourDestinations() async {
    try {
      final response = await _repository.getTourDestinations();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<String?> uploadImage(String path) async {
    try {
      final response = await _repository.uploadVehicleImage(path);
      final url = response.data;
      return url != null && url.isNotEmpty ? url : null;
    } catch (error) {
      _setFailure(error);
      return null;
    }
  }

  Future<bool> createTourDestination(Map<String, dynamic> data) async {
    _setLoading();
    try {
      await _repository.createTourDestination(data);
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> updateTourDestination(
    String id,
    Map<String, dynamic> data,
  ) async {
    _setLoading();
    try {
      await _repository.updateTourDestination(id, data);
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadSubscription() async {
    _setLoading();
    try {
      final response = await _repository.getSubscription();
      _subscription = response.data;
      _message = response.message;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> upgradeSubscription() async {
    _setLoading();
    try {
      final response = await _repository.upgradeSubscription();
      _message = response.message;
      await loadSubscription();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> loadActiveTracking() async {
    _setLoading();
    try {
      final response = await _repository.getActiveTracking();
      _activeTracking = response.data ?? [];
      _message = response.message;
      _markLoaded();
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<bool> pairGpsDevice(
    String vehicleId, {
    required String deviceId,
    String? vendor,
  }) async {
    _setLoading();
    try {
      final response = await _repository.pairGpsDevice(
        vehicleId,
        deviceId: deviceId,
        vendor: vendor,
      );
      _message = response.message;
      _markLoaded();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> unpairGpsDevice(String vehicleId) async {
    _setLoading();
    try {
      final response = await _repository.unpairGpsDevice(vehicleId);
      _message = response.message;
      _markLoaded();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<List<VehicleGeofenceModel>> loadVehicleGeofences(
    String vehicleId,
  ) async {
    try {
      final response = await _repository.getVehicleGeofences(vehicleId);
      return response.data ?? [];
    } catch (error) {
      _setFailure(error);
      return [];
    }
  }

  Future<bool> saveVehicleGeofence(
    String vehicleId, {
    String? id,
    required String name,
    required double centerLat,
    required double centerLng,
    required int radiusM,
    bool isActive = true,
  }) async {
    _setLoading();
    try {
      final response = await _repository.upsertVehicleGeofence(
        vehicleId,
        id: id,
        name: name,
        centerLat: centerLat,
        centerLng: centerLng,
        radiusM: radiusM,
        isActive: isActive,
      );
      _message = response.message;
      _markLoaded();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<bool> deleteVehicleGeofence(
    String vehicleId,
    String geofenceId,
  ) async {
    _setLoading();
    try {
      final response = await _repository.deleteVehicleGeofence(
        vehicleId,
        geofenceId,
      );
      _message = response.message;
      _markLoaded();
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  void _resetUploadProgress(int total) {
    _uploadPhotoCurrent = 0;
    _uploadPhotoTotal = total;
    notifyListeners();
  }

  void _updateUploadProgress(int current, int total) {
    _uploadPhotoCurrent = current;
    _uploadPhotoTotal = total;
    notifyListeners();
  }

  void _clearUploadProgress() {
    _uploadPhotoCurrent = 0;
    _uploadPhotoTotal = 0;
    notifyListeners();
  }

  void _setLoading() {
    _status = MitraStatus.loading;
    _message = null;
    notifyListeners();
  }

  void _markLoaded() {
    _status = MitraStatus.loaded;
    notifyListeners();
  }

  void _setFailure(Object error) {
    _lastFailure = error is Failure
        ? error
        : Failure(message: userFacingError(error));
    _message = _lastFailure!.message;
    _status = MitraStatus.failure;
    notifyListeners();
  }

  void clearSessionData() {
    _profile = null;
    _stats = null;
    _earnings = null;
    _earningsHistory = null;
    _reviewsSummary = null;
    _operatingHours = [];
    _vehicles = [];
    _bookings = [];
    _reviews = [];
    _travelSchedules = [];
    _tourPackages = [];
    _status = MitraStatus.initial;
    _message = null;
    notifyListeners();
  }
}
