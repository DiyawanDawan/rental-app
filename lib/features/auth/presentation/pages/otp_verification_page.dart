import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/di.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../customer/data/customer_repository.dart';
import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_message.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    required this.email,
    super.key,
  });

  final String email;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await _authService.verifyRegistration(
      email: widget.email,
      code: _codeController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      final referral = prefs.getString('pending_referral_code');
      if (referral != null && referral.isNotEmpty) {
        try {
          await getIt<CustomerRepository>().applyReferralCode(referral);
          await prefs.remove('pending_referral_code');
        } catch (_) {
          if (mounted) {
            SnackbarUtils.showError(context, 'Kode referral tidak valid atau sudah digunakan');
          }
        }
      }
      if (!mounted) return;
      context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, child) {
        return AuthScaffold(
          title: 'Verifikasi OTP',
          subtitle: 'Masukkan kode verifikasi yang dikirim untuk ${widget.email}.',
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthMessage(
                    message: _authService.status == AuthStatus.failure ? _authService.message : null,
                  ),
                  AppGap.lg,
                  AuthTextField(
                    controller: _codeController,
                    label: 'Kode OTP',
                    prefixIcon: LucideIcons.badgeCheck,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: AuthValidators.otp,
                  ),
                  AppGap.v(AppSpacing.xxl),
                  AuthSubmitButton(
                    label: 'Verifikasi',
                    isLoading: _authService.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            AppGap.md,
            Center(
              child: TextButton(
                onPressed: _authService.isLoading
                    ? null
                    : () async {
                        await _authService.resendOtp(widget.email, type: 'REGISTRATION');
                      },
                child: const Text('Kirim ulang kode OTP'),
              ),
            ),
            AppGap.lg,
            TextButton(
              onPressed: () => context.go(AppRoutePaths.login),
              child: const Text('Kembali ke login'),
            ),
          ],
        );
      },
    );
  }
}
