import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/router/router_query_mixin.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import '../../application/customer_service.dart';
import '../../data/models/travel_model.dart';
import '../widgets/travel_schedule_card.dart';

class TravelSearchPage extends StatefulWidget {
  const TravelSearchPage({super.key});

  @override
  State<TravelSearchPage> createState() => _TravelSearchPageState();
}

class _TravelDaySchedules {
  const _TravelDaySchedules({
    required this.date,
    required this.label,
    required this.schedules,
  });

  final String date;
  final String label;
  final List<TravelScheduleModel> schedules;
}

class _TravelSearchPageState extends State<TravelSearchPage> with RouterQueryMixin {
  static const int _upcomingDays = 7;
  static const int _maxPreviewPerDay = 6;

  String? _selectedOrigin;
  String? _selectedDestination;
  DateTime _selectedDate = DateTime.now();

  List<String> _origins = [];
  List<String> _destinations = [];
  List<TravelRouteModel> _allRoutes = [];
  List<_TravelDaySchedules> _upcomingByDay = [];
  bool _isLoading = true;
  bool _isLoadingSchedules = true;

  String? _pendingDestination;

  @override
  void onRouterQueryReady(Map<String, String> queryParameters) {
    final destination = queryParameters['destination'];
    if (destination != null && destination.isNotEmpty) {
      _pendingDestination = destination;
    }
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final routes = await context.read<CustomerService>().getTravelRoutes();
    if (!mounted) return;
    setState(() {
      _allRoutes = routes.where((r) => r.origin.isNotEmpty && r.destination.isNotEmpty).toList();
      _origins = _allRoutes.map((e) => e.origin).toSet().toList()..sort();
      _isLoading = false;
      _applyDefaultRoute();
      _applyPendingDestination();
    });
    await _loadUpcomingSchedules();
  }

  void _applyDefaultRoute() {
    if (_pendingDestination != null || _origins.isEmpty || _selectedOrigin != null) return;

    final first = _allRoutes.firstWhere(
      (r) => r.originRegencyId != null && r.destinationRegencyId != null,
      orElse: () => _allRoutes.first,
    );
    _selectedOrigin = first.origin;
    _destinations = _allRoutes
        .where((e) => e.origin == first.origin)
        .map((e) => e.destination)
        .toSet()
        .toList()
      ..sort();
    _selectedDestination = _destinations.firstOrNull;
  }

  Future<void> _loadUpcomingSchedules() async {
    setState(() => _isLoadingSchedules = true);

    final service = context.read<CustomerService>();
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    final dayResults = await Future.wait(
      List.generate(_upcomingDays, (index) async {
        final day = start.add(Duration(days: index));
        final dateStr = _isoDate(day);
        final schedules = await service.searchTravel(date: dateStr);
        schedules.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        return _TravelDaySchedules(
          date: dateStr,
          label: _dayLabel(day, index),
          schedules: schedules,
        );
      }),
    );

    if (!mounted) return;
    setState(() {
      _upcomingByDay = dayResults.where((d) => d.schedules.isNotEmpty).toList();
      _isLoadingSchedules = false;
    });
  }

  String _isoDate(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  String _dayLabel(DateTime day, int offset) {
    if (offset == 0) return 'Hari ini';
    if (offset == 1) return 'Besok';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
  }

  void _applyPendingDestination() {
    final target = _pendingDestination;
    if (target == null) return;

    final normalized = target.toLowerCase();
    final matchingRoutes = _allRoutes.where(
      (r) => r.destination.toLowerCase().contains(normalized),
    );
    if (matchingRoutes.isEmpty) return;

    final first = matchingRoutes.first;
    _selectedOrigin = first.origin;
    _destinations = _allRoutes
        .where((e) => e.origin == first.origin)
        .map((e) => e.destination)
        .toSet()
        .toList()
      ..sort();

    final exact = _destinations.where((d) => d.toLowerCase().contains(normalized)).toList();
    _selectedDestination = exact.isNotEmpty ? exact.first : _destinations.firstOrNull;
    _pendingDestination = null;
  }

  void _updateDestinations(String? origin) {
    setState(() {
      _selectedOrigin = origin;
      _selectedDestination = null;
      _destinations = _allRoutes
          .where((e) => e.origin == origin)
          .map((e) => e.destination)
          .toSet()
          .toList()
        ..sort();
      if (_pendingDestination != null) {
        _applyPendingDestination();
      }
    });
  }

  TravelRouteModel? _selectedRoute() {
    if (_selectedOrigin == null || _selectedDestination == null) return null;
    for (final route in _allRoutes) {
      if (route.origin == _selectedOrigin && route.destination == _selectedDestination) {
        return route;
      }
    }
    return null;
  }

  void _search() {
    final route = _selectedRoute();
    if (route == null) return;
    if (route.originRegencyId == null || route.destinationRegencyId == null) return;

    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    context.push(
      AppRoutePaths.travelSchedulesWithQuery(
        origin: route.origin,
        destination: route.destination,
        date: dateStr,
        originRegencyId: route.originRegencyId,
        destinationRegencyId: route.destinationRegencyId,
      ),
    );
  }

  void _openAllSchedulesForDay(String date) {
    context.push(
      AppRoutePaths.travelSchedulesWithQuery(
        origin: 'Semua rute',
        destination: '',
        date: date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Travel')),
      body: _isLoading
          ? const AppLoadingView()
          : _allRoutes.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppPadding.screen,
                    child: Text(
                      'Belum ada rute travel tersedia.',
                      style: context.textBodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: AppPadding.screen,
                  children: [
                    _buildDropdown(
                      label: 'Kota Asal',
                      value: _selectedOrigin,
                      items: _origins,
                      icon: LucideIcons.mapPin,
                      onChanged: _updateDestinations,
                    ),
                    AppGap.lg,
                    _buildDropdown(
                      label: 'Kota Tujuan',
                      value: _selectedDestination,
                      items: _destinations,
                      icon: LucideIcons.navigation,
                      onChanged: (val) => setState(() => _selectedDestination = val),
                      enabled: _selectedOrigin != null,
                    ),
                    AppGap.lg,
                    ListTile(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppShapes.sm,
                        side: BorderSide(color: context.cs.outline),
                      ),
                      leading: Icon(LucideIcons.calendar, size: 20.sp),
                      title: Text('Tanggal Keberangkatan', style: context.textBodySmall),
                      subtitle: Text(
                        _selectedDate.toIso8601String().split('T')[0],
                        style: context.textTitleSmall,
                      ),
                      trailing: Icon(Icons.chevron_right, color: context.cs.onSurfaceVariant),
                    ),
                    AppGap.ctaSpacer,
                    ElevatedButton(
                      onPressed: _selectedRoute() == null ? null : _search,
                      child: const Text('Cari Jadwal'),
                    ),
                    AppGap.lg,
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutePaths.vehiclesWithQuery(type: 'BUS')),
                      icon: Icon(LucideIcons.bus, size: 18.sp),
                      label: const Text('Sewa Bus Penuh (Charter)'),
                    ),
                    AppGap.sm,
                    Text(
                      'Share per kursi = jadwal travel di atas. Sewa bus penuh = rental armada bus.',
                      style: context.textBodySmall,
                      textAlign: TextAlign.center,
                    ),
                    AppGap.section,
                    _buildUpcomingSection(),
                    SizedBox(height: AppSpacing.page),
                  ],
                ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Jadwal Terdekat', style: context.textTitleLarge),
        AppGap.xs,
        Text(
          'Perjalanan hari ini dan $_upcomingDays hari ke depan — semua rute.',
          style: context.textBodySmall,
        ),
        AppGap.md,
        if (_isLoadingSchedules)
          const AppShimmerLoading(itemCount: 3)
        else if (_upcomingByDay.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              'Belum ada jadwal tersedia untuk minggu ini.',
              style: context.textBodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        else
          ..._upcomingByDay.expand((day) => _buildDayGroup(day)),
      ],
    );
  }

  List<Widget> _buildDayGroup(_TravelDaySchedules day) {
    final preview = day.schedules.take(_maxPreviewPerDay).toList();
    final remaining = day.schedules.length - preview.length;

    return [
      Padding(
        padding: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(day.label, style: context.textTitleSmall),
            ),
            Text(
              day.date,
              style: context.textCaption,
            ),
          ],
        ),
      ),
      for (var i = 0; i < preview.length; i++) ...[
        if (i > 0) SizedBox(height: AppSpacing.listGap),
        TravelScheduleCard(
          schedule: preview[i],
          showEarliestBadge: i == 0,
        ),
      ],
      if (remaining > 0) ...[
        AppGap.sm,
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _openAllSchedulesForDay(day.date),
            child: Text('+$remaining jadwal lainnya'),
          ),
        ),
      ],
      AppGap.sm,
    ];
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20.sp),
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      hint: Text(enabled ? 'Pilih $label' : 'Pilih asal terlebih dahulu'),
    );
  }
}
