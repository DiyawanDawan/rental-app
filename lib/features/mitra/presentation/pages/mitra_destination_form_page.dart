import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/mitra_service.dart';

class MitraDestinationFormPage extends StatefulWidget {
  const MitraDestinationFormPage({this.destinationId, super.key});

  final String? destinationId;

  @override
  State<MitraDestinationFormPage> createState() => _MitraDestinationFormPageState();
}

class _MitraDestinationFormPageState extends State<MitraDestinationFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _videoUrlController = TextEditingController();

  final List<_MediaDraft> _photos = [];
  bool _isSubmitting = false;
  bool _isUploading = false;

  bool get _isEdit => widget.destinationId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadDestination();
    }
  }

  Future<void> _loadDestination() async {
    final destinations = await context.read<MitraService>().getTourDestinations();
    final match = destinations.where((d) => d['id']?.toString() == widget.destinationId).firstOrNull;
    if (match == null || !mounted) return;

    _nameController.text = match['name']?.toString() ?? '';
    _descriptionController.text = match['description']?.toString() ?? '';
    _addressController.text = match['address']?.toString() ?? '';
    _latController.text = match['latitude']?.toString() ?? '';
    _lngController.text = match['longitude']?.toString() ?? '';

    final media = match['media'];
    if (media is List) {
      for (final item in media) {
        if (item is! Map<String, dynamic>) continue;
        final type = item['mediaType']?.toString() ?? 'IMAGE';
        final url = item['url']?.toString() ?? '';
        if (url.isEmpty) continue;
        if (type == 'VIDEO') {
          _videoUrlController.text = url;
        } else if (type == 'IMAGE') {
          _photos.add(_MediaDraft(url: url, isPrimary: item['isPrimary'] == true));
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 75);
    if (files.isEmpty || !mounted) return;

    setState(() => _isUploading = true);
    final service = context.read<MitraService>();
    for (final file in files) {
      final url = await service.uploadImage(file.path);
      if (url != null) {
        _photos.add(_MediaDraft(url: url, isPrimary: _photos.isEmpty));
      }
    }
    if (mounted) setState(() => _isUploading = false);
  }

  Map<String, dynamic> _buildPayload() {
    final media = <Map<String, dynamic>>[
      ..._photos.asMap().entries.map(
            (e) => {
              'url': e.value.url,
              'mediaType': 'IMAGE',
              'isPrimary': e.key == 0,
            },
          ),
    ];
    final videoUrl = _videoUrlController.text.trim();
    if (videoUrl.isNotEmpty) {
      media.add({'url': videoUrl, 'mediaType': 'VIDEO'});
    }

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
    };
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat != null) payload['latitude'] = lat;
    if (lng != null) payload['longitude'] = lng;
    if (media.isNotEmpty) payload['media'] = media;
    return payload;
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().length < 3) {
      SnackbarUtils.showError(context, 'Nama destinasi minimal 3 karakter.');
      return;
    }

    setState(() => _isSubmitting = true);
    final service = context.read<MitraService>();
    final payload = _buildPayload();
    final success = _isEdit
        ? await service.updateTourDestination(widget.destinationId!, payload)
        : await service.createTourDestination(payload);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      SnackbarUtils.showSuccess(context, _isEdit ? 'Destinasi diperbarui' : 'Destinasi dibuat');
      context.pop(true);
    } else {
      SnackbarUtils.showError(context, service.message ?? 'Gagal menyimpan destinasi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Destinasi' : 'Tambah Destinasi')),
      body: ListView(
        padding: AppPadding.list,
        children: [
          Container(
            padding: AppPadding.card,
            decoration: AppDecorations.elevatedSurface(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi destinasi untuk pelanggan — foto, video, deskripsi, dan lokasi.',
                  style: AppTextStyles.bodySmall,
                ),
                AppGap.lg,
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama destinasi *'),
                ),
                AppGap.md,
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi / informasi wisata'),
                  maxLines: 5,
                ),
                AppGap.md,
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                AppGap.md,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    AppGap.h(AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lngController,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppGap.section,
          Text('Galeri Foto', style: AppTextStyles.titleSmall),
          AppGap.sm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ..._photos.map(
                (photo) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppShapes.sm,
                      child: Image.network(photo.url, width: 88.w, height: 88.w, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.remove(photo)),
                        child: CircleAvatar(
                          radius: 12.r,
                          backgroundColor: AppColors.critical,
                          child: Icon(LucideIcons.x, size: 14.sp, color: AppColors.onDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _isUploading ? null : _pickPhotos,
                child: Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGray),
                    borderRadius: AppShapes.sm,
                  ),
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : Icon(LucideIcons.imagePlus, color: AppColors.orange),
                ),
              ),
            ],
          ),
          AppGap.section,
          TextField(
            controller: _videoUrlController,
            decoration: const InputDecoration(
              labelText: 'URL Video (opsional)',
              hintText: 'https://...mp4 atau YouTube',
            ),
          ),
          AppGap.section,
          ElevatedButton(
            onPressed: _isSubmitting || _isUploading ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isEdit ? 'Simpan Perubahan' : 'Publikasikan Destinasi'),
          ),
        ],
      ),
    );
  }
}

class _MediaDraft {
  _MediaDraft({required this.url, this.isPrimary = false});
  final String url;
  final bool isPrimary;
}
