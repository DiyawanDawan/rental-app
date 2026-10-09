class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegisterCustomer = '/auth/register/customer';
  static const String authRegisterMitra = '/auth/register/mitra';
  static const String authVerifyRegistration = '/auth/verify-registration';
  static const String authResendOtp = '/auth/resend-otp';
  static const String authRefreshToken = '/auth/refresh-token';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authProfile = '/auth/me';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyResetCode = '/auth/verify-reset-code';
  static const String authResetPassword = '/auth/reset-password';
  static const String authGoogle = '/auth/google';
  static const String authFacebook = '/auth/facebook';
  static const String authRequestPhoneUpdate = '/auth/me/phone/request-update';
  static const String authVerifyPhoneUpdate = '/auth/me/phone/verify-update';
  static const String authVerification = '/auth/me/verify';

  static String authResetPasswordWithToken(String token) =>
      '/auth/reset-password/$token';

  // Mitra
  static const String mitraProfile = '/mitra/profile';
  static const String mitraProfileBankInfo = '/mitra/profile/bank-info';
  static const String mitraStats = '/mitra/stats';
  static const String mitraBalance = '/mitra/balance';
  static const String mitraReviews = '/mitra/reviews';
  static const String mitraWithdraw = '/mitra/withdraw';
  static const String mitraSubscription = '/mitra/subscription';
  static const String mitraSubscriptionUpgrade = '/mitra/subscription/upgrade';
  static const String mitraSubscriptionCancel = '/mitra/subscription/cancel';
  static const String mitraTrackingActive = '/mitra/tracking/active';
  static String mitraVehicleLocation(String vehicleId) =>
      '/mitra/vehicles/$vehicleId/location';
  static String mitraVehicleLocationHistory(String vehicleId) =>
      '/mitra/vehicles/$vehicleId/location/history';
  static String mitraVehicleGpsDevice(String vehicleId) =>
      '/mitra/vehicles/$vehicleId/gps-device';
  static String mitraVehicleGeofence(String vehicleId) =>
      '/mitra/vehicles/$vehicleId/geofence';
  static String mitraVehicleGeofenceItem(String vehicleId, String geofenceId) =>
      '/mitra/vehicles/$vehicleId/geofence/$geofenceId';
  static const String mitraVehicles = '/vehicles/mitra/vehicles';
  static const String mitraBookings = '/bookings/mitra/bookings';
  static const String mitraDrivers = '/mitra/drivers';
  static String mitraDriver(String id) => '/mitra/drivers/$id';
  static String mitraAssignDriver(String bookingId) =>
      '/mitra/bookings/$bookingId/assign-driver';

  // Vehicles
  static const String vehicles = '/vehicles';
  static const String vehicleUpload = '/vehicles/upload';
  static const String vehicleAmenities = '/amenities';
  static const String vehicleFavorites = '/vehicles/favorites';
  static String vehicleFavorite(String id) => '/vehicles/$id/favorite';
  static String vehicleById(String id) => '/vehicles/$id';
  static String vehicleAvailability(String id) => '/vehicles/$id/availability';
  static String vehicleStatus(String id) => '/vehicles/$id/status';
  static String vehicleRestore(String id) => '/vehicles/$id/restore';
  static String vehiclePhotos(String id) => '/vehicles/$id/photos';
  static String vehiclePhotoRegister(String id) =>
      '/vehicles/$id/photos/register';
  static const String pusherAuth = '/realtime/pusher/auth';
  static const String storageUploadInit = '/storage/uploads/init';
  static String storageUploadPart(String uploadId) =>
      '/storage/uploads/$uploadId/part';
  static String storageUploadComplete(String uploadId) =>
      '/storage/uploads/$uploadId/complete';
  static String storageUploadAbort(String uploadId) =>
      '/storage/uploads/$uploadId';
  static String vehiclePhotoById(String vehicleId, String photoId) =>
      '/vehicles/$vehicleId/photos/$photoId';
  static String vehiclePricing(String id) => '/vehicles/$id/pricing';
  static String vehicleBlockedDates(String id) => '/vehicles/$id/blocked-dates';
  static String vehicleAmenitiesUpdate(String vehicleId) =>
      '/amenities/vehicle/$vehicleId';

  // Bookings
  static const String bookings = '/bookings';
  static const String bookingCalculate = '/bookings/calculate';
  static const String myBookings = '/bookings/my';
  static String bookingById(String id) => '/bookings/$id';
  static String bookingCancel(String id) => '/bookings/$id/cancel';
  static String bookingExtend(String id) => '/bookings/$id/extend';
  static String bookingLocation(String id) => '/bookings/$id/location';
  static String bookingDocuments(String id) => '/bookings/$id/documents';
  static String bookingMitraConfirm(String id) =>
      '/bookings/mitra/bookings/$id/confirm';
  static String bookingMitraReject(String id) =>
      '/bookings/mitra/bookings/$id/reject';
  static String bookingMitraHandover(String id) =>
      '/bookings/mitra/bookings/$id/handover';
  static String bookingMitraReturned(String id) =>
      '/bookings/mitra/bookings/$id/returned';

  // Delivery
  static const String deliveryCalculate = '/delivery/calculate';
  static const String deliveryActiveSetting = '/delivery/settings/active';

  // Payments & Wallet
  static const String paymentChannels = '/payments/channels';
  static const String paymentInitiate = '/payments/initiate';
  static const String paymentsMy = '/payments/my';
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopup = '/wallet/topup';
  static String walletTopupStatus(String id) => '/wallet/topup/$id';
  static const String bankAccounts = '/banks/my-accounts';
  static const String mitraEarnings = '/payments/mitra/earnings';
  static const String mitraEarningsHistory = '/payments/mitra/earnings/history';
  static const String mitraPayoutRequest = '/payments/mitra/payout/request';
  static const String mitraPayoutHistory = '/payments/mitra/payout/history';
  static String paymentStatus(String id) => '/payments/$id/status';
  static String paymentSimulate(String id) => '/payments/$id/simulate';
  static String paymentChangeMethod(String id) => '/payments/$id/change-method';

  // Travel
  static const String travelRoutes = '/travel/routes';
  static const String travelSearch = '/travel/search';
  static const String travelBook = '/travel/book';
  static const String travelMitraSchedules = '/travel/mitra/schedules';
  static const String travelSchedules = '/travel/schedules';
  static String travelScheduleById(String id) => '/travel/schedules/$id';
  static String travelScheduleSeats(String id) => '/travel/schedules/$id/seats';
  static String travelMitraScheduleById(String id) =>
      '/travel/mitra/schedules/$id';

  // Reviews
  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';
  static String reviewVehicle(String vehicleId) =>
      '/reviews/vehicle/$vehicleId';
  static String reviewMitra(String mitraId) => '/reviews/mitra/$mitraId';
  static String reviewReply(String reviewId) => '/reviews/$reviewId/reply';

  // Content & Notifications
  static const String banners = '/content/banners';
  static const String contentUpload = '/content/upload';
  static const String blogs = '/content/blogs';
  static String blogBySlug(String slug) => '/content/blogs/slug/$slug';
  static const String notifications = '/notifications';
  static const String notificationUnreadCount = '/notifications/unread-count';
  static const String notificationReadAll = '/notifications/read-all';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static const String registerDevice = '/notifications/devices';
  static const String unregisterDevice = '/notifications/devices';

  // Chat
  static const String chatRooms = '/chat/rooms';
  static String chatMessages(String roomId) => '/chat/rooms/$roomId/messages';
  static String chatRead(String roomId) => '/chat/rooms/$roomId/read';

  // Tour packages
  static const String tourPackages = '/tour-packages';
  static const String tourPackagesMitraMe = '/tour-packages/mitra/me';
  static const String tourDestinations = '/tour-packages/destinations';
  static String tourDestinationById(String id) =>
      '/tour-packages/destinations/$id';
  static String tourPackageById(String id) => '/tour-packages/$id';

  // Social & loyalty
  static const String mitraStoresFollowing = '/mitra-stores/following';
  static String mitraStorePublic(String id) => '/mitra-stores/$id/public';
  static String mitraStoreFollow(String id) => '/mitra-stores/$id/follow';
  static const String loyaltyBalance = '/loyalty/balance';
  static const String loyaltyHistory = '/loyalty/history';
  static const String loyaltyReferralMe = '/loyalty/referral/me';
  static const String loyaltyReferralApply = '/loyalty/referral/apply';
  static const String contentHelp = '/content/help';

  // Addresses & Locations
  static const String addresses = '/addresses';
  static const String addressesMy = '/addresses/my';
  static const String addressRegions = '/addresses/regions';
  static String addressById(String id) => '/addresses/$id';
  static const String vouchersAvailable = '/vouchers/available';
  static const String voucherValidate = '/vouchers/validate';
  static const String geocoding = '/locations/geocoding';
  static const String cancellationPolicies = '/content/cancellation-policies';
  static const String banksSupported = '/banks/supported';
  static String bankAccountById(String id) => '/banks/my-accounts/$id';
  static String bankAccountPrimary(String id) =>
      '/banks/my-accounts/$id/primary';
  static const String operatingHours = '/operating-hours/me';


  // Legacy aliases
  static String bookingUploadDocs(String id) => bookingDocuments(id);
  static String bookingApprove(String id) => bookingMitraConfirm(id);
  static String bookingReject(String id) => bookingMitraReject(id);
  static String bookingHandover(String id) => bookingMitraHandover(id);
  static String bookingReturn(String id) => bookingMitraReturned(id);
  static const String mitraPayout = mitraPayoutRequest;
  static String mitraReviewsById(String mitraId) => reviewMitra(mitraId);
}
