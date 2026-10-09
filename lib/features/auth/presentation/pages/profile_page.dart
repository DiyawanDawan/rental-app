import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/di.dart';
import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/badges/verified_badge.dart';
import '../../../../core/widgets/lists/icon_menu_tile.dart';
import '../../../customer/application/customer_service.dart';
import '../../application/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _avatarPath;
  int _loyaltyBalance = 0;
  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadLoyalty();
  }

  Future<void> _loadLoyalty() async {
    final service = getIt<CustomerService>();
    final balance = await service.getLoyaltyBalance();
    final referral = await service.getMyReferralCode();
    if (!mounted) return;
    setState(() {
      _loyaltyBalance = balance;
      _referralCode = referral?['code']?.toString();
    });
  }

  void _loadInitialData() {
    final user = context.read<AuthService>().user;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final data = {
      'fullName': _nameController.text.trim(),
    };

    final success = await context.read<AuthService>().updateProfile(
      data,
      avatarPath: _avatarPath,
    );

    if (!mounted) return;
    if (success) {
      setState(() => _avatarPath = null);
      SnackbarUtils.showSuccess(context, 'Profil berhasil diperbarui');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Ya, Logout', style: AppTextStyles.labelLarge.copyWith(color: AppColors.critical)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      await context.read<AuthService>().logout();
      if (!mounted) return;
      context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Silakan login terlebih dahulu')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(LucideIcons.settings),
            tooltip: 'Pengaturan',
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(LucideIcons.logOut, color: AppColors.critical),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.screen,
          children: [
            Container(
              padding: AppPadding.card,
              decoration: AppDecorations.elevatedSurface(),
              child: Column(
                children: [
                  Center(
                    child: VerifiedAvatar(
                      isVerified: user.isVerified == true,
                      onUnverifiedTap: () => context.push('/kyc'),
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (picked != null) {
                            setState(() => _avatarPath = picked.path);
                          }
                        },
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.lightGray,
                          backgroundImage: _avatarPath != null
                              ? FileImage(File(_avatarPath!))
                              : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : null),
                          child: _avatarPath == null &&
                                  (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                              ? Icon(LucideIcons.user, size: 50.sp, color: AppColors.navy)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  AppGap.md,
                  if (authService.isKycVerified)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.12),
                        borderRadius: AppShapes.md,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.badgeCheck, size: 16.sp, color: AppColors.teal),
                          AppGap.xs,
                          Text(
                            'Akun Terverifikasi (KYC)',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.teal),
                          ),
                        ],
                      ),
                    )
                  else if (authService.isKycPending)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.12),
                        borderRadius: AppShapes.md,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clock, size: 16.sp, color: AppColors.orange),
                          AppGap.xs,
                          Text(
                            'KYC Menunggu Peninjauan Admin',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.orange),
                          ),
                        ],
                      ),
                    )
                  else if (authService.isKycRejected)
                    InkWell(
                      onTap: () => context.push('/kyc'),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.critical.withValues(alpha: 0.12),
                          borderRadius: AppShapes.md,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.circleAlert, size: 16.sp, color: AppColors.critical),
                            AppGap.xs,
                            Text(
                              'KYC Ditolak: Ajukan Ulang',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.critical),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => context.push('/kyc'),
                      icon: Icon(LucideIcons.shieldAlert, size: 16.sp, color: AppColors.orange),
                      label: Text(
                        'Belum Verifikasi Identitas (KYC)',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.orange),
                      ),
                    ),
                  AppGap.section,
                  _buildInfoTile('Email', user.email, LucideIcons.mail, enabled: false),
                  AppGap.lg,
                  _buildTextField(_nameController, 'Nama Lengkap', LucideIcons.user),
                  AppGap.lg,
                  _buildInfoTile(
                    'Nomor HP',
                    user.phoneNumber != null && user.phoneNumber!.isNotEmpty
                        ? user.phoneNumber!
                        : 'Belum diatur (ubah via Pengaturan)',
                    LucideIcons.phone,
                    enabled: false,
                  ),
                  AppGap.ctaSpacer,
                  ElevatedButton(
                    onPressed: authService.isLoading ? null : _update,
                    child: Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
            AppGap.section,
            Text('Menu Akun', style: AppTextStyles.titleMedium),
            AppGap.sectionTitleToContent,
            IconMenuTile(
              title: 'Dompet Saya',
              subtitle: 'Saldo, top up & penarikan',
              icon: LucideIcons.wallet,
              onTap: () => context.push('/wallet'),
            ),
            IconMenuTile(
              title: 'Favorit Saya',
              subtitle: 'Kendaraan tersimpan',
              icon: LucideIcons.heart,
              onTap: () => context.push(AppRoutePaths.favorites),
            ),
            IconMenuTile(
              title: 'Mitra Diikuti',
              subtitle: 'Toko mitra favorit',
              icon: LucideIcons.store,
              onTap: () => context.push(AppRoutePaths.following),
            ),
            IconMenuTile(
              title: 'Poin Loyalitas',
              subtitle: '$_loyaltyBalance poin',
              icon: LucideIcons.gift,
              onTap: () => context.push(AppRoutePaths.loyaltyHistory),
            ),
            IconMenuTile(
              title: 'Voucher & Promo',
              subtitle: 'Diskon siap pakai',
              icon: LucideIcons.ticket,
              onTap: () => context.push(AppRoutePaths.vouchers),
            ),
            if (_referralCode != null) ...[
              Container(
                padding: AppPadding.card,
                decoration: AppDecorations.floatingCard(),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        borderRadius: AppShapes.sm,
                      ),
                      child: Icon(LucideIcons.users, color: AppColors.teal),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kode Referral', style: AppTextStyles.titleSmall),
                          Text(_referralCode!, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.share2),
                      onPressed: () => Share.share(
                        'Daftar Travelindo dengan kode referral saya: $_referralCode\nhttps://travelindo.com/register',
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.md,
            ],
            IconMenuTile(
              title: 'Pesan',
              subtitle: 'Chat dengan mitra',
              icon: LucideIcons.messageSquare,
              onTap: () => context.push('/chat'),
            ),
            IconMenuTile(
              title: 'Alamat Saya',
              subtitle: 'Kelola alamat pengiriman',
              icon: LucideIcons.mapPin,
              onTap: () => context.push('/addresses'),
            ),
            IconMenuTile(
              title: 'Pusat Bantuan',
              subtitle: 'FAQ & kontak support',
              icon: LucideIcons.headset,
              onTap: () => context.push('/help-center'),
            ),
            IconMenuTile(
              title: 'Ganti Password',
              subtitle: 'Perbarui kata sandi akun',
              icon: LucideIcons.lock,
              onTap: () => context.push('/change-password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {bool enabled = true}) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20.sp),
        border: OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.lightGray,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20.sp),
        border: OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.isEmpty) ? '$label wajib diisi' : null,
    );
  }
}
