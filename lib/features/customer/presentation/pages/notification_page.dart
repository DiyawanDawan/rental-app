import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../application/customer_service.dart';
import '../../data/models/notification_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerService>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<CustomerService>().markAllNotificationsAsRead(),
            child: Text(
              'Baca Semua',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.onDark),
            ),
          ),
        ],
      ),
      body: Consumer<CustomerService>(
        builder: (context, service, child) {
          if (service.status == CustomerStatus.loading &&
              service.notifications.isEmpty) {
            return const AppLoadingView();
          }

          if (service.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.bellOff,
                    size: 64.sp,
                    color: AppColors.mediumGray,
                  ),
                  AppGap.lg,
                  Text(
                    'Belum ada notifikasi',
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadNotifications(),
            child: ListView.separated(
              padding: AppPadding.list,
              itemCount: service.notifications.length,
              separatorBuilder: (context, index) => Divider(height: 1.h),
              itemBuilder: (context, index) {
                final notif = service.notifications[index];
                return ListTile(
                  onTap: () {
                    if (!notif.isRead) {
                      service.markNotificationAsRead(notif.id);
                    }
                    _navigateFromNotification(context, notif);
                  },
                  contentPadding: EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: notif.isRead
                        ? AppColors.lightGray
                        : AppColors.orange.withValues(alpha: 0.1),
                    child: Icon(
                      _getIcon(notif.type),
                      color: notif.isRead
                          ? AppColors.darkGray
                          : AppColors.orange,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: notif.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppGap.xs,
                      Text(notif.body, style: AppTextStyles.bodySmall),
                      AppGap.xs,
                      Text(
                        _formatTime(notif.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (notif.actionLabel != null &&
                          notif.actionLabel!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => _openAction(notif),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(notif.actionLabel!),
                          ),
                        ),
                    ],
                  ),
                  trailing: notif.isRead
                      ? null
                      : CircleAvatar(
                          radius: notif.priority == 'URGENT' ? 5.r : 4.r,
                          backgroundColor: notif.priority == 'URGENT'
                              ? AppColors.critical
                              : AppColors.orange,
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'BOOKING':
        return LucideIcons.calendarCheck;
      case 'PAYMENT':
        return LucideIcons.wallet;
      case 'PROMOTION':
      case 'PROMO':
        return LucideIcons.ticket;
      case 'CHAT':
        return LucideIcons.messageSquare;
      default:
        return LucideIcons.bell;
    }
  }

  void _navigateFromNotification(
    BuildContext context,
    NotificationModel notif,
  ) {
    if (notif.actionLink != null && notif.actionLink!.startsWith('/')) {
      context.push(notif.actionLink!);
      return;
    }
    final data = notif.data ?? {};
    switch (notif.type) {
      case 'BOOKING':
      case 'DOCUMENT':
      case 'REMINDER':
        final bookingId = data['bookingId']?.toString();
        if (bookingId != null && bookingId.isNotEmpty) {
          context.push('/bookings/$bookingId');
        } else {
          context.go(AppRoutePaths.bookings);
        }
      case 'PAYMENT':
      case 'REFUND':
        context.go('/wallet');
      case 'CHAT':
        final roomId = data['roomId']?.toString();
        if (roomId != null && roomId.isNotEmpty) {
          context.push('/chat/$roomId');
        } else {
          context.push('/chat');
        }
      case 'PAYOUT':
      case 'INCOME':
        context.go(AppRoutePaths.mitraDashboard);
      case 'PROMOTION':
      case 'PROMO':
        final vehicleId = data['vehicleId']?.toString();
        final mitraId = data['mitraId']?.toString();
        final packageId = data['packageId']?.toString();
        if (vehicleId != null && vehicleId.isNotEmpty) {
          context.push(AppRoutePaths.vehicleDetail(vehicleId));
        } else if (packageId != null && packageId.isNotEmpty) {
          context.push('/tours/$packageId');
        } else if (mitraId != null && mitraId.isNotEmpty) {
          context.push(AppRoutePaths.mitraPublicProfile(mitraId));
        }
      default:
        break;
    }
  }

  void _openAction(NotificationModel notif) {
    if (notif.actionLink == null || notif.actionLink!.isEmpty) return;
    _navigateFromNotification(context, notif);
  }

  String _formatTime(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      return timeago.format(date, locale: 'id');
    } catch (_) {
      return createdAt;
    }
  }
}
