import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/routes.dart';
import 'page_transitions.dart';
import '../features/auth/application/auth_service.dart';
import '../features/customer/data/models/tour_model.dart';
import '../features/auth/presentation/pages/change_password_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/kyc_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_verification_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/settings_page.dart';
import '../features/chat/presentation/pages/chat_messages_page.dart';
import '../features/chat/presentation/pages/chat_room_list_page.dart';
import '../features/customer/presentation/pages/address_list_page.dart';
import '../features/customer/presentation/pages/address_form_page.dart';
import '../features/customer/data/models/address_model.dart';
import '../features/customer/presentation/pages/destination_detail_page.dart';
import '../features/customer/presentation/pages/destination_list_page.dart';
import '../features/customer/presentation/pages/blog_detail_page.dart';
import '../features/customer/presentation/pages/blog_list_page.dart';
import '../features/customer/presentation/pages/booking_detail_page.dart';
import '../features/customer/presentation/pages/cancellation_policy_page.dart';
import '../features/customer/presentation/pages/favorites_page.dart';
import '../features/customer/presentation/pages/following_page.dart';
import '../features/customer/presentation/pages/help_center_page.dart';
import '../features/customer/presentation/pages/loyalty_history_page.dart';
import '../features/customer/presentation/pages/voucher_list_page.dart';
import '../features/customer/presentation/pages/mitra_public_profile_page.dart';
import '../features/wallet/presentation/pages/wallet_page.dart';
import '../features/customer/presentation/pages/create_booking_page.dart';
import '../features/customer/presentation/pages/my_bookings_page.dart';
import '../features/customer/presentation/pages/notification_page.dart';
import '../features/customer/presentation/pages/seat_picker_page.dart';
import '../features/customer/presentation/pages/submit_review_page.dart';
import '../features/customer/presentation/pages/tour_booking_page.dart';
import '../features/customer/presentation/pages/tour_package_detail_page.dart';
import '../features/customer/presentation/pages/tour_package_list_page.dart';
import '../features/customer/presentation/pages/travel_booking_checkout_page.dart';
import '../features/customer/presentation/pages/travel_schedule_list_page.dart';
import '../features/customer/presentation/pages/travel_search_page.dart';
import '../features/customer/presentation/pages/vehicle_detail_page.dart';
import '../features/customer/presentation/pages/vehicle_list_page.dart';
import '../features/health/presentation/health_check_page.dart';
import '../features/home/presentation/pages/global_search_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/not_found_page.dart';
import '../features/home/presentation/pages/onboarding_page.dart';
import '../features/home/presentation/widgets/main_shell.dart';
import '../features/mitra/presentation/pages/mitra_bookings_page.dart';
import '../features/mitra/presentation/pages/mitra_drivers_page.dart';
import '../features/mitra/presentation/pages/mitra_dashboard_page.dart';
import '../features/mitra/presentation/pages/mitra_earnings_page.dart';
import '../features/mitra/presentation/pages/mitra_operating_hours_page.dart';
import '../features/mitra/presentation/pages/mitra_profile_page.dart';
import '../features/mitra/presentation/pages/mitra_vehicle_blocked_dates_page.dart';
import '../features/mitra/presentation/pages/mitra_seat_map_editor.dart';
import '../features/mitra/presentation/pages/mitra_vehicle_form_page.dart';
import '../features/mitra/presentation/pages/mitra_vehicle_photos_page.dart';
import '../features/mitra/presentation/pages/mitra_vehicle_pricing_page.dart';
import '../features/mitra/presentation/pages/mitra_vehicles_page.dart';
import '../features/mitra/presentation/pages/mitra_reviews_page.dart';
import '../features/mitra/presentation/pages/mitra_destination_form_page.dart';
import '../features/mitra/presentation/pages/mitra_tour_package_form_page.dart';
import '../features/mitra/presentation/pages/mitra_subscription_page.dart';
import '../features/mitra/presentation/pages/mitra_tracking_page.dart';
import '../features/mitra/presentation/pages/mitra_vehicle_gps_page.dart';
import '../features/mitra/presentation/pages/mitra_vehicle_geofence_page.dart';
import '../features/mitra/presentation/pages/mitra_tour_packages_page.dart';
import '../features/mitra/presentation/pages/mitra_travel_schedules_page.dart';
import '../features/wallet/presentation/pages/wallet_topup_page.dart';
import '../features/customer/presentation/pages/payment_history_page.dart';
import '../features/wallet/presentation/pages/bank_account_list_page.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter? _instance;

  static GoRouter get instance {
    assert(_instance != null, 'AppRouter belum diinisialisasi');
    return _instance!;
  }

  static GoRouter router(AuthService authService) {
    return _instance ??= GoRouter(
        initialLocation: AppRoutePaths.home,
        refreshListenable: authService,
        errorBuilder: (context, state) => NotFoundPage(message: state.error?.toString()),
        redirect: (context, state) async {
          final path = state.uri.path;
          final isAuthenticated = authService.isAuthenticated;
          final isMitra = authService.user?.role == 'MITRA';
          final isLoggingIn = path == AppRoutePaths.login ||
              path == AppRoutePaths.register ||
              path == AppRoutePaths.otp;

          if (kReleaseMode && path == AppRoutePaths.health) {
            return AppRoutePaths.home;
          }

          final prefs = await SharedPreferences.getInstance();
          final onboardingDone = prefs.getBool('onboarding_completed') ?? false;
          if (!onboardingDone &&
              !isAuthenticated &&
              path != AppRoutePaths.onboarding &&
              path != AppRoutePaths.login &&
              path != AppRoutePaths.register &&
              path != AppRoutePaths.otp) {
            return AppRoutePaths.onboarding;
          }

          final authRequiredPrefixes = [
            AppRoutePaths.favorites,
            AppRoutePaths.following,
            AppRoutePaths.loyaltyHistory,
            AppRoutePaths.vouchers,
            AppRoutePaths.profile,
            AppRoutePaths.changePassword,
            AppRoutePaths.kyc,
            AppRoutePaths.wallet,
            AppRoutePaths.addresses,
            AppRoutePaths.chat,
            AppRoutePaths.notifications,
            AppRoutePaths.paymentHistory,
            AppRoutePaths.walletBanks,
            AppRoutePaths.bookings,
            '/bookings/create',
            AppRoutePaths.mitraDashboard,
          ];

          final needsAuth = authRequiredPrefixes.any(
            (prefix) => path == prefix || path.startsWith('$prefix/'),
          );

          if (!isAuthenticated && needsAuth) {
            return AppRoutePaths.login;
          }

          if (!isAuthenticated && path.startsWith('/mitra')) {
            return AppRoutePaths.login;
          }

          if (path.startsWith('/admin')) {
            return AppRoutePaths.home;
          }

          if (isAuthenticated && path.startsWith('/mitra') && !isMitra) {
            return AppRoutePaths.home;
          }

          if (isAuthenticated && isLoggingIn) {
            if (isMitra) return AppRoutePaths.mitraDashboard;
            return AppRoutePaths.home;
          }

          if (isAuthenticated && isMitra && path == AppRoutePaths.home) {
            return AppRoutePaths.mitraDashboard;
          }

          return null;
        },
        routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutePaths.home,
            name: AppRouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutePaths.bookings,
            name: AppRouteNames.bookings,
            builder: (context, state) => const MyBookingsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.wallet,
            name: 'wallet',
            builder: (context, state) => const WalletPage(),
          ),
          GoRoute(
            path: AppRoutePaths.notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationPage(),
          ),
          GoRoute(
            path: AppRoutePaths.cancellationPolicy,
            name: 'cancellationPolicy',
            builder: (context, state) => const CancellationPolicyPage(),
          ),
          GoRoute(
            path: AppRoutePaths.helpCenter,
            name: 'helpCenter',
            builder: (context, state) => const HelpCenterPage(),
          ),
          GoRoute(
            path: AppRoutePaths.profile,
            name: AppRouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutePaths.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.changePassword,
            name: 'changePassword',
            builder: (context, state) => const ChangePasswordPage(),
          ),
          GoRoute(
            path: AppRoutePaths.kyc,
            name: 'kyc',
            builder: (context, state) => const KycPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraProfile,
            name: AppRouteNames.mitraProfile,
            builder: (context, state) => const MitraProfilePage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraDashboard,
            name: AppRouteNames.mitraDashboard,
            builder: (context, state) => const MitraDashboardPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraVehicles,
            name: AppRouteNames.mitraVehicles,
            builder: (context, state) => const MitraVehiclesPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraBookings,
            name: AppRouteNames.mitraBookings,
            builder: (context, state) => const MitraBookingsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraDrivers,
            name: AppRouteNames.mitraDrivers,
            builder: (context, state) => const MitraDriversPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraEarnings,
            name: 'mitraEarnings',
            builder: (context, state) => const MitraEarningsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraOperatingHours,
            name: 'mitraOperatingHours',
            builder: (context, state) => const MitraOperatingHoursPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraReviews,
            name: 'mitraReviews',
            builder: (context, state) => const MitraReviewsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraTravelSchedules,
            name: 'mitraTravelSchedules',
            builder: (context, state) => const MitraTravelSchedulesPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraTourPackages,
            name: 'mitraTourPackages',
            builder: (context, state) => const MitraTourPackagesPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraSubscription,
            name: AppRouteNames.mitraSubscription,
            builder: (context, state) => const MitraSubscriptionPage(),
          ),
          GoRoute(
            path: AppRoutePaths.mitraTracking,
            name: AppRouteNames.mitraTracking,
            builder: (context, state) => const MitraTrackingPage(),
          ),
          GoRoute(
            path: AppRoutePaths.search,
            name: AppRouteNames.search,
            pageBuilder: (context, state) => fadeSlidePage<void>(
              key: state.pageKey,
              child: const GlobalSearchPage(),
            ),
          ),
          GoRoute(
            path: AppRoutePaths.vehicles,
            name: AppRouteNames.vehicles,
            builder: (context, state) => const VehicleListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.travelSearch,
            name: AppRouteNames.travelSearch,
            builder: (context, state) => const TravelSearchPage(),
          ),
          GoRoute(
            path: AppRoutePaths.tourPackages,
            name: AppRouteNames.tourPackages,
            builder: (context, state) => const TourPackageListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.destinations,
            name: 'destinations',
            builder: (context, state) => const DestinationListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.blogs,
            name: 'blogs',
            builder: (context, state) => const BlogListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.favorites,
            name: 'favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: AppRoutePaths.following,
            name: 'following',
            builder: (context, state) => const FollowingPage(),
          ),
          GoRoute(
            path: AppRoutePaths.loyaltyHistory,
            name: 'loyaltyHistory',
            builder: (context, state) => const LoyaltyHistoryPage(),
          ),
          GoRoute(
            path: AppRoutePaths.vouchers,
            name: 'vouchers',
            builder: (context, state) => const VoucherListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.chat,
            name: 'chatRooms',
            builder: (context, state) => const ChatRoomListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.addresses,
            name: 'addresses',
            builder: (context, state) => const AddressListPage(),
          ),
          GoRoute(
            path: AppRoutePaths.addressForm,
            name: 'addressForm',
            builder: (context, state) => AddressFormPage(
              initialAddress: state.extra as AddressModel?,
            ),
          ),
          GoRoute(
            path: AppRoutePaths.walletTopup,
            name: 'walletTopup',
            builder: (context, state) => const WalletTopupPage(),
          ),
          GoRoute(
            path: AppRoutePaths.paymentHistory,
            name: 'paymentHistory',
            builder: (context, state) => const PaymentHistoryPage(),
          ),
          GoRoute(
            path: AppRoutePaths.walletBanks,
            name: 'walletBanks',
            builder: (context, state) => const BankAccountListPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.mitraTourPackageForm,
        name: 'mitraTourPackageForm',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return MitraTourPackageFormPage(packageId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraDestinationForm,
        name: 'mitraDestinationForm',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return MitraDestinationFormPage(destinationId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraPublicProfilePattern,
        name: 'mitraPublicProfile',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraPublicProfilePage(mitraId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.health,
        name: AppRouteNames.health,
        builder: (context, state) => const HealthCheckPage(),
      ),
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: AppRouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutePaths.otp,
        name: AppRouteNames.otp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutePaths.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutePaths.resetPassword,
        name: AppRouteNames.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutePaths.vehicleDetailPattern,
        name: AppRouteNames.vehicleDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: VehicleDetailPage(vehicleId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.travelSchedules,
        name: AppRouteNames.travelSchedules,
        builder: (context, state) {
          final origin = state.uri.queryParameters['origin'] ?? '';
          final destination = state.uri.queryParameters['destination'] ?? '';
          final date = state.uri.queryParameters['date'] ?? '';
          final originRegencyId = state.uri.queryParameters['originRegencyId'];
          final destinationRegencyId = state.uri.queryParameters['destinationRegencyId'];
          return TravelScheduleListPage(
            origin: origin,
            destination: destination,
            date: date,
            originRegencyId: originRegencyId,
            destinationRegencyId: destinationRegencyId,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.travelSeatPickerPattern,
        name: AppRouteNames.travelSeatPicker,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: SeatPickerPage(scheduleId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.travelCheckout,
        name: 'travelCheckout',
        pageBuilder: (context, state) {
          final scheduleId = state.uri.queryParameters['scheduleId'] ?? '';
          final seatsParam = state.uri.queryParametersAll['seats'];
          final legacyParam = state.uri.queryParametersAll['seatIds'];
          final selectedSeats = (seatsParam != null && seatsParam.isNotEmpty)
              ? seatsParam
              : (legacyParam ?? <String>[]);
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: TravelBookingCheckoutPage(scheduleId: scheduleId, selectedSeats: selectedSeats),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.tourPackageDetailPattern,
        name: AppRouteNames.tourPackageDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: TourPackageDetailPage(tourId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.tourBookPattern,
        name: 'tourBooking',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra;
          final tour = extra is TourPackageModel ? extra : null;
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: TourBookingPage(tourId: id, tour: tour),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.chatMessagesPattern,
        name: 'chatMessages',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final name = state.uri.queryParameters['name'] ?? 'Chat';
          return ChatMessagesPage(roomId: id, name: name);
        },
      ),
      GoRoute(
        path: AppRoutePaths.destinationDetailPattern,
        name: 'destinationDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: DestinationDetailPage(destinationId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.blogDetailPattern,
        name: 'blogDetail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return BlogDetailPage(slug: slug);
        },
      ),
      GoRoute(
        path: AppRoutePaths.bookingDetailPattern,
        name: 'bookingDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingDetailPage(bookingId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.submitReviewPattern,
        name: 'submitReview',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final vehicleName = state.uri.queryParameters['vehicleName'] ?? '';
          return SubmitReviewPage(bookingId: id, vehicleName: vehicleName);
        },
      ),
      GoRoute(
        path: AppRoutePaths.createBookingPattern,
        name: AppRouteNames.createBooking,
        pageBuilder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId'] ?? '';
          return fadeSlidePage<void>(
            key: state.pageKey,
            child: CreateBookingPage(vehicleId: vehicleId),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraAddVehicle,
        name: AppRouteNames.mitraAddVehicle,
        builder: (context, state) => const MitraVehicleFormPage(),
      ),
      GoRoute(
        path: AppRoutePaths.mitraEditVehiclePattern,
        name: AppRouteNames.mitraEditVehicle,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraVehicleFormPage(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraVehiclePhotosPattern,
        name: AppRouteNames.mitraVehiclePhotos,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraVehiclePhotosPage(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraVehiclePricingPattern,
        name: AppRouteNames.mitraVehiclePricing,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraVehiclePricingPage(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraVehicleBlockedDatesPattern,
        name: AppRouteNames.mitraVehicleBlockedDates,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraVehicleBlockedDatesPage(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraVehicleSeatMapPattern,
        name: AppRouteNames.mitraVehicleSeatMap,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraSeatMapEditorPage(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraVehicleGpsPattern,
        name: AppRouteNames.mitraVehicleGps,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraVehicleGpsPage(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.mitraVehicleGeofencePattern,
        name: AppRouteNames.mitraVehicleGeofence,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MitraVehicleGeofencePage(vehicleId: id);
        },
      ),
    ],
  );
  }
}
