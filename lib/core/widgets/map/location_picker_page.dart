import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/di.dart';
import '../../../config/color.dart';
import '../../../config/text_styles.dart';
import '../../../config/spacing.dart';
import '../../../features/customer/data/customer_repository.dart';
import '../layout/scroll_safe_padding.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({this.initialLocation, super.key});

  final LatLng? initialLocation;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _currentLocation;
  final MapController _mapController = MapController();
  bool _isSatellite = false;
  String _address = 'Mencari alamat...';
  bool _isGeocoding = false;
  bool _isLocating = false;
  Timer? _geocodeDebounce;
  int _geocodeRequest = 0;

  @override
  void initState() {
    super.initState();
    _currentLocation =
        widget.initialLocation ?? const LatLng(-6.2000, 106.8166);
    if (widget.initialLocation == null) {
      _locateDevice(showError: false);
    } else {
      _performReverseGeocode();
    }
  }

  Future<void> _performReverseGeocode() async {
    final requestId = ++_geocodeRequest;
    final location = _currentLocation;
    if (mounted) setState(() => _isGeocoding = true);
    try {
      final response = await getIt<CustomerRepository>().reverseGeocode(
        location.latitude,
        location.longitude,
      );
      if (mounted && requestId == _geocodeRequest) {
        setState(() {
          _address = response.data ?? 'Alamat tidak ditemukan';
          _isGeocoding = false;
        });
      }
    } catch (e) {
      if (mounted && requestId == _geocodeRequest) {
        setState(() {
          _address = 'Gagal memuat alamat';
          _isGeocoding = false;
        });
      }
    }
  }

  void _scheduleReverseGeocode() {
    _geocodeDebounce?.cancel();
    if (mounted) setState(() => _isGeocoding = true);
    _geocodeDebounce = Timer(
      const Duration(milliseconds: 450),
      _performReverseGeocode,
    );
  }

  Future<void> _locateDevice({bool showError = true}) async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Layanan lokasi perangkat sedang nonaktif');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diperlukan untuk menemukan posisi Anda');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _currentLocation = location;
        _address = 'Mencari alamat...';
      });
      _mapController.move(location, 16);
      _scheduleReverseGeocode();
    } catch (error) {
      if (mounted && showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          IconButton(
            icon: Icon(_isSatellite ? LucideIcons.map : LucideIcons.layers),
            onPressed: () => setState(() => _isSatellite = !_isSatellite),
            tooltip: 'Ganti Layer',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  setState(() {
                    _currentLocation = event.camera.center;
                  });
                  _scheduleReverseGeocode();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travelindo.app',
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xxl + AppSpacing.md),
              child: Icon(
                LucideIcons.mapPin,
                color: AppColors.critical,
                size: 40.sp,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: ScrollSafePadding.bottomInset(context),
                ),
                child: Card(
                  child: Padding(
                    padding: AppPadding.list,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 18.sp,
                              color: AppColors.orange,
                            ),
                            AppGap.h(AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _isGeocoding ? 'Mencari alamat...' : _address,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        AppGap.md,
                        Text(
                          'Lat: ${_currentLocation.latitude.toStringAsFixed(6)}, Lng: ${_currentLocation.longitude.toStringAsFixed(6)}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        AppGap.lg,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isGeocoding
                                ? null
                                : () => Navigator.pop(context, {
                                    'latlng': _currentLocation,
                                    'address': _address,
                                  }),
                            child: const Text('Konfirmasi Lokasi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.xl,
            bottom:
                AppSpacing.mapPickerFabClearance +
                MediaQuery.paddingOf(context).bottom,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.surface,
              onPressed: _isLocating ? null : _locateDevice,
              child: _isLocating
                  ? SizedBox(
                      width: 18.sp,
                      height: 18.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(LucideIcons.locateFixed, color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}
