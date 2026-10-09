import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_message.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({required this.email, super.key});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await context.read<AuthService>().resetPasswordWithToken(
          email: widget.email,
          code: _codeController.text.trim(),
          newPassword: _passwordController.text,
        );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Password berhasil direset. Silakan login kembali.');
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return AuthScaffold(
      title: 'Reset Password',
      subtitle: 'Masukkan kode yang dikirim ke email Anda dan buat password baru.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthMessage(
                message: authService.status == AuthStatus.failure ? authService.message : null,
              ),
              AppGap.lg,
              AuthTextField(
                controller: _codeController,
                label: 'Kode Reset',
                prefixIcon: LucideIcons.key,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.otp,
              ),
              AppGap.md,
              AuthTextField(
                controller: _passwordController,
                label: 'Password Baru',
                prefixIcon: LucideIcons.lockKeyhole,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: AuthValidators.password,
              ),
              AppGap.v(AppSpacing.xxl),
              AuthSubmitButton(
                label: 'Simpan Password',
                isLoading: authService.isLoading,
                onPressed: _submit,
              ),
              AppGap.md,
              Center(
                child: TextButton(
                  onPressed: authService.isLoading
                      ? null
                      : () async {
                          final success = await authService.resendOtp(
                            widget.email,
                            type: 'PASSWORD_RESET',
                          );
                          if (success && mounted) {
                            SnackbarUtils.showSuccess(
                              context,
                              'Kode reset baru telah dikirim ke email Anda',
                            );
                          }
                        },
                  child: const Text('Kirim ulang kode reset'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
