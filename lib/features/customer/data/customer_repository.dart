import 'models/vehicle_review_aggregate_model.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/paginated_response.dart';
import 'customer_remote_datasource.dart';
import 'models/amenity_model.dart';
import 'models/banner_model.dart';
import 'models/address_model.dart';
import 'models/region_model.dart';
import 'models/blog_model.dart';
import 'models/booking_model.dart';
import 'models/delivery_setting_model.dart';
import 'models/notification_model.dart';
import 'models/payment_channel_model.dart';
import 'models/review_model.dart';
import 'models/tour_model.dart';
import 'models/tourist_destination_model.dart';
import 'models/travel_model.dart';
import 'models/vehicle_model.dart';
import 'models/vehicle_blocked_date_model.dart';
import 'models/voucher_model.dart';
import 'models/customer_payment_model.dart';

class CustomerRepository {
  const CustomerRepository(this._remoteDataSource);

  final CustomerRemoteDataSource _remoteDataSource;

  Future<ApiResponse<List<BannerModel>>> getBanners({String? position}) {
    return _remoteDataSource.getBanners(position: position);
  }

  Future<PaginatedResponse<VehicleModel>> getVehicles({
    String? search, String? type, String? brand, String? transmission,
    String? sort, String? rentalType, String? regencyId,
    bool? isInstantBooking, bool? withDriver,
    double? minPrice, double? maxPrice, double? minRating,
    List<String>? amenityIds,
    String? dateStart, String? dateEnd,
    double? lat, double? lng, double? radiusKm,
    int page = 1, int limit = 10,
  }) {
    return _remoteDataSource.getVehicles(
      search: search, type: type, brand: brand, transmission: transmission,
      sort: sort, rentalType: rentalType, regencyId: regencyId,
      isInstantBooking: isInstantBooking, withDriver: withDriver,
      minPrice: minPrice, maxPrice: maxPrice, minRating: minRating,
      amenityIds: amenityIds, dateStart: dateStart, dateEnd: dateEnd,
      lat: lat, lng: lng, radiusKm: radiusKm,
      page: page, limit: limit,
    );
  }

  Future<ApiResponse<VehicleModel>> getVehicleById(String id) {
    return _remoteDataSource.getVehicleById(id);
  }

  Future<ApiResponse<List<VehicleBlockedDateModel>>> getVehicleAvailability(String id) {
    return _remoteDataSource.getVehicleAvailability(id);
  }

  Future<ApiResponse<List<PaymentChannelModel>>> getPaymentChannels() {
    return _remoteDataSource.getPaymentChannels();
  }

  Future<ApiResponse<BookingCostEstimateModel>> calculateBooking({
    required String vehicleId,
    required String startDate,
    required String endDate,
    bool withDelivery = false,
    String? deliveryAddressId,
    bool isInsured = false,
    String packageType = 'BASIC',
    String type = 'RENTAL',
    String? voucherCode,
    double? destinationLat,
    double? destinationLng,
    String? scheduleId,
    String? tourPackageId,
    List<String>? tourPackageAddons,
    int? seatCount,
  }) {
    return _remoteDataSource.calculateBooking(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      withDelivery: withDelivery,
      deliveryAddressId: deliveryAddressId,
      isInsured: isInsured,
      packageType: packageType,
      type: type,
      voucherCode: voucherCode,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      scheduleId: scheduleId,
      tourPackageId: tourPackageId,
      tourPackageAddons: tourPackageAddons,
      seatCount: seatCount,
    );
  }

  Future<ApiResponse<BookingCostEstimateModel>> calculateDelivery({
    required String vehicleId,
    required String deliveryAddressId,
    required String startDate,
    required String endDate,
    bool isInsured = false,
    String packageType = 'BASIC',
    String? voucherCode,
  }) {
    return _remoteDataSource.calculateDelivery(
      vehicleId: vehicleId,
      deliveryAddressId: deliveryAddressId,
      startDate: startDate,
      endDate: endDate,
      isInsured: isInsured,
      packageType: packageType,
      voucherCode: voucherCode,
    );
  }

  Future<ApiResponse<DeliverySettingModel?>> getActiveDeliverySetting() {
    return _remoteDataSource.getActiveDeliverySetting();
  }

  Future<ApiResponse<BookingModel>> createBooking({
    required String vehicleId,
    required String startDate,
    required String endDate,
    required String paymentChannel,
    bool withDelivery = false,
    String? deliveryAddressId,
    bool isInsured = false,
    String packageType = 'BASIC',
    bool isSelfDrive = true,
    String type = 'RENTAL',
    String? voucherCode,
    double? destinationLat,
    double? destinationLng,
    String? deliveryAddress,
    String? scheduleId,
    String? tourPackageId,
    List<String>? tourPackageAddons,
    List<String>? seats,
    String? driverId,
    Map<String, dynamic>? paymentChannelProperties,
  }) {
    return _remoteDataSource.createBooking(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      paymentChannel: paymentChannel,
      withDelivery: withDelivery,
      deliveryAddressId: deliveryAddressId,
      isInsured: isInsured,
      packageType: packageType,
      isSelfDrive: isSelfDrive,
      type: type,
      voucherCode: voucherCode,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      deliveryAddress: deliveryAddress,
      scheduleId: scheduleId,
      tourPackageId: tourPackageId,
      tourPackageAddons: tourPackageAddons,
      seats: seats,
      driverId: driverId,
      paymentChannelProperties: paymentChannelProperties,
    );
  }

  Future<ApiResponse<List<BookingModel>>> getMyBookings({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) {
    return _remoteDataSource.getMyBookings(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }

  Future<ApiResponse<BookingModel>> getBookingById(String id) {
    return _remoteDataSource.getBookingById(id);
  }

  Future<ApiResponse<void>> cancelBooking(String id, {String? reason}) {
    return _remoteDataSource.cancelBooking(id, reason: reason);
  }

  Future<ApiResponse<void>> uploadBookingDocs(
    String id,
    Map<String, String> documents, {
    Map<String, String> extraFields = const {},
  }) {
    return _remoteDataSource.uploadBookingDocs(
      id,
      documents,
      extraFields: extraFields,
    );
  }

  Future<ApiResponse<List<ReviewModel>>> getVehicleReviews(String vehicleId) {
    return _remoteDataSource.getVehicleReviews(vehicleId);
  }

  Future<ApiResponse<VehicleReviewAggregateModel>> getVehicleReviewsAggregate(String vehicleId) {
    return _remoteDataSource.getVehicleReviewsAggregate(vehicleId);
  }

  Future<ApiResponse<List<ReviewModel>>> getMitraReviews(String mitraId) {
    return _remoteDataSource.getMitraReviews(mitraId);
  }

  Future<ApiResponse<void>> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
    int? ratingCleanliness,
    int? ratingService,
    int? ratingCondition,
  }) {
    return _remoteDataSource.submitReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
      ratingCleanliness: ratingCleanliness,
      ratingService: ratingService,
      ratingCondition: ratingCondition,
    );
  }

  Future<ApiResponse<void>> editReview({
    required String reviewId,
    int? rating,
    String? comment,
    int? ratingCleanliness,
    int? ratingService,
    int? ratingCondition,
  }) {
    return _remoteDataSource.editReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
      ratingCleanliness: ratingCleanliness,
      ratingService: ratingService,
      ratingCondition: ratingCondition,
    );
  }

  // Travel
  Future<ApiResponse<List<TravelScheduleModel>>> searchTravel({
    required String date,
    String? originRegencyId,
    String? destinationRegencyId,
  }) {
    return _remoteDataSource.searchTravel(
      date: date,
      originRegencyId: originRegencyId,
      destinationRegencyId: destinationRegencyId,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTravelRoutes() {
    return _remoteDataSource.getTravelRoutes();
  }

  Future<ApiResponse<TravelSeatAvailabilityModel>> getTravelSeats(
    String scheduleId,
  ) {
    return _remoteDataSource.getTravelSeats(scheduleId);
  }

  Future<ApiResponse<void>> bookTravel({
    required String scheduleId,
    required List<String> seats,
    required String paymentChannel,
  }) {
    return _remoteDataSource.bookTravel(
      scheduleId: scheduleId,
      seats: seats,
      paymentChannel: paymentChannel,
    );
  }

  // Tours
  Future<ApiResponse<List<TourPackageModel>>> getTourPackages() {
    return _remoteDataSource.getTourPackages();
  }

  Future<ApiResponse<TourPackageModel>> getTourPackageById(String id) {
    return _remoteDataSource.getTourPackageById(id);
  }

  Future<ApiResponse<TravelScheduleModel>> getTravelScheduleById(
    String scheduleId,
  ) => _remoteDataSource.getTravelScheduleById(scheduleId);

  Future<ApiResponse<List<RegionItemModel>>> getAddressRegions({
    String? countryId,
    String? provinceId,
    String? regencyId,
    String? districtId,
  }) => _remoteDataSource.getAddressRegions(
    countryId: countryId,
    provinceId: provinceId,
    regencyId: regencyId,
    districtId: districtId,
  );

  Future<ApiResponse<List<AddressModel>>> getMyAddresses() =>
      _remoteDataSource.getMyAddresses();

  Future<ApiResponse<AddressModel>> getAddressById(String id) =>
      _remoteDataSource.getAddressById(id);

  Future<ApiResponse<AddressModel>> createAddress(Map<String, dynamic> data) =>
      _remoteDataSource.createAddress(data);

  Future<ApiResponse<AddressModel>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) => _remoteDataSource.updateAddress(id, data);

  Future<ApiResponse<void>> deleteAddress(String id) =>
      _remoteDataSource.deleteAddress(id);

  Future<ApiResponse<List<NotificationModel>>> getNotifications() =>
      _remoteDataSource.getNotifications();

  Future<ApiResponse<int>> getUnreadNotificationCount() =>
      _remoteDataSource.getUnreadNotificationCount();

  Future<ApiResponse<void>> markNotificationAsRead(String id) =>
      _remoteDataSource.markNotificationAsRead(id);

  Future<ApiResponse<void>> markAllNotificationsAsRead() =>
      _remoteDataSource.markAllNotificationsAsRead();

  Future<ApiResponse<Map<String, dynamic>>> getPaymentStatus(
    String paymentId,
  ) => _remoteDataSource.getPaymentStatus(paymentId);

  Future<ApiResponse<void>> registerDeviceToken(
    String token,
    String platform,
  ) => _remoteDataSource.registerDeviceToken(token, platform);

  Future<ApiResponse<void>> unregisterDeviceToken(String token) =>
      _remoteDataSource.unregisterDeviceToken(token);

  Future<ApiResponse<Map<String, dynamic>>> toggleVehicleFavorite(
    String vehicleId,
  ) => _remoteDataSource.toggleVehicleFavorite(vehicleId);

  Future<ApiResponse<List<VehicleModel>>> getFavoriteVehicles() =>
      _remoteDataSource.getFavoriteVehicles();

  Future<ApiResponse<Map<String, dynamic>>> getMitraPublicProfile(
    String mitraId,
  ) => _remoteDataSource.getMitraPublicProfile(mitraId);

  Future<ApiResponse<void>> followMitra(String mitraId) =>
      _remoteDataSource.followMitra(mitraId);

  Future<ApiResponse<void>> unfollowMitra(String mitraId) =>
      _remoteDataSource.unfollowMitra(mitraId);

  Future<ApiResponse<List<Map<String, dynamic>>>> getFollowingMitra() =>
      _remoteDataSource.getFollowingMitra();

  Future<ApiResponse<int>> getLoyaltyBalance() =>
      _remoteDataSource.getLoyaltyBalance();

  Future<ApiResponse<List<Map<String, dynamic>>>> getLoyaltyHistory() =>
      _remoteDataSource.getLoyaltyHistory();

  Future<ApiResponse<Map<String, dynamic>>> getMyReferralCode() =>
      _remoteDataSource.getMyReferralCode();

  Future<ApiResponse<Map<String, dynamic>>> getHelpCenter() =>
      _remoteDataSource.getHelpCenter();

  Future<ApiResponse<Map<String, dynamic>>> applyReferralCode(String code) =>
      _remoteDataSource.applyReferralCode(code);

  Future<ApiResponse<List<Map<String, dynamic>>>> getCancellationPolicies() =>
      _remoteDataSource.getCancellationPolicies();

  Future<ApiResponse<String>> reverseGeocode(double lat, double lng) =>
      _remoteDataSource.reverseGeocode(lat, lng);

  Future<ApiResponse<void>> bookTour({
    required String tourPackageId,
    required String startDate,
    required String endDate,
    required String paymentChannel,
  }) {
    return _remoteDataSource.bookTour(
      tourPackageId: tourPackageId,
      startDate: startDate,
      endDate: endDate,
      paymentChannel: paymentChannel,
    );
  }

  Future<ApiResponse<List<VoucherModel>>> getAvailableVouchers() =>
      _remoteDataSource.getAvailableVouchers();

  Future<ApiResponse<VoucherModel>> validateVoucher({
    required String code,
    required double amount,
    String? rentalType,
  }) =>
      _remoteDataSource.validateVoucher(
        code: code,
        amount: amount,
        rentalType: rentalType,
      );

  Future<ApiResponse<List<BlogModel>>> getBlogs({
    String? category,
    bool isPublishedOnly = true,
  }) =>
      _remoteDataSource.getBlogs(
        category: category,
        isPublishedOnly: isPublishedOnly,
      );


  Future<ApiResponse<List<AmenityModel>>> getAmenities() =>
      _remoteDataSource.getAmenities();

  Future<ApiResponse<BlogModel>> getBlogBySlug(String slug) =>
      _remoteDataSource.getBlogBySlug(slug);

  Future<ApiResponse<void>> extendBooking(
    String id, {
    int? days,
    Map<String, dynamic>? data,
  }) => _remoteDataSource.extendBooking(id, days: days, data: data);

  Future<ApiResponse<void>> submitBookingLocation(
    String id, {
    required double lat,
    required double lng,
    double? accuracyM,
    double? heading,
    double? speedKmh,
  }) => _remoteDataSource.submitBookingLocation(
    id,
    lat: lat,
    lng: lng,
    accuracyM: accuracyM,
    heading: heading,
    speedKmh: speedKmh,
  );

  Future<ApiResponse<Map<String, dynamic>>> initiatePayment({
    required String bookingId,
    required String paymentChannel,
  }) => _remoteDataSource.initiatePayment(
    bookingId: bookingId,
    paymentChannel: paymentChannel,
  );

  Future<ApiResponse<List<CustomerPaymentModel>>> getMyPayments() =>
      _remoteDataSource.getMyPayments();

  Future<ApiResponse<List<String>>> getTourDestinations() =>
      _remoteDataSource.getTourDestinations();

  Future<ApiResponse<List<TouristDestinationModel>>> getTouristDestinations() =>
      _remoteDataSource.getTouristDestinations();

  Future<ApiResponse<TouristDestinationModel>> getTouristDestinationById(
    String id,
  ) => _remoteDataSource.getTouristDestinationById(id);

  Future<ApiResponse<Map<String, dynamic>>> simulatePayment(String paymentId) =>
      _remoteDataSource.simulatePayment(paymentId);

  Future<ApiResponse<Map<String, dynamic>>> changePaymentMethod({
    required String paymentId,
    required String paymentChannel,
  }) => _remoteDataSource.changePaymentMethod(
    paymentId: paymentId,
    paymentChannel: paymentChannel,
  );
}
