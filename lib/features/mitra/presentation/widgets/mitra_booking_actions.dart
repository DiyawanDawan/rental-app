import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../chat/application/chat_service.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_booking_model.dart';

/// Action buttons for mitra booking card based on status.
class MitraBookingActions extends StatelessWidget {
  const MitraBookingActions({required this.booking, super.key});

  final MitraBookingModel booking;

  Future<void> _chatCustomer(BuildContext context) async {
    final chatService = context.read<ChatService>();
    final room = await chatService.createRoom(bookingId: booking.id);
    if (!context.mounted) return;
    if (room != null) {
      final nameParam = Uri.encodeComponent(
        booking.customerName.isNotEmpty ? booking.customerName : 'Pelanggan',
      );
      context.push('/chat/${room.id}?name=$nameParam');
    } else {
      SnackbarUtils.showError(context, 'Gagal membuka chat dengan pelanggan');
    }
  }

  Future<void> _pickAndHandover(BuildContext context) async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo == null || !context.mounted) return;

    final service = context.read<MitraService>();
    final success = await service.handoverBookingWithPhoto(
      booking.id,
      photoPath: photo.path,
    );

    if (!context.mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Serah terima berhasil');
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal serah terima');
    }
  }

  Future<void> _pickAndReturn(BuildContext context) async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo == null || !context.mounted) return;

    final service = context.read<MitraService>();
    final success = await service.returnBookingWithPhoto(
      booking.id,
      photoPath: photo.path,
    );

    if (!context.mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Pengembalian berhasil');
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal pengembalian');
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<MitraService>();

    Widget actionButton = const SizedBox.shrink();

    if (booking.status == 'PENDING') {
      actionButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              final reasonController = TextEditingController();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tolak Pesanan'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Yakin ingin menolak pesanan ini?'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Alasan penolakan (opsional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                      child: const Text('Tolak'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                final reason = reasonController.text.trim();
                service.rejectBooking(booking.id, reason: reason.isNotEmpty ? reason : null);
              }
            },
            child: Text('Tolak', style: AppTextStyles.labelLarge.copyWith(color: AppColors.critical)),
          ),
          ElevatedButton(
            onPressed: () => service.approveBooking(booking.id),
            child: const Text('Terima'),
          ),
        ],
      );
    } else if (booking.status == 'PAID') {
      actionButton = ElevatedButton(
        onPressed: () => _pickAndHandover(context),
        child: const Text('Serah Terima'),
      );
    } else if (booking.status == 'APPROVED') {
      actionButton = Text(
        'Menunggu pembayaran customer',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGray),
      );
    } else if (booking.status == 'HANDOVER') {
      actionButton = ElevatedButton(
        onPressed: () => _pickAndReturn(context),
        child: const Text('Pengembalian'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: () => _chatCustomer(context),
          icon: const Icon(LucideIcons.messageSquare, size: 16, color: AppColors.orange),
          label: Text('Chat', style: AppTextStyles.labelMedium.copyWith(color: AppColors.orange)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.orange),
            visualDensity: VisualDensity.compact,
          ),
        ),
        actionButton,
      ],
    );
  }
}
