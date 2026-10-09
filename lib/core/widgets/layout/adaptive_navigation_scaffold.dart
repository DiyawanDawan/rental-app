import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../config/breakpoints.dart';
import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/routes.dart';
import 'desktop_top_header.dart';
import 'page_width_container.dart';
import '../../../config/theme_context.dart';
import '../../../features/auth/application/auth_service.dart';
import '../../../features/customer/application/customer_service.dart';

/// Kerangka navigasi adaptif standar Travelindo.
///
/// * **Mobile:** [NavigationBar] di bawah layar.
/// * **Tablet/Desktop:** top bar horizontal ala Airbnb (logo kiri, menu tengah, aksi kanan).
class AdaptiveNavigationScaffold extends StatelessWidget {
  const AdaptiveNavigationScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  static const _customerProfileTabPaths = {
    AppRoutePaths.profile,
    AppRoutePaths.settings,
    AppRoutePaths.changePassword,
    AppRoutePaths.kyc,
    AppRoutePaths.helpCenter,
    AppRoutePaths.notifications,
    AppRoutePaths.cancellationPolicy,
    AppRoutePaths.favorites,
    AppRoutePaths.following,
    AppRoutePaths.loyaltyHistory,
    AppRoutePaths.vouchers,
    AppRoutePaths.addresses,
    AppRoutePaths.chat,
    AppRoutePaths.paymentHistory,
    AppRoutePaths.walletBanks,
    AppRoutePaths.walletTopup,
  };

  /// Halaman jelajah dari home — tab Beranda tetap aktif, bottom nav tetap tampil.
  static const _customerBrowseTabPaths = {
    AppRoutePaths.search,
    AppRoutePaths.vehicles,
    AppRoutePaths.destinations,
    AppRoutePaths.tourPackages,
    AppRoutePaths.travelSearch,
    AppRoutePaths.blogs,
  };

  static const _mitraProfileTabPaths = {
    AppRoutePaths.mitraProfile,
    AppRoutePaths.mitraEarnings,
    AppRoutePaths.mitraOperatingHours,
    AppRoutePaths.settings,
    AppRoutePaths.changePassword,
    AppRoutePaths.kyc,
  };

  static const _mitraDashboardSubPaths = {
    AppRoutePaths.mitraReviews,
    AppRoutePaths.mitraTravelSchedules,
    AppRoutePaths.mitraTourPackages,
  };

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final isMitra = user?.role == 'MITRA';
    final isAuthenticated = authService.isAuthenticated;
    final unreadNotifications = !isAuthenticated || isMitra
        ? 0
        : context.watch<CustomerService>().unreadNotificationCount;

    final destinations = !isAuthenticated
        ? _guestDestinations()
        : isMitra
            ? _mitraDestinations()
            : _customerDestinations(unreadNotifications);

    final selectedIndex = _calculateSelectedIndex(context, isAuthenticated, isMitra);
    final onDestinationSelected = (int index) {
      if (!isAuthenticated) {
        _onGuestTap(context, index);
      } else {
        _onTap(context, index, isMitra);
      }
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.mobile;

        if (isMobile) {
          return _buildMobileScaffold(
            context,
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          );
        }

        return _buildTopNavScaffold(
          context,
          isMitra: isMitra,
        );
      },
    );
  }

  Scaffold _buildMobileScaffold(
    BuildContext context, {
    required List<NavigationDestination> destinations,
    required int selectedIndex,
    required ValueChanged<int> onDestinationSelected,
  }) {
    final navTheme = Theme.of(context).navigationBarTheme;
    final navBackground = navTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: navBackground,
          boxShadow: context.isDarkTheme
              ? null
              : AppDecorations.softShadow(
                  opacity: 0.14,
                  blur: 20,
                  offsetY: -4,
                  tint: AppColors.navy,
                ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          destinations: destinations,
        ),
      ),
    );
  }

  Scaffold _buildTopNavScaffold(
    BuildContext context, {
    required bool isMitra,
  }) {
    final location = GoRouterState.of(context).uri.path;
    final documentScroll = _usesDocumentScroll(location);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesktopTopHeader(isMitra: isMitra),
          Expanded(
            child: documentScroll
                ? child
                : PageWidthContainer(child: child),
          ),
        ],
      ),
    );
  }

  /// Halaman dengan scroll vertikal di viewport penuh (bukan di dalam kotak sempit).
  static bool _usesDocumentScroll(String location) {
    return location == AppRoutePaths.home;
  }

  int _calculateSelectedIndex(BuildContext context, bool isAuthenticated, bool isMitra) {
    final String location = GoRouterState.of(context).uri.path;
    if (!isAuthenticated) {
      if (location == AppRoutePaths.settings) return 3;
      return 0;
    }
    if (isMitra) {
      if (location == AppRoutePaths.mitraDashboard) return 0;
      if (location.startsWith(AppRoutePaths.mitraVehicles)) return 1;
      if (location == AppRoutePaths.mitraBookings) return 2;
      if (_mitraProfileTabPaths.contains(location)) return 3;
      if (_mitraDashboardSubPaths.contains(location)) return 0;
    } else {
      if (location == AppRoutePaths.home || _isBrowsePath(location)) return 0;
      if (location == AppRoutePaths.bookings || location.startsWith('${AppRoutePaths.bookings}/')) {
        return 1;
      }
      if (location == AppRoutePaths.wallet || location.startsWith('${AppRoutePaths.wallet}/')) {
        return 2;
      }
      if (_customerProfileTabPaths.contains(location)) return 3;
    }
    return 0;
  }

  static bool _isBrowsePath(String location) {
    if (_customerBrowseTabPaths.contains(location)) return true;
    for (final path in _customerBrowseTabPaths) {
      if (location.startsWith('$path?')) return true;
    }
    return false;
  }

  void _onGuestTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutePaths.home);
        break;
      case 3:
        context.go(AppRoutePaths.settings);
        break;
      default:
        context.push(AppRoutePaths.login);
        break;
    }
  }

  void _onTap(BuildContext context, int index, bool isMitra) {
    if (isMitra) {
      switch (index) {
        case 0:
          context.go(AppRoutePaths.mitraDashboard);
          break;
        case 1:
          context.go(AppRoutePaths.mitraVehicles);
          break;
        case 2:
          context.go(AppRoutePaths.mitraBookings);
          break;
        case 3:
          context.go(AppRoutePaths.mitraProfile);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go(AppRoutePaths.home);
          break;
        case 1:
          context.go(AppRoutePaths.bookings);
          break;
        case 2:
          context.go(AppRoutePaths.wallet);
          break;
        case 3:
          context.go(AppRoutePaths.profile);
          break;
      }
    }
  }

  List<NavigationDestination> _guestDestinations() {
    return [
      NavigationDestination(icon: Icon(LucideIcons.house), label: 'home'.tr()),
      NavigationDestination(icon: Icon(LucideIcons.shoppingBag), label: 'bookings'.tr()),
      NavigationDestination(icon: Icon(LucideIcons.wallet), label: 'wallet'.tr()),
      const NavigationDestination(icon: Icon(LucideIcons.settings), label: 'Pengaturan'),
    ];
  }

  List<NavigationDestination> _customerDestinations(int unreadNotifications) {
    return [
      NavigationDestination(icon: Icon(LucideIcons.house), label: 'home'.tr()),
      NavigationDestination(icon: Icon(LucideIcons.shoppingBag), label: 'bookings'.tr()),
      NavigationDestination(icon: Icon(LucideIcons.wallet), label: 'wallet'.tr()),
      NavigationDestination(
        icon: _badgeIcon(LucideIcons.user, unreadNotifications),
        label: 'profile'.tr(),
      ),
    ];
  }

  Widget _badgeIcon(IconData icon, int count) {
    if (count <= 0) return Icon(icon);
    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(icon),
    );
  }

  List<NavigationDestination> _mitraDestinations() {
    return const [
      NavigationDestination(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
      NavigationDestination(icon: Icon(LucideIcons.car), label: 'Armada'),
      NavigationDestination(icon: Icon(LucideIcons.clipboardList), label: 'Pesanan'),
      NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profil'),
    ];
  }
}
