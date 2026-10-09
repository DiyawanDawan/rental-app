import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/theme_context.dart';
import '../../../../core/widgets/lists/icon_menu_tile.dart';
import '../../../../core/services/display_density_service.dart';
import '../../../../core/services/theme_mode_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _promoNotifications = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthService>().initBiometrics();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _promoNotifications = prefs.getBool('promo_notifications') ?? true);
  }

  Future<void> _setPromoNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promo_notifications', value);
    setState(() => _promoNotifications = value);
  }

  void _showPhoneUpdateDialog() {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    final isOtpSent = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Nomor Telepon'),
        content: ValueListenableBuilder<bool>(
          valueListenable: isOtpSent,
          builder: (context, sent, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!sent)
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Nomor Telepon Baru'),
                    keyboardType: TextInputType.phone,
                  )
                else
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(labelText: 'Kode OTP (Cek SMS)'),
                    keyboardType: TextInputType.number,
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final service = context.read<AuthService>();
              if (!isOtpSent.value) {
                if (phoneController.text.isEmpty) return;
                final success = await service.requestPhoneUpdate(phoneController.text.trim());
                if (success) isOtpSent.value = true;
              } else {
                if (otpController.text.isEmpty) return;
                final success = await service.verifyPhoneUpdate(
                  phoneNumber: phoneController.text.trim(),
                  code: otpController.text.trim(),
                );
                if (success && mounted) {
                  SnackbarUtils.showSuccess(context, 'Nomor telepon berhasil diperbarui');
                  Navigator.pop(context);
                }
              }
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isOtpSent,
              builder: (context, sent, child) => Text(sent ? 'Verifikasi' : 'Kirim OTP'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final density = context.watch<DisplayDensityService>();
    final themeModeService = context.watch<ThemeModeService>();

    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: AppPadding.list,
        children: [
          if (!isAuthenticated) ...[
            Container(
              padding: AppPadding.card,
              decoration: AppDecorations.floatingCardOf(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Masuk untuk fitur akun', style: context.textTitleSmall),
                  AppGap.sm,
                  Text(
                    'Bahasa dan tampilan bisa diatur tanpa login. Login untuk biometrik, password, dan notifikasi akun.',
                    style: context.textBodySmall,
                  ),
                  AppGap.md,
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutePaths.login),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ),
            AppGap.section,
          ],
          if (isAuthenticated) ...[
            Text('Keamanan', style: context.textTitleMedium),
            AppGap.sectionTitleToContent,
            Container(
              decoration: AppDecorations.elevatedSurfaceOf(context),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Login Biometrik', style: context.textTitleSmall),
                    subtitle: Text('Gunakan sidik jari atau wajah untuk masuk', style: context.textBodySmall),
                    value: authService.isBiometricEnabled,
                    activeColor: AppColors.orange,
                    onChanged: (value) async {
                      final success = await authService.setBiometricEnabled(value);
                      if (!success && mounted) {
                        SnackbarUtils.showError(context, 'Gagal mengaktifkan biometrik. Pastikan perangkat mendukung.');
                      }
                    },
                  ),
                  Divider(height: 1.h),
                ],
              ),
            ),
            IconMenuTile(
              title: 'Update Nomor Telepon',
              subtitle: authService.user?.phoneNumber ?? 'Belum diatur',
              icon: LucideIcons.phone,
              onTap: _showPhoneUpdateDialog,
            ),
            IconMenuTile(
              title: 'Ganti Password',
              subtitle: 'Perbarui kata sandi akun Anda',
              icon: LucideIcons.keyRound,
              onTap: () => context.push('/change-password'),
            ),
            AppGap.section,
          ],
          Text('Bahasa & Notifikasi', style: context.textTitleMedium),
          AppGap.sectionTitleToContent,
          Container(
            decoration: AppDecorations.elevatedSurfaceOf(context),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  title: Text('Bahasa Aplikasi', style: context.textTitleSmall),
                  subtitle: Text(
                    context.locale.languageCode == 'en' ? 'English' : 'Indonesia',
                    style: context.textBodySmall,
                  ),
                  trailing: DropdownButton<String>(
                    value: context.locale.languageCode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'id', child: Text('ID')),
                      DropdownMenuItem(value: 'en', child: Text('EN')),
                    ],
                    onChanged: (code) {
                      if (code == null) return;
                      context.setLocale(Locale(code));
                    },
                  ),
                ),
                Divider(height: 1.h),
                SwitchListTile(
                  title: Text('Notifikasi Promo', style: context.textTitleSmall),
                  subtitle: Text('Armada baru, harga turun, dan paket wisata', style: context.textBodySmall),
                  value: _promoNotifications,
                  activeColor: AppColors.orange,
                  onChanged: _setPromoNotifications,
                ),
              ],
            ),
          ),
          AppGap.section,
          Text('Tampilan', style: context.textTitleMedium),
          AppGap.sectionTitleToContent,
          Container(
            decoration: AppDecorations.elevatedSurfaceOf(context),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  title: Text('Mode tampilan', style: context.textTitleSmall),
                  subtitle: Text(
                    ThemeModeService.label(themeModeService.themeMode),
                    style: context.textBodySmall,
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeModeService.themeMode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Terang')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Gelap')),
                    ],
                    onChanged: (mode) {
                      if (mode == null) return;
                      themeModeService.setThemeMode(mode);
                    },
                  ),
                ),
                Divider(height: 1.h),
                SwitchListTile(
                  title: Text('Mode tampilan padat', style: context.textTitleSmall),
                  subtitle: Text(
                    'Perkecil teks & jarak antar elemen (${density.textScaleFactor.toStringAsFixed(2)}x)',
                    style: context.textBodySmall,
                  ),
                  value: density.isCompact,
                  activeColor: AppColors.orange,
                  onChanged: (value) => density.setCompact(value),
                ),
              ],
            ),
          ),
          AppGap.section,
          Text('Tentang Aplikasi', style: context.textTitleMedium),
          AppGap.sectionTitleToContent,
          Container(
            decoration: AppDecorations.elevatedSurfaceOf(context),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  title: Text('Versi Aplikasi', style: context.textTitleSmall),
                  trailing: Text('1.0.0 (V5)', style: context.textBodySmall),
                ),
                Divider(height: 1.h),
                ListTile(
                  title: Text('Syarat & Ketentuan', style: context.textTitleSmall),
                  trailing: Icon(LucideIcons.externalLink, size: 18.sp, color: context.cs.onSurfaceVariant),
                ),
                Divider(height: 1.h),
                ListTile(
                  title: Text('Kebijakan Privasi', style: context.textTitleSmall),
                  trailing: Icon(LucideIcons.externalLink, size: 18.sp, color: context.cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
