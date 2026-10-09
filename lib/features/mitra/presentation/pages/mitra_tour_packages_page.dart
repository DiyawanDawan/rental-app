import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';

class MitraTourPackagesPage extends StatefulWidget {
  const MitraTourPackagesPage({super.key});

  @override
  State<MitraTourPackagesPage> createState() => _MitraTourPackagesPageState();
}

class _MitraTourPackagesPageState extends State<MitraTourPackagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadTourPackages();
    });
  }

  Future<void> _toggleStatus(MitraService service, Map<String, dynamic> pkg) async {
    final id = pkg['id']?.toString();
    if (id == null) return;
    final current = pkg['status']?.toString() ?? 'ACTIVE';
    final next = current == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    final success = await service.updateTourPackage(id, {'status': next});
    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, next == 'ACTIVE' ? 'Paket diaktifkan' : 'Paket dinonaktifkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paket Wisata'),
        actions: [
          IconButton(
            tooltip: 'Kelola destinasi',
            icon: Icon(LucideIcons.mapPinned),
            onPressed: () => context.push(AppRoutePaths.mitraDestinationForm),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutePaths.mitraTourPackageForm),
        icon: Icon(LucideIcons.plus),
        label: const Text('Tambah'),
      ),
      body: Consumer<MitraService>(
        builder: (context, service, _) {
          if (service.status == MitraStatus.loading && service.tourPackages.isEmpty) {
            return const AppLoadingView();
          }

          if (service.tourPackages.isEmpty) {
            return const AppEmptyState(
              icon: LucideIcons.map,
              title: 'Belum ada paket wisata',
              message: 'Buat paket wisata pertama untuk ditawarkan ke pelanggan.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadTourPackages(),
            child: ListView.separated(
              padding: AppPadding.listWithFab,
              itemCount: service.tourPackages.length,
              separatorBuilder: (_, __) => AppGap.sm,
              itemBuilder: (context, index) {
                final pkg = service.tourPackages[index];
                final id = pkg['id']?.toString() ?? '';
                final status = pkg['status']?.toString() ?? 'ACTIVE';
                final isActive = status == 'ACTIVE';

                return StaggeredListItem(
                  index: index,
                  child: Container(
                    decoration: AppDecorations.floatingCard(),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                    title: Text(pkg['name']?.toString() ?? '-', style: AppTextStyles.titleSmall),
                    subtitle: Text(
                      '${MoneyFormatter.rupiah((pkg['basePrice'] as num?)?.toDouble() ?? 0)} \u00b7 $status',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isActive,
                          activeColor: AppColors.teal,
                          onChanged: (_) => _toggleStatus(service, pkg),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              context.push('${AppRoutePaths.mitraTourPackageForm}?id=$id');
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus paket?'),
                                  content: const Text('Paket akan dinonaktifkan.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya')),
                                  ],
                                ),
                              );
                              if (confirmed == true && mounted) {
                                await service.deleteTourPackage(id);
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
