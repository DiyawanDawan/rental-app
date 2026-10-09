import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/upload_executor.dart';
import '../../../core/network/paginated_response.dart';
import 'models/amenity_model.dart';
import 'models/banner_model.dart';
import 'models/booking_model.dart';
import 'models/address_model.dart';
import 'models/delivery_setting_model.dart';
import 'models/region_model.dart';
import 'models/blog_model.dart';
import 'models/notification_model.dart';
import 'models/payment_channel_model.dart';
import 'models/review_model.dart';
import 'models/tour_model.dart';
import 'models/tourist_destination_model.dart';
import 'models/travel_model.dart';
import 'models/vehicle_model.dart';
import 'models/vehicle_blocked_date_model.dart';
import 'models/voucher_model.dart';
import 'models/vehicle_review_aggregate_model.dart';
import 'models/customer_payment_model.dart';

class CustomerRemoteDataSource {
  const CustomerRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse<List<BannerModel>>> getBanners({String? position}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.banners,
      queryParameters: {if (position != null) 'position': position},
    );

    return ApiResponse<List<BannerModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(BannerModel.fromJson)
                .toList()
          : <BannerModel>[],
    );
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
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vehicles,
      queryParameters: {
        'page': page,
        'limit': limit,
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
      response.data ?? <String, dynamic>{},
      (json) => VehicleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<VehicleModel>> getVehicleById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vehicleById(id),
    );

    return ApiResponse<VehicleModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => VehicleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<VehicleBlockedDateModel>>> getVehicleAvailability(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vehicleAvailability(id),
    );

    return ApiResponse<List<VehicleBlockedDateModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleBlockedDateModel.fromJson)
          .toList(),
    );
  }

  Future<ApiResponse<List<PaymentChannelModel>>> getPaymentChannels() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.paymentChannels,
    );

    return ApiResponse<List<PaymentChannelModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(PaymentChannelModel.fromJson)
                .toList()
          : <PaymentChannelModel>[],
    );
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
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.bookingCalculate,
      queryParameters: {
        if (vehicleId.isNotEmpty) 'vehicleId': vehicleId,
        'startDate': startDate,
        'endDate': endDate,
        if (withDelivery) 'withDelivery': 'true',
        if (deliveryAddressId != null && deliveryAddressId.isNotEmpty)
          'deliveryAddressId': deliveryAddressId,
        'isInsured': isInsured.toString(),
        'packageType': packageType,
        'type': type,
        if (voucherCode != null && voucherCode.isNotEmpty)
          'voucherCode': voucherCode,
        if (destinationLat != null) 'destinationLat': destinationLat.toString(),
        if (destinationLng != null) 'destinationLng': destinationLng.toString(),
        if (scheduleId != null && scheduleId.isNotEmpty)
          'scheduleId': scheduleId,
        if (tourPackageId != null && tourPackageId.isNotEmpty)
          'tourPackageId': tourPackageId,
        if (tourPackageAddons != null && tourPackageAddons.isNotEmpty)
          'tourPackageAddons': tourPackageAddons,
        if (seatCount != null) 'seatCount': seatCount.toString(),
      },
    );

    return ApiResponse<BookingCostEstimateModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BookingCostEstimateModel.fromJson(json as Map<String, dynamic>),
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
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.deliveryCalculate,
      data: {
        'vehicleId': vehicleId,
        'deliveryAddressId': deliveryAddressId,
        'startDate': startDate,
        'endDate': endDate,
        'isInsured': isInsured,
        'packageType': packageType,
        if (voucherCode != null && voucherCode.isNotEmpty)
          'voucherCode': voucherCode,
      },
    );

    return ApiResponse<BookingCostEstimateModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BookingCostEstimateModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<DeliverySettingModel?>> getActiveDeliverySetting() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.deliveryActiveSetting,
    );

    return ApiResponse<DeliverySettingModel?>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic>
          ? DeliverySettingModel.fromJson(json)
          : null,
    );
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
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.bookings,
      data: {
        if (vehicleId.isNotEmpty) 'vehicleId': vehicleId,
        'startDate': startDate,
        'endDate': endDate,
        'withDelivery': withDelivery,
        if (deliveryAddressId != null && deliveryAddressId.isNotEmpty)
          'deliveryAddressId': deliveryAddressId,
        'isSelfDrive': isSelfDrive,
        'isInsured': isInsured,
        'packageType': packageType,
        'type': type,
        'paymentChannel': paymentChannel,
        if (voucherCode != null && voucherCode.isNotEmpty)
          'voucherCode': voucherCode,
        if (destinationLat != null) 'destinationLat': destinationLat,
        if (destinationLng != null) 'destinationLng': destinationLng,
        if (deliveryAddress != null && deliveryAddress.isNotEmpty)
          'deliveryAddress': deliveryAddress,
        if (scheduleId != null && scheduleId.isNotEmpty)
          'scheduleId': scheduleId,
        if (tourPackageId != null && tourPackageId.isNotEmpty)
          'tourPackageId': tourPackageId,
        if (tourPackageAddons != null && tourPackageAddons.isNotEmpty)
          'tourPackageAddons': tourPackageAddons,
        if (seats != null && seats.isNotEmpty) 'seats': seats,
        if (driverId != null && driverId.isNotEmpty) 'driverId': driverId,
        if (paymentChannelProperties != null)
          'paymentChannelProperties': paymentChannelProperties,
      },
    );

    return ApiResponse<BookingModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<BookingModel>>> getMyBookings({
    int? page,
    int? limit,
    String? status,
    String? search,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.myBookings,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    return ApiResponse<List<BookingModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(BookingModel.fromJson)
                .toList()
          : <BookingModel>[],
    );
  }

  Future<ApiResponse<BookingModel>> getBookingById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.bookingById(id),
    );

    return ApiResponse<BookingModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> cancelBooking(String id, {String? reason}) async {
    final validReason = (reason != null && reason.trim().length >= 5)
        ? reason.trim()
        : 'Dibatalkan oleh pelanggan';
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.bookingCancel(id),
      data: {'reason': validReason},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> uploadBookingDocs(
    String id,
    Map<String, String> documents, {
    Map<String, String> extraFields = const {},
  }) async {
    final executor = UploadExecutor(_apiClient);

    for (final entry in documents.entries) {
      await executor.uploadNamedDocument(
        endpoint: ApiEndpoints.bookingUploadDocs(id),
        fieldName: entry.key,
        filePath: entry.value,
        extraFields: extraFields,
      );
    }

    return ApiResponse<void>.fromJson(<String, dynamic>{}, (_) {});
  }

  Future<ApiResponse<List<ReviewModel>>> getVehicleReviews(
    String vehicleId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.reviewVehicle(vehicleId),
    );

    return ApiResponse<List<ReviewModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      ReviewModel.listFromResponse,
    );
  }

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

  Future<ApiResponse<List<ReviewModel>>> getMitraReviews(String mitraId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.reviewMitra(mitraId),
    );

    return ApiResponse<List<ReviewModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      ReviewModel.listFromResponse,
    );
  }

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

  Future<ApiResponse<void>> editReview({
    required String reviewId,
    int? rating,
    String? comment,
    int? ratingCleanliness,
    int? ratingService,
    int? ratingCondition,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.reviewById(reviewId),
      data: {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
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



  // Travel
  Future<ApiResponse<List<Map<String, dynamic>>>> getTravelRoutes() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.travelRoutes,
    );

    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as List).whereType<Map<String, dynamic>>().toList(),
    );
  }

  Future<ApiResponse<List<TravelScheduleModel>>> searchTravel({
    required String date,
    String? originRegencyId,
    String? destinationRegencyId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.travelSearch,
      queryParameters: {
        'date': date,
        if (originRegencyId != null && originRegencyId.isNotEmpty)
          'originRegencyId': originRegencyId,
        if (destinationRegencyId != null && destinationRegencyId.isNotEmpty)
          'destinationRegencyId': destinationRegencyId,
      },
    );

    return ApiResponse<List<TravelScheduleModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(TravelScheduleModel.fromJson)
                .toList()
          : <TravelScheduleModel>[],
    );
  }

  Future<ApiResponse<TravelScheduleModel>> getTravelScheduleById(
    String scheduleId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.travelScheduleById(scheduleId),
    );

    return ApiResponse<TravelScheduleModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => TravelScheduleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<TravelSeatAvailabilityModel>> getTravelSeats(
    String scheduleId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.travelScheduleSeats(scheduleId),
    );

    return ApiResponse<TravelSeatAvailabilityModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) =>
          TravelSeatAvailabilityModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> bookTravel({
    required String scheduleId,
    required List<String> seats,
    required String paymentChannel,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.travelBook,
      data: {
        'scheduleId': scheduleId,
        'seats': seats,
        'paymentMethod': paymentChannel,
        'paymentChannel': paymentChannel,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  // Tour Packages
  Future<ApiResponse<List<TouristDestinationModel>>>
  getTouristDestinations() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.tourDestinations,
    );

    return ApiResponse<List<TouristDestinationModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(TouristDestinationModel.fromJson)
                .where((d) => d.id.isNotEmpty)
                .toList()
          : <TouristDestinationModel>[],
    );
  }

  Future<ApiResponse<TouristDestinationModel>> getTouristDestinationById(
    String id,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.tourDestinationById(id),
    );

    return ApiResponse<TouristDestinationModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => TouristDestinationModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<String>>> getTourDestinations() async {
    final response = await getTouristDestinations();
    return ApiResponse<List<String>>(
      success: response.success,
      status: response.status,
      message: response.message,
      data: response.data
          ?.map((d) => d.name)
          .where((n) => n.isNotEmpty)
          .toList(),
    );
  }

  Future<ApiResponse<List<TourPackageModel>>> getTourPackages() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.tourPackages,
    );

    return ApiResponse<List<TourPackageModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(TourPackageModel.fromJson)
                .toList()
          : <TourPackageModel>[],
    );
  }

  Future<ApiResponse<TourPackageModel>> getTourPackageById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.tourPackageById(id),
    );

    return ApiResponse<TourPackageModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => TourPackageModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // Addresses
  Future<ApiResponse<List<RegionItemModel>>> getAddressRegions({
    String? countryId,
    String? provinceId,
    String? regencyId,
    String? districtId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.addressRegions,
      queryParameters: {
        if (countryId != null && countryId.isNotEmpty) 'countryId': countryId,
        if (provinceId != null && provinceId.isNotEmpty)
          'provinceId': provinceId,
        if (regencyId != null && regencyId.isNotEmpty) 'regencyId': regencyId,
        if (districtId != null && districtId.isNotEmpty)
          'districtId': districtId,
      },
    );

    return ApiResponse<List<RegionItemModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(RegionItemModel.fromJson)
                .toList()
          : <RegionItemModel>[],
    );
  }

  Future<ApiResponse<List<AddressModel>>> getMyAddresses() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.addressesMy,
    );

    return ApiResponse<List<AddressModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(AddressModel.fromJson)
                .toList()
          : <AddressModel>[],
    );
  }

  Future<ApiResponse<AddressModel>> getAddressById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.addressById(id),
    );

    return ApiResponse<AddressModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic>
          ? AddressModel.fromJson(json)
          : throw const FormatException('Format respon alamat tidak valid'),
    );
  }

  Future<ApiResponse<AddressModel>> createAddress(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.addresses,
      data: data,
    );

    return ApiResponse<AddressModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic>
          ? AddressModel.fromJson(json)
          : throw const FormatException('Format respon alamat tidak valid'),
    );
  }

  Future<ApiResponse<AddressModel>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.addressById(id),
      data: data,
    );

    return ApiResponse<AddressModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic>
          ? AddressModel.fromJson(json)
          : throw const FormatException('Format respon alamat tidak valid'),
    );
  }

  Future<ApiResponse<void>> deleteAddress(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.addressById(id),
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  // Notifications
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
    );

    return ApiResponse<List<NotificationModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(NotificationModel.fromJson)
                .toList()
          : <NotificationModel>[],
    );
  }

  Future<ApiResponse<int>> getUnreadNotificationCount() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.notificationUnreadCount,
    );

    return ApiResponse<int>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map
          ? int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0
          : int.tryParse(json?.toString() ?? '0') ?? 0,
    );
  }

  Future<ApiResponse<void>> markNotificationAsRead(String id) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.notificationMarkRead(id),
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> markAllNotificationsAsRead() async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.notificationReadAll,
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPaymentStatus(
    String paymentId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.paymentStatus(paymentId),
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> registerDeviceToken(
    String token,
    String platform,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.registerDevice,
      data: {'fcmToken': token, 'platform': platform},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleVehicleFavorite(
    String vehicleId,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.vehicleFavorite(vehicleId),
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<List<VehicleModel>>> getFavoriteVehicles() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vehicleFavorites,
    );
    return ApiResponse<List<VehicleModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(VehicleModel.fromJson)
                .toList()
          : <VehicleModel>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMitraPublicProfile(
    String mitraId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraStorePublic(mitraId),
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<void>> followMitra(String mitraId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mitraStoreFollow(mitraId),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> unfollowMitra(String mitraId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.mitraStoreFollow(mitraId),
    );
    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getFollowingMitra() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mitraStoresFollowing,
    );
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<int>> getLoyaltyBalance() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.loyaltyBalance,
    );
    return ApiResponse<int>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => ((json is Map ? json['balance'] : json) as num?)?.toInt() ?? 0,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getLoyaltyHistory() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.loyaltyHistory,
    );
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyReferralCode() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.loyaltyReferralMe,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> applyReferralCode(
    String code,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.loyaltyReferralApply,
      data: {'code': code},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getHelpCenter() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.contentHelp,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
    );
  }

  Future<ApiResponse<void>> unregisterDeviceToken(String token) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.registerDevice,
      data: {'fcmToken': token},
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> extendBooking(
    String id, {
    int? days,
    Map<String, dynamic>? data,
  }) async {
    final payload = data ?? {'days': days ?? 1};
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.bookingExtend(id),
      data: payload,
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<void>> submitBookingLocation(
    String id, {
    required double lat,
    required double lng,
    double? accuracyM,
    double? heading,
    double? speedKmh,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.bookingLocation(id),
      data: {
        'lat': lat,
        'lng': lng,
        if (accuracyM != null) 'accuracyM': accuracyM,
        if (heading != null) 'heading': heading,
        if (speedKmh != null) 'speedKmh': speedKmh,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> initiatePayment({
    required String bookingId,
    required String paymentChannel,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.paymentInitiate,
      data: {
        'bookingId': bookingId,
        'channelCode': paymentChannel,
        'paymentChannel': paymentChannel,
      },
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json as Map<String, dynamic>,
    );
  }



  Future<ApiResponse<List<CustomerPaymentModel>>> getMyPayments() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.paymentsMy,
    );

    return ApiResponse<List<CustomerPaymentModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
              .whereType<Map<String, dynamic>>()
              .map(CustomerPaymentModel.fromJson)
              .toList()
          : <CustomerPaymentModel>[],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> simulatePayment(
    String paymentId,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.paymentSimulate(paymentId),
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> changePaymentMethod({
    required String paymentId,
    required String paymentChannel,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.paymentChangeMethod(paymentId),
      data: {
        'newChannelCode': paymentChannel,
        'channelCode': paymentChannel,
        'paymentChannel': paymentChannel,
      },
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>>
  getCancellationPolicies() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.cancellationPolicies,
    );
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[],
    );
  }

  Future<ApiResponse<String>> reverseGeocode(double lat, double lng) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.geocoding,
      queryParameters: {'lat': lat, 'lng': lng},
    );

    return ApiResponse<String>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => (json as Map<String, dynamic>)['address']?.toString() ?? '',
    );
  }

  Future<ApiResponse<void>> bookTour({
    required String tourPackageId,
    required String startDate,
    required String endDate,
    required String paymentChannel,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.bookings,
      data: {
        'tourPackageId': tourPackageId,
        'startDate': startDate,
        'endDate': endDate,
        'type': 'TOUR_PACKAGE',
        'paymentChannel': paymentChannel,
      },
    );

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }

  // Marketing & Content
  Future<ApiResponse<List<VoucherModel>>> getAvailableVouchers() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vouchersAvailable,
    );

    return ApiResponse<List<VoucherModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(VoucherModel.fromJson)
                .toList()
          : <VoucherModel>[],
    );
  }

  Future<ApiResponse<VoucherModel>> validateVoucher({
    required String code,
    required double amount,
    String? rentalType,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.voucherValidate,
      data: {
        'code': code.trim(),
        'amount': amount,
        if (rentalType != null && rentalType.isNotEmpty) 'rentalType': rentalType,
      },
    );

    return ApiResponse<VoucherModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is Map<String, dynamic>
          ? VoucherModel.fromJson(json)
          : throw const FormatException('Format respon voucher tidak valid'),
    );
  }

  Future<ApiResponse<List<BlogModel>>> getBlogs({
    String? category,
    bool isPublishedOnly = true,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.blogs,
      queryParameters: {
        if (isPublishedOnly) 'isPublished': 'true',
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );

    return ApiResponse<List<BlogModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(BlogModel.fromJson)
                .toList()
          : <BlogModel>[],
    );
  }

  Future<ApiResponse<List<AmenityModel>>> getAmenities() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.vehicleAmenities,
    );

    return ApiResponse<List<AmenityModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
                .whereType<Map<String, dynamic>>()
                .map(AmenityModel.fromJson)
                .where((a) => a.id.isNotEmpty)
                .toList()
          : <AmenityModel>[],
    );
  }

  Future<ApiResponse<BlogModel>> getBlogBySlug(String slug) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.blogBySlug(slug),
    );

    return ApiResponse<BlogModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BlogModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
