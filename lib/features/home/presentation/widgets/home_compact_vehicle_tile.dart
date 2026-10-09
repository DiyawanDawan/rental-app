import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/hero_tags.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/utils/image_cache_url.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../config/decorations.dart';
import '../../../../core/utils/precache_network_image.dart';
import '../../../../core/widgets/interaction/animated_inkwell.dart';
import '../../../../core/widgets/media/app_cached_network_image.dart';
import '../../../../core/widgets/motion/app_hero.dart';
import '../../../customer/data/models/vehicle_model.dart';

class HomeCompactVehicleTile extends StatelessWidget {
  const HomeCompactVehicleTile({required this.vehicle, super.key});

  final VehicleModel vehicle;

  Future<void> _openDetail(BuildContext context) async {
    final photoUrl = vehicle.primaryPhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await precacheNetworkImageUrl(
        context,
        cacheBustImageUrl(photoUrl, version: vehicle.id),
      );
    }
    if (!context.mounted) return;
    context.push(AppRoutePaths.vehicleDetail(vehicle.id));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: () => _openDetail(context),
      borderRadius: AppShapes.md,
      child: Container(
        decoration: AppDecorations.floatingCardOf(context),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          leading: ClipRRect(
            borderRadius: AppShapes.sm,
            child: SizedBox(
              width: 64.w,
              height: 64.h,
              child: _VehicleThumb(vehicle: vehicle),
            ),
          ),
          title: Text(vehicle.name, style: context.textTitleSmall),
          subtitle: Text(
            '${vehicle.brand ?? '-'} \u00b7 ${MoneyFormatter.rupiah(vehicle.pricePerDay)}/hari',
            style: context.textBodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(LucideIcons.chevronRight, color: context.cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _VehicleThumb extends StatelessWidget {
  const _VehicleThumb({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (vehicle.primaryPhotoUrl == null) {
      image = Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(LucideIcons.car, color: Theme.of(context).colorScheme.primary),
      );
    } else {
      image = AppCachedNetworkImage(
        imageUrl: cacheBustImageUrl(vehicle.primaryPhotoUrl!, version: vehicle.id),
        fit: BoxFit.cover,
        errorIcon: LucideIcons.car,
      );
    }

    return AppHero(
      tag: AppHeroTags.vehiclePhoto(vehicle.id),
      child: image,
    );
  }
}
