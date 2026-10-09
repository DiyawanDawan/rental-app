import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../application/chat_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({super.key});

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().loadRooms();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ChatService>().loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan')),
      body: Consumer<ChatService>(
        builder: (context, service, child) {
          if (service.status == ChatStatus.loading && service.rooms.isEmpty) {
            return const AppLoadingView();
          }

          if (service.rooms.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  const AppEmptyState(
                    icon: LucideIcons.messageCircle,
                    title: 'Belum ada pesan',
                    message: 'Percakapan dengan mitra atau rental akan muncul di sini.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: service.rooms.length,
              separatorBuilder: (context, index) => Divider(height: 1.h),
              itemBuilder: (context, index) {
                final room = service.rooms[index];
                final displayName = room.name ?? 'Chat';
                final encodedName = Uri.encodeComponent(displayName);

                return ListTile(
                  onTap: () => context.push('/chat/${room.id}?name=$encodedName'),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.lightGray,
                    backgroundImage: room.otherUserAvatar != null && room.otherUserAvatar!.isNotEmpty
                        ? NetworkImage(room.otherUserAvatar!)
                        : null,
                    child: (room.otherUserAvatar == null || room.otherUserAvatar!.isEmpty)
                        ? const Icon(LucideIcons.user, color: AppColors.navy)
                        : null,
                  ),
                  title: Text(displayName, style: AppTextStyles.titleSmall),
                  subtitle: Text(
                    room.lastMessage ?? 'Belum ada pesan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: room.unreadCount > 0 ? AppColors.navy : AppColors.textTertiary,
                      fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (room.lastMessageTime != null)
                        Text(
                          _formatTime(room.lastMessageTime!),
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp),
                        ),
                      if (room.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(top: AppSpacing.xs),
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final local = date.toLocal();
    final now = DateTime.now();
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day}/${local.month}';
  }
}
