import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/di.dart';
import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_message.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

enum RegisterRole { customer, mitra }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  RegisterRole _role = RegisterRole.customer;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final success = _role == RegisterRole.customer
        ? await _authService.registerCustomer(
            email: email,
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          )
        : await _authService.registerMitra(
            email: email,
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );

    if (!mounted) return;
    if (success) {
      final referral = _referralController.text.trim();
      if (referral.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_referral_code', referral);
      }
      if (!mounted) return;
      context.go('${AppRoutePaths.otp}?email=$email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authService,
      builder: (context, child) {
        return AuthScaffold(
          title: 'Buat akun baru',
          subtitle: 'Pilih tipe akun lalu lengkapi data registrasi.',
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthMessage(
                    message: _authService.status == AuthStatus.failure ? _authService.message : null,
                  ),
                  AppGap.lg,
                  Text('Tipe akun', style: AppTextStyles.titleSmall),
                  AppGap.sm,
                  SegmentedButton<RegisterRole>(
                    segments: const [
                      ButtonSegment(
                        value: RegisterRole.customer,
                        label: Text('Customer'),
                        icon: Icon(LucideIcons.user),
                      ),
                      ButtonSegment(
                        value: RegisterRole.mitra,
                        label: Text('Mitra'),
                        icon: Icon(LucideIcons.store),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (value) {
                      setState(() => _role = value.first);
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return AppColors.orange;
                          }
                          return AppColors.textSecondary;
                        },
                      ),
                      iconColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return AppColors.orange;
                          }
                          return AppColors.textSecondary;
                        },
                      ),
                    ),
                  ),
                  AppGap.lg,
                  AuthTextField(
                    controller: _nameController,
                    label: 'Nama lengkap',
                    prefixIcon: LucideIcons.userRound,
                    textInputAction: TextInputAction.next,
                    validator: AuthValidators.requiredField,
                  ),
                  AppGap.md,
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
                    controller: _phoneController,
                    label: _role == RegisterRole.mitra ? 'Nomor HP' : 'Nomor HP opsional',
                    prefixIcon: LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: _role == RegisterRole.mitra ? AuthValidators.requiredField : null,
                  ),
                  AppGap.md,
                  if (_role == RegisterRole.customer)
                    AuthTextField(
                      controller: _referralController,
                      label: 'Kode referral (opsional)',
                      prefixIcon: LucideIcons.gift,
                      textInputAction: TextInputAction.next,
                    ),
                  if (_role == RegisterRole.customer) AppGap.md,
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    prefixIcon: LucideIcons.lockKeyhole,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: AuthValidators.password,
                  ),
                  AppGap.v(AppSpacing.xxl),
                  AuthSubmitButton(
                    label: 'Daftar',
                    isLoading: _authService.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            AppGap.lg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah punya akun?', style: AppTextStyles.bodySmall),
                TextButton(
                  onPressed: () => context.go(AppRoutePaths.login),
                  child: Text('Masuk'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
