import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/auth_service.dart';
import '../widgets/auth_validators.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_newController.text != _confirmController.text) {
      SnackbarUtils.showError(context, 'Konfirmasi password tidak cocok');
      return;
    }

    final success = await context.read<AuthService>().resetPassword(
          newPassword: _newController.text,
          currentPassword: _currentController.text.trim().isEmpty ? null : _currentController.text,
        );

    if (success && mounted) {
      SnackbarUtils.showSuccess(context, 'Password berhasil diubah');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('Ganti Password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppPadding.screen,
          children: [
            TextFormField(
              controller: _currentController,
              decoration: InputDecoration(labelText: 'Password Saat Ini'),
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            AppGap.lg,
            TextFormField(
              controller: _newController,
              decoration: InputDecoration(labelText: 'Password Baru'),
              obscureText: true,
              validator: AuthValidators.password,
            ),
            AppGap.lg,
            TextFormField(
              controller: _confirmController,
              decoration: InputDecoration(labelText: 'Konfirmasi Password Baru'),
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            AppGap.ctaSpacer,
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: Text(isLoading ? 'Memproses...' : 'Ubah Password'),
            ),
          ],
        ),
      ),
    );
  }
}
