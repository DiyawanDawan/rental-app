import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/di.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_message.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricLogin());
  }

  Future<void> _tryBiometricLogin() async {
    if (!_authService.isBiometricEnabled) return;

    final success = await _authService.restoreSessionWithBiometrics();
    if (!mounted || !success) return;
    context.go(AppRoutePaths.home);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const _demoCustomerEmail = 'customer1@travelindo.test';
  static const _demoCustomerPassword = 'Password123!';
  static const _demoMitraEmail = 'mitra1@travelindo.test';
  static const _demoMitraPassword = 'Password123!';

  void _fillDemo({required String email, required String password}) {
    _emailController.text = email;
    _passwordController.text = password;
    _formKey.currentState?.validate();
    setState(() {});
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, child) {
        return AuthScaffold(
          title: 'Masuk ke akun',
          subtitle: 'Gunakan email dan password yang sudah terdaftar.',
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthMessage(
                    message: _authService.status == AuthStatus.failure ? _authService.message : null,
                  ),
                  if (_authService.status == AuthStatus.failure &&
                      (_authService.message?.toLowerCase().contains('verifikasi') == true ||
                          _authService.message?.toLowerCase().contains('otp') == true)) ...[
                    AppGap.sm,
                    OutlinedButton.icon(
                      onPressed: () {
                        final email = _emailController.text.trim();
                        context.push('${AppRoutePaths.otp}?email=$email');
                      },
                      icon: const Icon(LucideIcons.badgeCheck, size: 16),
                      label: const Text('Verifikasi OTP Sekarang'),
                    ),
                  ],
                  AppGap.lg,
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@email.com',
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.email,
                  ),
                  AppGap.md,
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    prefixIcon: LucideIcons.lockKeyhole,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: AuthValidators.password,
                  ),
                  AppGap.sm,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutePaths.forgotPassword),
                      child: Text('Lupa Password?'),
                    ),
                  ),
                  AppGap.md,
                  AuthSubmitButton(
                    label: 'Masuk',
                    isLoading: _authService.isLoading,
                    onPressed: _submit,
                  ),
                  if (!kReleaseMode) ...[
                    AppGap.md,
                    OutlinedButton.icon(
                      onPressed: _authService.isLoading
                          ? null
                          : () => _fillDemo(
                                email: _demoCustomerEmail,
                                password: _demoCustomerPassword,
                              ),
                      icon: Icon(LucideIcons.sparkles, size: 20.sp),
                      label: Text('Demo Pelanggan'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    AppGap.sm,
                    OutlinedButton.icon(
                      onPressed: _authService.isLoading
                          ? null
                          : () => _fillDemo(
                                email: _demoMitraEmail,
                                password: _demoMitraPassword,
                              ),
                      icon: Icon(LucideIcons.briefcase, size: 20.sp),
                      label: Text('Demo Mitra'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                  AppGap.section,
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                        child: Text('atau', style: AppTextStyles.labelSmall),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  AppGap.section,
                  OutlinedButton.icon(
                    onPressed: () async {
                      final success = await _authService.signInWithGoogle();
                      if (success && mounted) {
                        context.go(AppRoutePaths.home);
                      }
                    },
                    icon: Icon(LucideIcons.globe, size: 20.sp),
                    label: Text('Masuk dengan Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  AppGap.md,
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FacebookAuth.instance.login();
                      if (result.status == LoginStatus.success && result.accessToken != null) {
                        final success = await _authService.loginWithFacebook(
                          result.accessToken!.tokenString,
                        );
                        if (success && mounted) {
                          context.go(AppRoutePaths.home);
                        }
                      } else if (result.status == LoginStatus.failed && mounted) {
                        SnackbarUtils.showError(context, 'Login Facebook gagal');
                      }
                    },
                    icon: Icon(LucideIcons.share2, size: 20.sp),
                    label: Text('Masuk dengan Facebook'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
            AppGap.lg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Belum punya akun?',
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutePaths.register),
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
