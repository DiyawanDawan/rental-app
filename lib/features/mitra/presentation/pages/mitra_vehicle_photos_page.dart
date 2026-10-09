import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/di.dart';
import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _VehiclePhotoItem {
  const _VehiclePhotoItem({required this.id, required this.url});

  final String id;
  final String url;
}

class MitraVehiclePhotosPage extends StatefulWidget {
  const MitraVehiclePhotosPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  State<MitraVehiclePhotosPage> createState() => _MitraVehiclePhotosPageState();
}

class _MitraVehiclePhotosPageState extends State<MitraVehiclePhotosPage> {
  final List<File> _newPhotos = [];
  List<_VehiclePhotoItem> _existingPhotos = [];
  bool _loadingPhotos = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _loadingPhotos = true);
    try {
      final response = await getIt<ApiClient>().get<Map<String, dynamic>>(
        ApiEndpoints.vehicleById(widget.vehicleId),
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final rawPhotos = data['photos'] as List? ?? [];
      _existingPhotos = rawPhotos
          .whereType<Map<String, dynamic>>()
          .map(
            (p) => _VehiclePhotoItem(
              id: p['id']?.toString() ?? '',
              url: p['photoUrl']?.toString() ?? p['url']?.toString() ?? '',
            ),
          )
          .where((p) => p.url.isNotEmpty)
          .toList();
    } catch (_) {
      _existingPhotos = [];
    } finally {
      if (mounted) setState(() => _loadingPhotos = false);
    }
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newPhotos.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  Future<void> _upload() async {
    if (_newPhotos.isEmpty) return;

    final service = context.read<MitraService>();
    final success = await service.uploadVehiclePhotos(
      widget.vehicleId,
      _newPhotos.map((f) => f.path).toList(),
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Berhasil mengunggah foto');
      setState(() => _newPhotos.clear());
      await _loadPhotos();
      await service.loadVehicles();
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal mengunggah foto');
    }
  }

  Future<void> _deletePhoto(_VehiclePhotoItem photo) async {
    if (photo.id.isEmpty) return;

    final service = context.read<MitraService>();
    final success = await service.deleteVehiclePhoto(widget.vehicleId, photo.id);
    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Foto dihapus');
      await _loadPhotos();
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal menghapus foto');
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MitraService>();
    final isUploading = service.status == MitraStatus.loading && service.uploadProgress != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri Foto'),
      ),
      body: ListView(
        padding: AppPadding.list,
        children: [
          Text('Foto Saat Ini', style: AppTextStyles.titleMedium),
          AppGap.md,
          if (_loadingPhotos)
            const Center(child: CircularProgressIndicator())
          else if (_existingPhotos.isEmpty)
            const Center(child: Text('Belum ada foto tambahan'))
          else
            MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              itemCount: _existingPhotos.length,
              itemBuilder: (context, index) {
                final photo = _existingPhotos[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: AppShapes.sm,
                      child: CachedNetworkImage(imageUrl: photo.url, fit: BoxFit.cover),
                    ),
                    if (photo.id.isNotEmpty)
                      Positioned(
                        top: AppSpacing.xs,
                        right: AppSpacing.xs,
                        child: GestureDetector(
                          onTap: () => _deletePhoto(photo),
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.xxs),
                            decoration: const BoxDecoration(
                              color: AppColors.critical,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 14.sp, color: AppColors.onDark),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          AppGap.section,
          const Divider(),
          AppGap.section,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Foto Baru', style: AppTextStyles.titleMedium),
              if (_newPhotos.isNotEmpty)
                TextButton(
                  onPressed: _upload,
                  child: const Text('Unggah Sekarang'),
                ),
            ],
          ),
          AppGap.md,
          if (isUploading) ...[
            LinearProgressIndicator(value: service.uploadProgress),
            AppGap.sm,
            Text(
              service.uploadProgressLabel ?? 'Mengunggah foto...',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            AppGap.md,
          ],
          if (_newPhotos.isEmpty)
            Center(
              child: OutlinedButton.icon(
                onPressed: _pickPhotos,
                icon: Icon(LucideIcons.imagePlus),
                label: const Text('Pilih Foto dari Galeri'),
              ),
            )
          else
            MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              itemCount: _newPhotos.length + 1,
              itemBuilder: (context, index) {
                if (index == _newPhotos.length) {
                  return GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withValues(alpha: 0.3),
                        borderRadius: AppShapes.sm,
                        border: Border.all(color: AppColors.lightGray),
                      ),
                      child: Icon(LucideIcons.plus, color: AppColors.navy),
                    ),
                  );
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: AppShapes.sm,
                      child: Image.file(_newPhotos[index], fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: GestureDetector(
                        onTap: () => setState(() => _newPhotos.removeAt(index)),
                        child: Container(
                          padding: EdgeInsets.all(AppSpacing.xxs),
                          decoration: const BoxDecoration(
                            color: AppColors.critical,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 14.sp, color: AppColors.onDark),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
