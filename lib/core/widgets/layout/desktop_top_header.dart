import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../config/color.dart';
import '../../../config/decorations.dart';
import '../../../config/motion.dart';
import '../../../config/routes.dart';
import '../../../config/shapes.dart';
import '../../../config/spacing.dart';
import '../../../config/theme_context.dart';
import '../../../features/auth/application/auth_service.dart';
import '../../../features/home/presentation/widgets/home_search_bar.dart';
import 'page_width_container.dart';

/// Header desktop ala Airbnb — logo kiri, kategori tengah, menu kanan, search di home.
class DesktopTopHeader extends StatelessWidget {
  const DesktopTopHeader({
    required this.isMitra,
    super.key,
  });

  final bool isMitra;

  static const _browsePaths = {
    AppRoutePaths.search,
    AppRoutePaths.vehicles,
    AppRoutePaths.destinations,
    AppRoutePaths.tourPackages,
    AppRoutePaths.travelSearch,
    AppRoutePaths.blogs,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline.withValues(alpha: 0.35);
    final location = GoRouterState.of(context).uri.path;
    final showSearch = !isMitra && location == AppRoutePaths.home;
    final authService = context.watch<AuthService>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: borderColor)),
        boxShadow: context.isDarkTheme
            ? null
            : AppDecorations.softShadow(
                opacity: 0.06,
                blur: 12,
                offsetY: 2,
                tint: AppColors.navy,
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: PageWidthContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 76,
                child: Row(
                  children: [
                    _HeaderLogo(onTap: () => context.go(AppRoutePaths.home)),
                    Expanded(
                      child: Center(
                        child: isMitra
                            ? _MitraNavRow(location: location)
                            : _BrowseNavRow(location: location),
                      ),
                    ),
                    _HeaderUserMenu(authService: authService, isMitra: isMitra),
                  ],
                ),
              ),
              if (showSearch) ...[
                SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: HomeSearchBar(variant: HomeSearchBarVariant.header),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static bool isBrowsePath(String location) {
    if (_browsePaths.contains(location)) return true;
    for (final path in _browsePaths) {
      if (location.startsWith('$path?') || location.startsWith('$path/')) return true;
    }
    return false;
  }
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.pill,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.plane, color: AppColors.orange, size: 28),
            AppGap.h(AppSpacing.sm),
            Text(
              'Travelindo',
              style: context.textTitleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseNavRow extends StatelessWidget {
  const _BrowseNavRow({required this.location});

  final String location;

  static const _items = [
    _BrowseNavItem('Beranda', LucideIcons.house, AppRoutePaths.home),
    _BrowseNavItem('Rental', LucideIcons.car, AppRoutePaths.vehicles),
    _BrowseNavItem('Wisata', LucideIcons.treePalm, AppRoutePaths.tourPackages),
    _BrowseNavItem('Travel', LucideIcons.bus, AppRoutePaths.travelSearch),
  ];

  int _selectedIndex() {
    if (location == AppRoutePaths.home || location == AppRoutePaths.search) return 0;
    if (location.startsWith(AppRoutePaths.vehicles)) return 1;
    if (location.startsWith(AppRoutePaths.tourPackages) ||
        location.startsWith(AppRoutePaths.destinations)) {
      return 2;
    }
    if (location.startsWith(AppRoutePaths.travelSearch)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _items.length; i++)
            _CategoryTab(
              label: _items[i].label,
              icon: _items[i].icon,
              selected: i == selected,
              onTap: () => context.go(_items[i].path),
            ),
        ],
      ),
    );
  }
}

class _MitraNavRow extends StatelessWidget {
  const _MitraNavRow({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final items = [
      _BrowseNavItem('Dashboard', LucideIcons.layoutDashboard, AppRoutePaths.mitraDashboard),
      _BrowseNavItem('Armada', LucideIcons.car, AppRoutePaths.mitraVehicles),
      _BrowseNavItem('Pesanan', LucideIcons.clipboardList, AppRoutePaths.mitraBookings),
      _BrowseNavItem('Profil', LucideIcons.user, AppRoutePaths.mitraProfile),
    ];

    var selected = 0;
    if (location.startsWith(AppRoutePaths.mitraVehicles)) selected = 1;
    if (location == AppRoutePaths.mitraBookings) selected = 2;
    if (location == AppRoutePaths.mitraProfile) selected = 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          _CategoryTab(
            label: items[i].label,
            icon: items[i].icon,
            selected: i == selected,
            onTap: () => context.go(items[i].path),
          ),
      ],
    );
  }
}

class _BrowseNavItem {
  const _BrowseNavItem(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.cs.onSurface : context.cs.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: context.textLabelSmall.copyWith(
                  color: color,
                  fontSize: 11,
                  height: 1.15,
                  letterSpacing: 0,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: AppMotion.fast,
                height: 2,
                width: selected ? 28 : 0,
                decoration: BoxDecoration(
                  color: context.cs.onSurface,
                  borderRadius: AppShapes.pill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderUserMenu extends StatelessWidget {
  const _HeaderUserMenu({
    required this.authService,
    required this.isMitra,
  });

  final AuthService authService;
  final bool isMitra;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!authService.isAuthenticated && !isMitra)
          TextButton(
            onPressed: () => context.push(AppRoutePaths.mitraDashboard),
            child: const Text('Jadi Mitra'),
          ),
        IconButton(
          tooltip: 'Pengaturan',
          onPressed: () => context.push(AppRoutePaths.settings),
          icon: const Icon(LucideIcons.globe),
        ),
        if (!authService.isAuthenticated)
          FilledButton(
            onPressed: () => context.push(AppRoutePaths.login),
            child: const Text('Masuk'),
          )
        else
          _UserMenuButton(authService: authService, isMitra: isMitra),
      ],
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton({
    required this.authService,
    required this.isMitra,
  });

  final AuthService authService;
  final bool isMitra;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: AppShapes.pill,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: context.cs.outline.withValues(alpha: 0.5)),
              borderRadius: AppShapes.pill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.menu, size: 18, color: context.cs.onSurface),
                AppGap.h(AppSpacing.sm),
                Icon(LucideIcons.user, size: 18, color: context.cs.onSurface),
              ],
            ),
          ),
        );
      },
      menuChildren: isMitra
          ? [
              _menuItem(context, 'Profil Mitra', LucideIcons.user, AppRoutePaths.mitraProfile),
              _menuItem(context, 'Pengaturan', LucideIcons.settings, AppRoutePaths.settings),
            ]
          : [
              _menuItem(context, 'Pesanan', LucideIcons.shoppingBag, AppRoutePaths.bookings),
              _menuItem(context, 'Wallet', LucideIcons.wallet, AppRoutePaths.wallet),
              _menuItem(context, 'Profil', LucideIcons.user, AppRoutePaths.profile),
              _menuItem(context, 'Notifikasi', LucideIcons.bell, AppRoutePaths.notifications),
              _menuItem(context, 'Pengaturan', LucideIcons.settings, AppRoutePaths.settings),
            ],
    );
  }

  MenuItemButton _menuItem(
    BuildContext context,
    String label,
    IconData icon,
    String path,
  ) {
    return MenuItemButton(
      onPressed: () => context.push(path),
      leadingIcon: Icon(icon, size: 18),
      child: Text(label),
    );
  }
}
