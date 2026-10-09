import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/image_cache_url.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/badges/status_badge.dart';
import '../../../../core/widgets/layout/scroll_safe_padding.dart';
import '../../../../core/widgets/media/app_cached_network_image.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../customer/application/customer_service.dart';
import '../../../customer/data/models/amenity_model.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_vehicle_model.dart';
import '../../data/models/vehicle_enums.dart';

class MitraVehiclesPage extends StatefulWidget {
  const MitraVehiclesPage({super.key});

  @override
  State<MitraVehiclesPage> createState() => _MitraVehiclesPageState();
}

class _MitraVehiclesPageState extends State<MitraVehiclesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadVehicles();
    });
  }

  void _refresh() {
    context.read<MitraService>().loadVehicles();
  }

  void _showAmenitiesDialog(BuildContext context, MitraVehicleModel vehicle) {
    final selectedIds = vehicle.amenities.map((a) => a['id']?.toString() ?? '').toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.sheetTop),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setDialogState) {
          return SafeArea(
            child: Padding(
              padding: ScrollSafePadding.sheetPadding(sheetCtx),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelola Fasilitas', style: AppTextStyles.titleLarge),
                  AppGap.xs,
                  Text(vehicle.name, style: AppTextStyles.bodySmall),
                  const Divider(),
                  AppGap.md,
                  FutureBuilder<List<AmenityModel>>(
                    future: sheetCtx.read<CustomerService>().getAmenities(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const AppLoadingView();
                      if (snapshot.hasError) {
                        return Text(
                          'Gagal memuat fasilitas',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        );
                      }
                      final allAmenities = snapshot.data ?? const [];

                      return Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: allAmenities.map((amenity) {
                          final isSelected = selectedIds.contains(amenity.id);
                          return FilterChip(
                            avatar: amenity.iconUrl != null
                                ? Image.network(amenity.iconUrl!, width: 18, height: 18, errorBuilder: (_, __, ___) => const SizedBox.shrink())
                                : null,
                            label: Text(amenity.name),
                            selected: isSelected,
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  selectedIds.add(amenity.id);
                                } else {
                                  selectedIds.remove(amenity.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  AppGap.ctaSpacer,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await sheetCtx
                            .read<MitraService>()
                            .updateVehicleAmenities(vehicle.id, selectedIds);
                        if (success && sheetCtx.mounted) {
                          Navigator.pop(sheetCtx);
                          SnackbarUtils.showSuccess(context, 'Fasilitas berhasil diperbarui');
                        }
                      },
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('mitra_vehicles_page'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          _refresh();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan Saya'),
      ),
      body: Consumer<MitraService>(
        builder: (context, service, child) {
          if (service.status == MitraStatus.loading && service.vehicles.isEmpty) {
            return const AppLoadingView();
          }

          if (service.vehicles.isEmpty) {
            return AppEmptyState(
              icon: LucideIcons.car,
              title: 'Belum ada armada',
              message: 'Mulai kelola bisnis Anda dengan menambahkan armada pertama.',
              actionLabel: 'Tambah Armada Sekarang',
              onAction: () => context.push(AppRoutePaths.mitraAddVehicle),
            );
          }

          return ListView.separated(
            padding: ScrollSafePadding.withFab(horizontal: AppSpacing.page, top: AppSpacing.page),
            itemCount: service.vehicles.length,
            separatorBuilder: (context, index) => AppGap.md,
            itemBuilder: (context, index) {
              final vehicle = service.vehicles[index];
              return StaggeredListItem(
                index: index,
                child: _VehicleItemCard(
                  vehicle: vehicle,
                  onAmenitiesTap: () => _showAmenitiesDialog(context, vehicle),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutePaths.mitraAddVehicle),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Tambah Armada'),
      ),
      ),
    );
  }
}

class _VehicleItemCard extends StatelessWidget {
  const _VehicleItemCard({required this.vehicle, required this.onAmenitiesTap});

  final MitraVehicleModel vehicle;
  final VoidCallback onAmenitiesTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.floatingCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            onTap: () => context.push(AppRoutePaths.mitraEditVehicle(vehicle.id)),
            leading: ClipRRect(
              borderRadius: AppShapes.sm,
              child: SizedBox(
                width: 60.w,
                height: 60.h,
                child: vehicle.primaryPhotoUrl == null
                    ? Container(color: AppColors.lightGray, child: const Icon(LucideIcons.car))
                    : AppCachedNetworkImage(
                        imageUrl: cacheBustImageUrl(vehicle.primaryPhotoUrl!, version: vehicle.id),
                        fit: BoxFit.cover,
                        errorIcon: LucideIcons.car,
                      ),
              ),
            ),
            title: Text(vehicle.name, style: AppTextStyles.titleSmall),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} \u00b7 ${MoneyFormatter.rupiah(vehicle.pricePerDay)}/hari',
                  style: AppTextStyles.bodySmall,
                ),
                AppGap.xs,
                Builder(builder: (context) {
                  final statusEnum = VehicleStatusEnum.fromString(vehicle.status);
                  return StatusBadge(
                    label: statusEnum.label,
                    color: _statusColor(statusEnum),
                  );
                }),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
          Divider(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutePaths.mitraEditVehicle(vehicle.id)),
                      icon: Icon(LucideIcons.pencil, size: 16.sp),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: onAmenitiesTap,
                      icon: Icon(LucideIcons.listChecks, size: 16.sp),
                      label: const Text('Fasilitas'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Kendaraan'),
                            content: Text('Hapus ${vehicle.name} dari armada?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          final ok = await context.read<MitraService>().deleteVehicle(vehicle.id);
                          if (context.mounted) {
                            SnackbarUtils.showSuccess(context, ok ? 'Kendaraan dihapus' : 'Gagal menghapus');
                          }
                        }
                      },
                      icon: Icon(LucideIcons.trash2, size: 16.sp, color: AppColors.critical),
                      label: Text('Hapus', style: AppTextStyles.labelLarge.copyWith(color: AppColors.critical)),
                    ),
                    if (vehicle.status == VehicleStatusEnum.unavailable.value)
                      TextButton.icon(
                        onPressed: () async {
                          final ok = await context.read<MitraService>().restoreVehicle(vehicle.id);
                          if (context.mounted) {
                            SnackbarUtils.showSuccess(context, ok
                              ? 'Kendaraan diajukan untuk verifikasi ulang'
                              : 'Gagal memulihkan kendaraan');
                          }
                        },
                        icon: Icon(LucideIcons.refreshCw, size: 16.sp, color: AppColors.primary),
                        label: Text('Pulihkan', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Beroperasi (Tersedia)'),
                  value: VehicleStatusEnum.fromString(vehicle.status).isOperational,
                  onChanged: (value) {
                    context.read<MitraService>().updateVehicleStatus(
                          vehicle.id,
                          value
                              ? VehicleStatusEnum.available.value
                              : VehicleStatusEnum.unavailable.value,
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(VehicleStatusEnum s) {
    switch (s) {
      case VehicleStatusEnum.available:
        return AppColors.success;
      case VehicleStatusEnum.maintenance:
        return AppColors.warning;
      case VehicleStatusEnum.pendingApproval:
        return AppColors.primary;
      case VehicleStatusEnum.unavailable:
        return AppColors.statusUnavailable;
    }
  }
}
