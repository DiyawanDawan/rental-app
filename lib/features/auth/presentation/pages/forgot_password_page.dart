import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../config/spacing.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_message.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final success = await context.read<AuthService>().forgotPassword(email);

    if (!mounted) return;
    if (success) {
      context.push('${AppRoutePaths.resetPassword}?email=$email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return AuthScaffold(
      title: 'Lupa Password',
      subtitle: 'Masukkan email Anda untuk menerima kode reset password.',
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
                controller: _emailController,
                label: 'Email',
                hint: 'nama@email.com',
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: AuthValidators.email,
              ),
              AppGap.v(AppSpacing.xxl),
              AuthSubmitButton(
                label: 'Kirim Kode Reset',
                isLoading: authService.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
