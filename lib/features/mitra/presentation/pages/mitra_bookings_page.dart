import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../customer/presentation/widgets/booking_card.dart';
import '../../../../config/spacing.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/mitra_service.dart';
import '../../data/models/mitra_booking_model.dart';
import '../widgets/mitra_booking_actions.dart';

class MitraBookingsPage extends StatefulWidget {
  const MitraBookingsPage({super.key});

  @override
  State<MitraBookingsPage> createState() => _MitraBookingsPageState();
}

class _MitraBookingsPageState extends State<MitraBookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraService>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pesanan Masuk'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Perlu Diproses'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: Consumer<MitraService>(
          builder: (context, service, child) {
            if (service.status == MitraStatus.loading && service.bookings.isEmpty) {
              return const AppLoadingView();
            }

            final activeBookings = service.bookings
                .where((b) => ['PENDING', 'APPROVED', 'PAID', 'HANDOVER'].contains(b.status))
                .toList();
            final historyBookings = service.bookings
                .where((b) => ['RETURNED', 'REJECTED', 'CANCELLED', 'COMPLETED'].contains(b.status))
                .toList();

            return TabBarView(
              children: [
                _BookingList(bookings: activeBookings, isHistory: false),
                _BookingList(bookings: historyBookings, isHistory: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings, required this.isHistory});

  final List<MitraBookingModel> bookings;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return AppEmptyState(
        icon: LucideIcons.shoppingBag,
        title: isHistory ? 'Belum ada riwayat pesanan' : 'Belum ada pesanan masuk',
        message: isHistory
            ? 'Riwayat pesanan yang selesai akan muncul di sini.'
            : 'Pesanan baru dari pelanggan akan muncul di sini.',
      );
    }

    return ListView.separated(
      padding: AppPadding.list,
      itemCount: bookings.length,
      separatorBuilder: (context, index) => AppGap.md,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          idOnLeft: true,
          data: BookingCardData(
            id: booking.id,
            status: booking.status,
            vehicleName: booking.vehicleName,
            subtitle: 'Customer: ${booking.customerName.isNotEmpty ? booking.customerName : '-'}',
            startDate: booking.startDate,
            endDate: booking.endDate,
            totalPrice: booking.totalPrice,
          ),
          footer: MitraBookingActions(booking: booking),
        );
      },
    );
  }
}
