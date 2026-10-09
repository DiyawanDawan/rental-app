import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/motion/staggered_list_item.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';

class MitraTravelSchedulesPage extends StatefulWidget {
  const MitraTravelSchedulesPage({super.key});

  @override
  State<MitraTravelSchedulesPage> createState() => _MitraTravelSchedulesPageState();
}

class _MitraTravelSchedulesPageState extends State<MitraTravelSchedulesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadTravelSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Shuttle')),
      body: Consumer<MitraService>(
        builder: (context, service, child) {
          if (service.status == MitraStatus.loading && service.travelSchedules.isEmpty) {
            return const AppLoadingView();
          }

          if (service.travelSchedules.isEmpty) {
            return const AppEmptyState(
              icon: LucideIcons.bus,
              title: 'Belum ada jadwal',
              message: 'Jadwal shuttle mitra akan tampil di sini.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadTravelSchedules(),
            child: ListView.separated(
              padding: AppPadding.list,
              itemCount: service.travelSchedules.length,
              separatorBuilder: (_, __) => AppGap.v(AppSpacing.listGap),
              itemBuilder: (context, index) {
                final schedule = service.travelSchedules[index];
                final id = schedule['id']?.toString() ?? '';
                return StaggeredListItem(
                  index: index,
                  child: Container(
                    decoration: AppDecorations.floatingCard(),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                    title: Text(
                      '${schedule['origin'] ?? '-'} \u2192 ${schedule['destination'] ?? '-'}',
                      style: AppTextStyles.titleSmall,
                    ),
                    subtitle: Text('${schedule['departureTime'] ?? '-'} · ${schedule['status'] ?? '-'}'),
                    trailing: IconButton(
                      icon: Icon(LucideIcons.trash2, color: AppColors.critical),
                      onPressed: id.isEmpty ? null : () => service.cancelTravelSchedule(id),
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
