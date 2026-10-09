import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/services/user_location_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/inputs/app_filter_chip.dart';
import '../../../../core/widgets/motion/animated_filter_switcher.dart';

class HomeTourQuickChips extends StatefulWidget {
  const HomeTourQuickChips({super.key});

  @override
  State<HomeTourQuickChips> createState() => _HomeTourQuickChipsState();
}

class _HomeTourQuickChipsState extends State<HomeTourQuickChips> {
  String _active = 'price_asc';

  Future<void> _open(BuildContext context, {required String sort, bool needsLocation = false}) async {
    setState(() => _active = sort);

    if (!needsLocation) {
      context.push(AppRoutePaths.tourPackagesWithQuery(sort: sort));
      return;
    }

    final position = await UserLocationService.instance.getCurrentPosition();
    if (!context.mounted) return;
    if (position == null) {
      SnackbarUtils.showError(context, 'Izinkan lokasi untuk sort wisata berdasarkan jarak.');
    }
    context.push(AppRoutePaths.tourPackagesWithQuery(sort: sort));
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
              label: const Text('Terdekat'),
              selected: _active == 'distance_asc',
              onSelected: (_) => _open(context, sort: 'distance_asc', needsLocation: true),
            ),
            AppGap.h(AppSpacing.sm),
            AppFilterChip(
              label: const Text('Terdekat & termurah'),
              selected: _active == 'nearest_cheapest',
              onSelected: (_) => _open(context, sort: 'nearest_cheapest', needsLocation: true),
            ),
          ],
        ),
      ),
    );
  }
}
