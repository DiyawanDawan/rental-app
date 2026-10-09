class AppRoutePaths {
  const AppRoutePaths._();

  static const String home = '/';
  static const String search = '/search';
  static const String onboarding = '/onboarding';
  static const String health = '/health';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String kyc = '/kyc';
  static const String wallet = '/wallet';
  static const String notifications = '/notifications';
  static const String cancellationPolicy = '/cancellation-policy';
  static const String helpCenter = '/help-center';
  static const String chat = '/chat';
  static const String chatMessagesPattern = '/chat/:id';
  static const String addresses = '/addresses';
  static const String addressForm = '/addresses/form';
  static const String blogs = '/blogs';
  static const String blogDetailPattern = '/blogs/:slug';
  static const String destinations = '/destinations';
  static const String destinationDetailPattern = '/destinations/:id';
  static const String vehicles = '/vehicles';
  static const String vehicleDetailPattern = '/vehicles/:id';
  static const String travelSearch = '/travel';
  static const String travelSchedules = '/travel/schedules';
  static const String travelSeatPickerPattern = '/travel/schedules/:id/seats';
  static const String travelCheckout = '/travel/checkout';
  static const String tourPackages = '/tours';
  static const String tourPackageDetailPattern = '/tours/:id';
  static const String tourBookPattern = '/tours/:id/book';
  static const String bookings = '/bookings';
  static const String bookingDetailPattern = '/bookings/:id';
  static const String submitReviewPattern = '/bookings/:id/review';
  static const String createBookingPattern = '/bookings/create/:vehicleId';

  // Mitra
  static const String mitraDashboard = '/mitra';
  static const String mitraVehicles = '/mitra/vehicles';
  static const String mitraAddVehicle = '/mitra/vehicles/add';
  static const String mitraEditVehiclePattern = '/mitra/vehicles/:id/edit';
  static const String mitraVehiclePhotosPattern = '/mitra/vehicles/:id/photos';
  static const String mitraVehiclePricingPattern = '/mitra/vehicles/:id/pricing';
  static const String mitraVehicleBlockedDatesPattern = '/mitra/vehicles/:id/blocked-dates';
  static const String mitraVehicleSeatMapPattern = '/mitra/vehicles/:id/seat-map';
  static const String mitraBookings = '/mitra/bookings';
  static const String mitraDrivers = '/mitra/drivers';
  static const String mitraProfile = '/mitra/profile';
  static const String mitraEarnings = '/mitra/earnings';
  static const String mitraOperatingHours = '/mitra/operating-hours';
  static const String mitraReviews = '/mitra/reviews';
  static const String mitraTravelSchedules = '/mitra/travel-schedules';
  static const String favorites = '/favorites';
  static const String following = '/following';
  static const String loyaltyHistory = '/loyalty/history';
  static const String vouchers = '/vouchers';
  static const String mitraTourPackages = '/mitra/tour-packages';
  static const String mitraTourPackageForm = '/mitra/tour-packages/form';
  static const String mitraDestinationForm = '/mitra/destinations/form';
  static const String mitraSubscription = '/mitra/subscription';
  static const String mitraTracking = '/mitra/tracking';
  static const String mitraVehicleGpsPattern = '/mitra/vehicles/:id/gps';
  static const String mitraVehicleGeofencePattern = '/mitra/vehicles/:id/geofence';
  static const String mitraPublicProfilePattern = '/mitra-stores/:id';
  static const String walletTopup = '/wallet/topup';
  static const String paymentHistory = '/payments/history';
  static const String walletBanks = '/wallet/banks';

  static String vehicleDetail(String id) => '/vehicles/$id';
  static String vehiclesWithQuery({
    String? type,
    String? transmission,
    String? search,
    String? sort,
    double? lat,
    double? lng,
    bool minRatingFour = false,
  }) {
    final params = <String, String>{};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (transmission != null && transmission.isNotEmpty) params['transmission'] = transmission;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (minRatingFour) params['minRating'] = '4';
    if (params.isEmpty) return vehicles;
    return '$vehicles?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
  }
  static String travelSchedulesWithQuery({
    required String origin,
    required String destination,
    required String date,
    String? originRegencyId,
    String? destinationRegencyId,
  }) {
    final params = <String, String>{
      'origin': origin,
      'destination': destination,
      'date': date,
      if (originRegencyId != null && originRegencyId.isNotEmpty) 'originRegencyId': originRegencyId,
      if (destinationRegencyId != null && destinationRegencyId.isNotEmpty)
        'destinationRegencyId': destinationRegencyId,
    };
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$travelSchedules?$query';
  }
  static String travelSearchWithQuery({String? destination}) {
    if (destination == null || destination.isEmpty) return travelSearch;
    return '$travelSearch?destination=${Uri.encodeComponent(destination)}';
  }
  static String travelScheduleSeats(String scheduleId) => '/travel/schedules/$scheduleId/seats';
  static String createBooking(String vehicleId) => '/bookings/create/$vehicleId';
  static String bookingDetail(String id) => '/bookings/$id';
  static String bookingsWithQuery({String? status}) {
    if (status == null || status.isEmpty) return bookings;
    return '$bookings?status=${Uri.encodeComponent(status)}';
  }
  static String blogDetail(String slug) => '/blogs/$slug';
  static String destinationDetail(String id) => '/destinations/$id';
  static String destinationsWithQuery({String? q}) {
    if (q == null || q.isEmpty) return destinations;
    return '$destinations?q=${Uri.encodeComponent(q)}';
  }
  static String blogsWithQuery({String? category, String? q}) {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (params.isEmpty) return blogs;
    return '$blogs?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
  }
  static String submitReview(String bookingId, {String vehicleName = ''}) {
    final encoded = Uri.encodeComponent(vehicleName);
    return '/bookings/$bookingId/review?vehicleName=$encoded';
  }
  static String tourDetail(String id) => '/tours/$id';
  static String tourPackagesWithQuery({String? q, String? sort, String? destination}) {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    if (destination != null && destination.isNotEmpty) params['destination'] = destination;
    if (params.isEmpty) return tourPackages;
    return '$tourPackages?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
  }
  static String searchWithQuery({String? q}) {
    if (q == null || q.isEmpty) return search;
    return '$search?q=${Uri.encodeComponent(q)}';
  }
  static String tourBook(String id) => '/tours/$id/book';
  static String chatMessages(String id, {String name = 'Chat'}) =>
      '/chat/$id?name=${Uri.encodeComponent(name)}';
  static String mitraPublicProfile(String id) => '/mitra-stores/$id';
  static String mitraEditVehicle(String id) => '/mitra/vehicles/$id/edit';
  static String mitraVehiclePhotos(String id) => '/mitra/vehicles/$id/photos';
  static String mitraVehiclePricing(String id) => '/mitra/vehicles/$id/pricing';
  static String mitraVehicleBlockedDates(String id) => '/mitra/vehicles/$id/blocked-dates';
  static String mitraVehicleSeatMap(String id) => '/mitra/vehicles/$id/seat-map';
  static String mitraVehicleGps(String id) => '/mitra/vehicles/$id/gps';
  static String mitraVehicleGeofence(String id) => '/mitra/vehicles/$id/geofence';
}

class AppRouteNames {
  const AppRouteNames._();

  static const String home = 'home';
  static const String search = 'search';
  static const String health = 'health';
  static const String login = 'login';
  static const String register = 'register';
  static const String otp = 'otp';
  static const String forgotPassword = 'forgotPassword';
  static const String resetPassword = 'resetPassword';
  static const String profile = 'profile';
  static const String vehicles = 'vehicles';
  static const String vehicleDetail = 'vehicleDetail';
  static const String travelSearch = 'travelSearch';
  static const String travelSchedules = 'travelSchedules';
  static const String travelSeatPicker = 'travelSeatPicker';
  static const String tourPackages = 'tourPackages';
  static const String tourPackageDetail = 'tourPackageDetail';
  static const String bookings = 'bookings';
  static const String createBooking = 'createBooking';

  // Mitra
  static const String mitraDashboard = 'mitraDashboard';
  static const String mitraVehicles = 'mitraVehicles';
  static const String mitraAddVehicle = 'mitraAddVehicle';
  static const String mitraEditVehicle = 'mitraEditVehicle';
  static const String mitraVehiclePhotos = 'mitraVehiclePhotos';
  static const String mitraVehiclePricing = 'mitraVehiclePricing';
  static const String mitraVehicleBlockedDates = 'mitraVehicleBlockedDates';
  static const String mitraVehicleSeatMap = 'mitraVehicleSeatMap';
  static const String mitraBookings = 'mitraBookings';
  static const String mitraDrivers = 'mitraDrivers';
  static const String mitraProfile = 'mitraProfile';
  static const String mitraSubscription = 'mitraSubscription';
  static const String mitraTracking = 'mitraTracking';
  static const String mitraVehicleGps = 'mitraVehicleGps';
  static const String mitraVehicleGeofence = 'mitraVehicleGeofence';
}
