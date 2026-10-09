import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _simNumberController = TextEditingController();
  File? _ktpImage;
  File? _simImage;
  File? _selfieImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nikController.dispose();
    _simNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type, {bool useCamera = false}) async {
    final pickedFile = await _picker.pickImage(
      source: useCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        if (type == 'ktp') _ktpImage = File(pickedFile.path);
        if (type == 'sim') _simImage = File(pickedFile.path);
        if (type == 'selfie') _selfieImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_ktpImage == null || _simImage == null || _selfieImage == null) {
      SnackbarUtils.showError(context, 'Mohon lengkapi semua dokumen (KTP, SIM, dan Selfie)');
      return;
    }

    final success = await context.read<AuthService>().submitVerification(
          ktpPath: _ktpImage!.path,
          simPath: _simImage!.path,
          selfiePath: _selfieImage!.path,
          ktpNumber: _nikController.text.trim(),
          simNumber: _simNumberController.text.trim().isEmpty ? null : _simNumberController.text.trim(),
        );

    if (success && mounted) {
      SnackbarUtils.showSuccess(context, 'Dokumen berhasil dikirim untuk verifikasi');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isLoading = authService.isLoading;
    final uploadProgress = authService.uploadDocProgress;

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Identitas (KYC)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.screen,
          children: [
            if (authService.isKycRejected) ...[
              Container(
                padding: AppPadding.card,
                decoration: BoxDecoration(
                  color: AppColors.critical.withValues(alpha: 0.1),
                  borderRadius: AppShapes.md,
                  border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.circleAlert, color: AppColors.critical, size: 20.sp),
                    AppGap.md,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengajuan Verifikasi Sebelumnya Ditolak',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.critical),
                          ),
                          AppGap.xs,
                          Text(
                            authService.kycRejectionReason ?? 'Mohon periksa dan unggah kembali dokumen identitas yang valid.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.lg,
            ],
            Text(
              'Lengkapi data dan dokumen berikut untuk verifikasi akun resmi Anda di Travelindo.',
              style: AppTextStyles.bodyMedium,
            ),
            AppGap.lg,
            TextFormField(
              controller: _nikController,
              decoration: const InputDecoration(
                labelText: 'Nomor Induk Kependudukan (NIK)*',
                hintText: '16 digit NIK sesuai KTP',
                prefixIcon: Icon(LucideIcons.idCard),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
              validator: AuthValidators.nik,
            ),
            AppGap.md,
            TextFormField(
              controller: _simNumberController,
              decoration: const InputDecoration(
                labelText: 'Nomor SIM (Opsional)',
                hintText: 'Nomor Surat Izin Mengemudi',
                prefixIcon: Icon(LucideIcons.car),
              ),
              keyboardType: TextInputType.number,
            ),
            AppGap.lg,
            _UploadCard(
              title: 'Foto KTP',
              image: _ktpImage,
              onTap: () => _pickImage('ktp'),
            ),
            AppGap.lg,
            _UploadCard(
              title: 'Foto SIM',
              image: _simImage,
              onTap: () => _pickImage('sim'),
            ),
            AppGap.lg,
            _UploadCard(
              title: 'Selfie dengan Identitas',
              image: _selfieImage,
              onTap: () => _pickImage('selfie', useCamera: true),
            ),
            SizedBox(height: 32.h),
            if (isLoading && uploadProgress != null) ...[
              LinearProgressIndicator(value: uploadProgress),
              AppGap.sm,
              Text(
                authService.uploadDocProgressLabel ?? 'Mengunggah dokumen...',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppGap.lg,
            ],
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: Text(isLoading ? 'Mengirim...' : 'Kirim Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  final String title;
  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: AppShapes.md,
          border: Border.all(color: AppColors.borderColor),
          image: image != null
              ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.camera, size: 32.sp, color: AppColors.navy),
                  AppGap.sm,
                  Text(title, style: AppTextStyles.titleSmall),
                  Text('Tap untuk ambil foto', style: AppTextStyles.bodySmall),
                ],
              )
            : null,
      ),
    );
  }
}
