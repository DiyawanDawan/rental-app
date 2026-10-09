class AuthValidators {
  const AuthValidators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = requiredField(value);
    if (requiredMessage != null) return requiredMessage;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredMessage = requiredField(value);
    if (requiredMessage != null) return requiredMessage;

    if (value!.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka';
    }
    return null;
  }

  static String? otp(String? value) {
    final requiredMessage = requiredField(value);
    if (requiredMessage != null) return requiredMessage;

    final clean = value!.trim();
    if (clean.length != 6 || int.tryParse(clean) == null) {
      return 'Kode OTP harus berupa 6 digit angka';
    }
    return null;
  }

  static String? nik(String? value) {
    final requiredMessage = requiredField(value);
    if (requiredMessage != null) return requiredMessage;

    final clean = value!.trim();
    if (clean.length != 16 || int.tryParse(clean) == null) {
      return 'NIK harus terdiri dari 16 digit angka';
    }
    return null;
  }
}
