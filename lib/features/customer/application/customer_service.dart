import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/cache/reference_data_cache.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/error_message_util.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/rental_location_share_service.dart';
import '../data/customer_repository.dart';
import '../data/models/amenity_model.dart';
import '../data/models/address_model.dart';
import '../data/models/region_model.dart';
import '../data/models/blog_model.dart';
import '../data/models/booking_model.dart';
import '../data/models/payment_channel_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/review_model.dart';
import '../data/models/tour_model.dart';
import '../data/models/tourist_destination_model.dart';
import '../data/models/travel_model.dart';
import '../data/models/vehicle_model.dart';
import '../data/models/vehicle_blocked_date_model.dart';
import '../data/models/voucher_model.dart';
import '../data/models/customer_payment_model.dart';

enum CustomerStatus { initial, loading, loaded, failure }

class CustomerService extends ChangeNotifier {
  CustomerService(
    this._repository,
    this._realTimeService,
    this._referenceCache,
    this._locationShareService,
  );

  final CustomerRepository _repository;
  final RealTimeService _realTimeService;
  final ReferenceDataCache _referenceCache;
  final RentalLocationShareService _locationShareService;

  CustomerStatus _status = CustomerStatus.initial;
  List<BookingModel> _myBookings = [];
  List<NotificationModel> _notifications = [];
  List<AddressModel> _myAddresses = [];
  List<String> _searchHistory = [];
  int _unreadNotificationCount = 0;
  String? _message;
  String? _customerRealtimeChannel;

  CustomerStatus get status => _status;
  List<BookingModel> get myBookings => List.unmodifiable(_myBookings);
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<AddressModel> get myAddresses => List.unmodifiable(_myAddresses);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  int get unreadNotificationCount => _unreadNotificationCount;
  String? get message => _message;
  String? get errorMessage => _message;

  Future<void> initCustomerRealtime(String userId) async {
    await teardownCustomerRealtime();
    final channel = 'private-user.$userId';
    _customerRealtimeChannel = channel;
    await _realTimeService.pusher.subscribe(
      channelName: channel,
      onEvent: (event) {
        if (event.eventName == 'booking-updated') {
          loadMyBookings();
        } else if (event.eventName == 'payment-paid') {
          _message = 'Pembayaran berhasil!';
          loadMyBookings();
        }
      },
    );
  }

  Future<void> teardownCustomerRealtime() async {
    final channel = _customerRealtimeChannel;
    if (channel == null) return;
    await _realTimeService.pusher.unsubscribe(channelName: channel);
    _customerRealtimeChannel = null;
  }

  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _searchHistory = prefs.getStringList('search_history') ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    final cleanQuery = query.trim();
    _searchHistory.remove(
      cleanQuery,
    ); // Remove if already exists to move to top
    _searchHistory.insert(0, cleanQuery);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);
    } catch (_) {}
  }

  Future<void> clearSearchHistory() async {
    _searchHistory = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
    } catch (_) {}
  }

  Future<List<PaymentChannelModel>> getPaymentChannels() async {
    try {
      return await _referenceCache.getPaymentChannels();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCancellationPolicies() async {
    try {
      return await _referenceCache.getCancellationPolicies();
    } catch (_) {
      return [];
    }
  }

  Future<List<AmenityModel>> getAmenities() async {
    try {
      return await _referenceCache.getAmenities();
    } catch (_) {
      return [];
    }
  }

  Future<void> loadMyBookings({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) async {
    _status = CustomerStatus.loading;
    _message = null;
    notifyListeners();

    try {
      final response = await _repository.getMyBookings(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
      _myBookings = response.data ?? [];
      _syncRentalLocationSharing();
      _status = CustomerStatus.loaded;
    } catch (error) {
      _message = userFacingError(error);
      _status = CustomerStatus.failure;
    }
    notifyListeners();
  }

  void _syncRentalLocationSharing() {
    _locationShareService.syncHandoverBookings(
      _myBookings
          .map(
            (b) => (id: b.id, status: b.status ?? '', isShuttle: b.isShuttle),
          )
          .toList(),
    );
  }

  Future<void> loadNotifications() async {
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      final response = await _repository.getNotifications();
      _notifications = response.data ?? [];
      await loadUnreadCount();
      _status = CustomerStatus.loaded;
    } catch (e) {
      _status = CustomerStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    try {
      final response = await _repository.getUnreadNotificationCount();
      _unreadNotificationCount = response.data ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          priority: _notifications[index].priority,
          actionLink: _notifications[index].actionLink,
          actionLabel: _notifications[index].actionLabel,
          data: _notifications[index].data,
          createdAt: _notifications[index].createdAt,
          isRead: true,
          readAt: _notifications[index].readAt,
        );
        _unreadNotificationCount = (_unreadNotificationCount - 1).clamp(0, 999);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      _notifications = _notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              priority: n.priority,
              actionLink: n.actionLink,
              actionLabel: n.actionLabel,
              data: n.data,
              createdAt: n.createdAt,
              isRead: true,
              readAt: n.readAt,
            ),
          )
          .toList();
      _unreadNotificationCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<BookingModel?> getBookingById(String id) async {
    try {
      final response = await _repository.getBookingById(id);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _repository.getPaymentStatus(paymentId);
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<List<CustomerPaymentModel>> getMyPayments() async {
    try {
      final response = await _repository.getMyPayments();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> initiatePayment({
    required String bookingId,
    required String paymentChannel,
  }) async {
    try {
      final response = await _repository.initiatePayment(
        bookingId: bookingId,
        paymentChannel: paymentChannel,
      );
      return response.data;
    } catch (e) {
      _message = userFacingError(e);
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> simulatePayment(String paymentId) async {
    try {
      final response = await _repository.simulatePayment(paymentId);
      return response.data;
    } catch (e) {
      _message = userFacingError(e);
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> changePaymentMethod({
    required String paymentId,
    required String paymentChannel,
  }) async {
    try {
      final response = await _repository.changePaymentMethod(
        paymentId: paymentId,
        paymentChannel: paymentChannel,
      );
      return response.data;
    } catch (e) {
      _message = userFacingError(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> extendBooking(String id, [dynamic arg]) async {
    try {
      if (arg is int) {
        await _repository.extendBooking(id, days: arg);
      } else if (arg is Map<String, dynamic>) {
        await _repository.extendBooking(id, data: arg);
      } else {
        await _repository.extendBooking(id, days: 1);
      }
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerDeviceToken(String token, String platform) async {
    try {
      await _repository.registerDeviceToken(token, platform);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getTourDestinations() async {
    try {
      final response = await _repository.getTourDestinations();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<TouristDestinationModel>> getTouristDestinations() async {
    try {
      final response = await _repository.getTouristDestinations();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<TouristDestinationModel?> getTouristDestinationById(String id) async {
    try {
      final response = await _repository.getTouristDestinationById(id);
      return response.data;
    } catch (_) {
      final destinations = await getTouristDestinations();
      for (final d in destinations) {
        if (d.id == id) return d;
      }
      return null;
    }
  }

  Future<List<AddressModel>> getMyAddresses() async {
    _status = CustomerStatus.loading;
    notifyListeners();
    try {
      final response = await _repository.getMyAddresses();
      _myAddresses = response.data ?? [];
      _status = CustomerStatus.loaded;
      notifyListeners();
      return _myAddresses;
    } catch (e) {
      _message = userFacingError(e);
      _status = CustomerStatus.failure;
      notifyListeners();
      return _myAddresses;
    }
  }

  Future<AddressModel?> getAddressById(String id) async {
    try {
      final response = await _repository.getAddressById(id);
      return response.data;
    } catch (e) {
      _message = userFacingError(e);
      return null;
    }
  }

  Future<bool> createAddress(Map<String, dynamic> data) async {
    _status = CustomerStatus.loading;
    notifyListeners();
    try {
      final response = await _repository.createAddress(data);
      if (response.data != null) {
        _myAddresses = [response.data!, ..._myAddresses];
      }
      _status = CustomerStatus.loaded;
      _message = 'Alamat berhasil ditambahkan';
      notifyListeners();
      return true;
    } catch (e) {
      _message = userFacingError(e);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    _status = CustomerStatus.loading;
    notifyListeners();
    try {
      final response = await _repository.updateAddress(id, data);
      if (response.data != null) {
        final index = _myAddresses.indexWhere((a) => a.id == id);
        if (index != -1) {
          _myAddresses[index] = response.data!;
        }
      }
      _status = CustomerStatus.loaded;
      _message = 'Alamat berhasil diperbarui';
      notifyListeners();
      return true;
    } catch (e) {
      _message = userFacingError(e);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      await _repository.deleteAddress(id);
      _myAddresses.removeWhere((a) => a.id == id);
      _message = 'Alamat berhasil dihapus';
      notifyListeners();
      return true;
    } catch (e) {
      _message = userFacingError(e);
      notifyListeners();
      return false;
    }
  }

  Future<List<RegionItemModel>> getRegionsHierarchy({
    String? countryId,
    String? provinceId,
    String? regencyId,
    String? districtId,
  }) async {
    try {
      return await _referenceCache.getRegions(
        countryId: countryId,
        provinceId: provinceId,
        regencyId: regencyId,
        districtId: districtId,
      );
    } catch (e) {
      _message = userFacingError(e);
      return [];
    }
  }

  Future<bool> cancelBooking(String id, {String? reason}) async {
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      await _repository.cancelBooking(id, reason: reason);
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadBookingDocs(
    String id,
    Map<String, String> documents, {
    Map<String, String> extraFields = const {},
  }) async {
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      await _repository.uploadBookingDocs(
        id,
        documents,
        extraFields: extraFields,
      );
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<List<ReviewModel>> getVehicleReviews(String vehicleId) async {
    try {
      final response = await _repository.getVehicleReviews(vehicleId);
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ReviewModel>> getMitraReviews(String mitraId) async {
    try {
      final response = await _repository.getMitraReviews(mitraId);
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<VehicleBlockedDateModel>> getVehicleAvailability(
    String vehicleId,
  ) async {
    try {
      final response = await _repository.getVehicleAvailability(vehicleId);
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
    int? ratingCleanliness,
    int? ratingService,
    int? ratingCondition,
  }) async {
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      await _repository.submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
        ratingCleanliness: ratingCleanliness,
        ratingService: ratingService,
        ratingCondition: ratingCondition,
      );
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editReview({
    required String reviewId,
    int? rating,
    String? comment,
    int? ratingCleanliness,
    int? ratingService,
    int? ratingCondition,
  }) async {
    try {
      await _repository.editReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
        ratingCleanliness: ratingCleanliness,
        ratingService: ratingService,
        ratingCondition: ratingCondition,
      );
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      notifyListeners();
      return false;
    }
  }

  // Travel & Tours
  Future<List<TravelRouteModel>> getTravelRoutes() async {
    try {
      final response = await _repository.getTravelRoutes();
      return (response.data ?? []).map(TravelRouteModel.fromJson).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TravelScheduleModel>> searchTravel({
    required String date,
    String? originRegencyId,
    String? destinationRegencyId,
  }) async {
    try {
      final response = await _repository.searchTravel(
        originRegencyId: originRegencyId,
        destinationRegencyId: destinationRegencyId,
        date: date,
      );
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<TravelSeatAvailabilityModel?> getTravelSeats(String scheduleId) async {
    try {
      final response = await _repository.getTravelSeats(scheduleId);
      return response.data;
    } catch (e) {
      _message = userFacingError(e);
      notifyListeners();
      return null;
    }
  }

  Future<TravelScheduleModel?> getTravelScheduleById(String scheduleId) async {
    try {
      final response = await _repository.getTravelScheduleById(scheduleId);
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<List<TourPackageModel>> getTourPackages() async {
    try {
      final response = await _repository.getTourPackages();
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<VoucherModel>> getAvailableVouchers() async {
    try {
      final response = await _repository.getAvailableVouchers();
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<BlogModel>> getBlogs({String? category}) async {
    try {
      final response = await _repository.getBlogs(category: category);
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<BlogModel?> getBlogBySlug(String slug) async {
    try {
      final response = await _repository.getBlogBySlug(slug);
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> bookTour({
    required String tourPackageId,
    required String startDate,
    required String endDate,
    required String paymentChannel,
  }) async {
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      await _repository.bookTour(
        tourPackageId: tourPackageId,
        startDate: startDate,
        endDate: endDate,
        paymentChannel: paymentChannel,
      );
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool?> toggleVehicleFavorite(String vehicleId) async {
    try {
      final response = await _repository.toggleVehicleFavorite(vehicleId);
      notifyListeners();
      return response.data?['favorited'] == true;
    } catch (error) {
      _message = userFacingError(error);
      notifyListeners();
      return null;
    }
  }

  Future<List<VehicleModel>> getFavoriteVehicles() async {
    try {
      final response = await _repository.getFavoriteVehicles();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMitraPublicProfile(String mitraId) async {
    try {
      final response = await _repository.getMitraPublicProfile(mitraId);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<bool> followMitra(String mitraId, {required bool follow}) async {
    try {
      if (follow) {
        await _repository.followMitra(mitraId);
      } else {
        await _repository.unfollowMitra(mitraId);
      }
      return true;
    } catch (error) {
      _message = userFacingError(error);
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFollowingMitra() async {
    try {
      final response = await _repository.getFollowingMitra();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<int> getLoyaltyBalance() async {
    try {
      final response = await _repository.getLoyaltyBalance();
      return response.data ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getLoyaltyHistory() async {
    try {
      final response = await _repository.getLoyaltyHistory();
      return response.data ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMyReferralCode() async {
    try {
      final response = await _repository.getMyReferralCode();
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<bool> applyReferralCode(String code) async {
    try {
      await _repository.applyReferralCode(code.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getHelpCenter() async {
    try {
      final response = await _repository.getHelpCenter();
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<bool> bookTravel({
    required String scheduleId,
    required List<String> seats,
    required String paymentChannel,
  }) async {
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      await _repository.bookTravel(
        scheduleId: scheduleId,
        seats: seats,
        paymentChannel: paymentChannel,
      );
      await loadMyBookings();
      return true;
    } catch (error) {
      _message = userFacingError(error);
      _status = CustomerStatus.failure;
      notifyListeners();
      return false;
    }
  }

  Future<VoucherModel?> validateVoucher({
    required String code,
    required double amount,
    String? rentalType,
  }) async {
    try {
      final response = await _repository.validateVoucher(
        code: code,
        amount: amount,
        rentalType: rentalType,
      );
      return response.data;
    } catch (error) {
      _message = userFacingError(error);
      return null;
    }
  }
}
