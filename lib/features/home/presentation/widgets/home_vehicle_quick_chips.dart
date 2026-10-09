import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/services/user_location_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/inputs/app_filter_chip.dart';
import '../../../../core/widgets/motion/animated_filter_switcher.dart';

class HomeVehicleQuickChips extends StatefulWidget {
  const HomeVehicleQuickChips({super.key});

  @override
  State<HomeVehicleQuickChips> createState() => _HomeVehicleQuickChipsState();
}

class _HomeVehicleQuickChipsState extends State<HomeVehicleQuickChips> {
  String _active = 'price_asc';

  Future<void> _open(BuildContext context, {required String sort, bool needsLocation = false}) async {
    setState(() => _active = sort);

    if (!needsLocation) {
      context.push(AppRoutePaths.vehiclesWithQuery(sort: sort));
      return;
    }

    final position = await UserLocationService.instance.getCurrentPosition();
    if (!context.mounted) return;
    if (position == null) {
      SnackbarUtils.showError(context, 'Izinkan lokasi untuk sort berdasarkan jarak.');
      context.push(AppRoutePaths.vehiclesWithQuery(sort: sort));
      return;
    }

    context.push(
      AppRoutePaths.vehiclesWithQuery(
        sort: sort,
        lat: position.latitude,
        lng: position.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFilterSwitcher(
      filterKey: _active,
      child: SizedBox(
        height: 40.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            AppFilterChip(
              label: const Text('Termurah'),
              selected: _active == 'price_asc',
              onSelected: (_) => _open(context, sort: 'price_asc'),
            ),
            AppGap.h(AppSpacing.sm),
            AppFilterChip(
              label: const Text('Rating tinggi'),
              selected: _active == 'rating',
              onSelected: (_) => _open(context, sort: 'rating'),
            ),
            AppGap.h(AppSpacing.sm),
            AppFilterChip(
              label: const Text('Terdekat & termurah'),
              selected: _active == 'nearest_cheapest',
              onSelected: (_) => _open(context, sort: 'nearest_cheapest', needsLocation: true),
            ),
            AppGap.h(AppSpacing.sm),
            AppFilterChip(
              label: const Text('Terdekat & rating'),
              selected: _active == 'nearest_top_rated',
              onSelected: (_) => _open(context, sort: 'nearest_top_rated', needsLocation: true),
            ),
          ],
        ),
      ),
    );
  }
}
