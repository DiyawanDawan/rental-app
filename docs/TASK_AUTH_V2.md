# Task Execution Plan - Integrasi Modul Autentikasi & Profil Pengguna v2

Dokumen ini adalah checklist dan panduan teknis langkah demi langkah untuk mengeksekusi integrasi dan penyelarasan modul Autentikasi antara Backend ([`Backend/src/routes/auth.ts`](file:///d:/Retal-Apps/Backend/src/routes/auth.ts)) dan Frontend Flutter ([`travelindo/lib/features/auth`](file:///d:/Retal-Apps/travelindo/lib/features/auth)).

Dokumen acuan perencanaan arsitektur: [`travelindo/docs/PLANNING_AUTH_V2.md`](file:///d:/Retal-Apps/travelindo/docs/PLANNING_AUTH_V2.md)

---

## Ringkasan Roadmap & Progress Tracker

- [x] **Fase 1: Penyelarasan & Perbaikan Backend (`Backend/src/controllers` & `validations`)**
- [x] **Fase 2: Standarisasi Data Layer & DTO Frontend (`lib/features/auth/data`)**
- [x] **Fase 3: State Management & Manajemen Sesi Sempurna (`lib/features/auth/application/auth_service.dart`)**
- [x] **Fase 4: Penyelarasan Validasi Form di Client (`lib/features/auth/presentation/widgets/auth_validators.dart`)**
- [x] **Fase 5: Pembaruan Halaman UI Autentikasi, KYC & Profil (`lib/features/auth/presentation/pages`)**
- [x] **Fase 6: Pengujian, Validasi Statis & Definition of Done (DoD)**

---

## Fase 1: Penyelarasan & Perbaikan Backend

File target:
- [`Backend/src/controllers/auth.controller.ts`](file:///d:/Retal-Apps/Backend/src/controllers/auth.controller.ts)
- [`Backend/src/validations/auth.validation.ts`](file:///d:/Retal-Apps/Backend/src/validations/auth.validation.ts)
- [`Backend/src/services/auth.service.ts`](file:///d:/Retal-Apps/Backend/src/services/auth.service.ts)

### Tasks:
- [x] **1.1. Perbaiki Kontrak Ubah Password (`POST /reset-password`)**
  - Di [`Backend/src/controllers/auth.controller.ts`](file:///d:/Retal-Apps/Backend/src/controllers/auth.controller.ts#L106-L110):
    - Baca field `newPassword` atau `password` secara konsisten:
      ```typescript
      const { password, newPassword, currentPassword } = req.body as {
        password?: string;
        newPassword?: string;
        currentPassword?: string;
      };
      const targetPassword = (newPassword || password)!;
      await authService.resetPassword(req.user!.id, targetPassword, currentPassword);
      ```
  - Di [`Backend/src/validations/auth.validation.ts`](file:///d:/Retal-Apps/Backend/src/validations/auth.validation.ts#L72-L76):
    - Terima `newPassword: passwordSchema.optional()`, `password: passwordSchema.optional()`, dan `currentPassword: z.string().optional()`.
  - Di [`Backend/src/services/auth.service.ts`](file:///d:/Retal-Apps/Backend/src/services/auth.service.ts#L320):
    - Jika `currentPassword` disertakan, verifikasi hash password pengguna lama terlebih dahulu sebelum menimpa dengan password baru.

- [x] **1.2. Verifikasi Resend OTP & Verification Rate Limiter**
  - Pastikan `resendOtpSchema` menerima `type: z.enum(['REGISTRATION', 'PASSWORD_RESET'])`.
  - Pastikan pengiriman OTP dibatasi maksimal 5 kali percobaan gagal sebelum *lockout* 15 menit.

---

## Fase 2: Standarisasi Data Layer & DTO Frontend

File target:
- [`travelindo/lib/features/auth/data/models/user_model.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/data/models/user_model.dart)
- [`travelindo/lib/features/auth/data/auth_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/data/auth_remote_datasource.dart)
- [`travelindo/lib/features/auth/data/auth_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/data/auth_repository.dart)

### Tasks:
- [x] **2.1. Perbarui `UserModel` dengan Field Status KYC Lengkap**
  - Tambahkan field ke dalam `UserModel`:
    ```dart
    String? verificationStatus, // 'UNVERIFIED' | 'PENDING' | 'VERIFIED' | 'REJECTED'
    String? rejectionReason,
    ```
  - Sinkronkan `user_model.g.dart` dan `user_model.freezed.dart`.

- [x] **2.2. Refactor `submitVerification` di `AuthRemoteDataSource`**
  - Ganti pemanggilan loop 3x dengan **satu request multipart** yang menggabungkan:
    - Files: `ktp`, `sim`, `selfie`
    - Fields: `ktpNumber` (Wajib, 16 digit), `simNumber` (Opsional)
  - Gunakan `MultipartUploadHelper.buildNamedDocForm`:
    ```dart
    Future<ApiResponse<void>> submitVerification({
      required String ktpPath,
      required String simPath,
      required String selfiePath,
      required String ktpNumber,
      String? simNumber,
      UploadProgressCallback? onDocProgress,
    }) async {
      final formData = await MultipartUploadHelper.buildNamedDocForm(
        {
          'ktp': ktpPath,
          'sim': simPath,
          'selfie': selfiePath,
        },
        extraFields: {
          'ktpNumber': ktpNumber,
          if (simNumber != null && simNumber.isNotEmpty) 'simNumber': simNumber,
        },
      );

      await UploadExecutor(_apiClient).uploadMultipart(
        endpoint: ApiEndpoints.authVerification,
        formData: formData,
        onProgress: onDocProgress,
      );

      return ApiResponse<void>.fromJson(<String, dynamic>{}, (_) {});
    }
    ```

- [x] **2.3. Refactor `verifyPhoneUpdate` di `AuthRemoteDataSource`**
  - Tambahkan parameter wajib `phoneNumber`:
    ```dart
    Future<ApiResponse<void>> verifyPhoneUpdate({
      required String phoneNumber,
      required String code,
    }) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.authVerifyPhoneUpdate,
        data: {
          'phoneNumber': phoneNumber,
          'code': code,
        },
      );
      return ApiResponse<void>.fromJson(response.data ?? <String, dynamic>{}, (_) {});
    }
    ```

- [x] **2.4. Refactor `resendOtp` di `AuthRemoteDataSource`**
  - Tambahkan parameter `type` (`'REGISTRATION' | 'PASSWORD_RESET'`):
    ```dart
    Future<ApiResponse<void>> resendOtp({
      required String email,
      String type = 'REGISTRATION',
    }) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.authResendOtp,
        data: {
          'email': email,
          'type': type,
        },
      );
      return ApiResponse<void>.fromJson(response.data ?? <String, dynamic>{}, (_) {});
    }
    ```

- [x] **2.5. Refactor `resetPassword` di `AuthRemoteDataSource`**
  - Kirim field `newPassword` dan `currentPassword`:
    ```dart
    Future<ApiResponse<void>> resetPassword({
      required String newPassword,
      String? currentPassword,
    }) async {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.authResetPassword,
        data: {
          'newPassword': newPassword,
          if (currentPassword != null && currentPassword.isNotEmpty)
            'currentPassword': currentPassword,
        },
      );
      return ApiResponse<void>.fromJson(response.data ?? <String, dynamic>{}, (_) {});
    }
    ```

- [x] **2.6. Sinkronisasi Signature pada `AuthRepository`**
  - Perbarui method `submitVerification`, `verifyPhoneUpdate`, `resendOtp`, dan `resetPassword` di `AuthRepository` agar meneruskan DTO baru ke datasource.

---

## Fase 3: State Management & Manajemen Sesi Sempurna

File target:
- [`travelindo/lib/features/auth/application/auth_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/application/auth_service.dart)

### Tasks:
- [x] **3.1. Amankan State `_user` saat `refreshSession()`**
  - Cegah hilangnya data profil pengguna saat refresh token:
    ```dart
    Future<bool> refreshSession() async {
      _setLoading();
      try {
        final response = await _authRepository.refreshToken();
        if (response.data?.user != null) {
          _user = response.data!.user;
        } else if (_user == null) {
          final profileRes = await _authRepository.getMe();
          _user = profileRes.data;
        }
        _message = response.message;
        _status = AuthStatus.authenticated;
        notifyListeners();
        await _postAuthSetup();
        return true;
      } catch (error) {
        _setFailure(error);
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    }
    ```

- [x] **3.2. Tambahkan Helper Getters Status KYC di `AuthService`**
  - Tambahkan getter untuk memudahkan widget UI mengetahui status verifikasi:
    ```dart
    bool get isKycVerified => _user?.isVerified == true || _user?.verificationStatus == 'VERIFIED';
    bool get isKycPending => _user?.verificationStatus == 'PENDING';
    bool get isKycRejected => _user?.verificationStatus == 'REJECTED';
    String? get kycRejectionReason => _user?.rejectionReason;
    ```

- [x] **3.3. Perbarui Method Action di `AuthService`**
  - Update `submitVerification(...)` agar menerima `ktpNumber` dan `simNumber`.
  - Update `verifyPhoneUpdate({required String phoneNumber, required String code})`.
  - Update `resendOtp(String email, {String type = 'REGISTRATION'})`.
  - Update `resetPassword({required String newPassword, String? currentPassword})`.

---

## Fase 4: Penyelarasan Validasi Form di Client

File target:
- [`travelindo/lib/features/auth/presentation/widgets/auth_validators.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/widgets/auth_validators.dart)

### Tasks:
- [x] **4.1. Sinkronisasi Validasi Password dengan Backend Zod**
  - Wajibkan minimal 8 karakter DAN mengandung setidaknya satu angka:
    ```dart
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
    ```

- [x] **4.2. Sinkronisasi Validasi OTP 6 Digit**
  - Pastikan panjang OTP tepat 6 digit angka:
    ```dart
    static String? otp(String? value) {
      final requiredMessage = requiredField(value);
      if (requiredMessage != null) return requiredMessage;

      final clean = value!.trim();
      if (clean.length != 6 || int.tryParse(clean) == null) {
        return 'Kode OTP harus berupa 6 digit angka';
      }
      return null;
    }
    ```

- [x] **4.3. Tambahkan Validator NIK (KTP)**
  - Validasi NIK tepat 16 digit angka:
    ```dart
    static String? nik(String? value) {
      final requiredMessage = requiredField(value);
      if (requiredMessage != null) return requiredMessage;

      final clean = value!.trim();
      if (clean.length != 16 || int.tryParse(clean) == null) {
        return 'NIK harus terdiri dari 16 digit angka';
      }
      return null;
    }
    ```

---

## Fase 5: Pembaruan Halaman UI Autentikasi, KYC & Profil

File target:
- [`travelindo/lib/features/auth/presentation/pages/login_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/login_page.dart)
- [`travelindo/lib/features/auth/presentation/pages/otp_verification_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/otp_verification_page.dart)
- [`travelindo/lib/features/auth/presentation/pages/reset_password_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/reset_password_page.dart)
- [`travelindo/lib/features/auth/presentation/pages/change_password_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/change_password_page.dart)
- [`travelindo/lib/features/auth/presentation/pages/kyc_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/kyc_page.dart)
- [`travelindo/lib/features/auth/presentation/pages/profile_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/profile_page.dart)
- [`travelindo/lib/features/auth/presentation/pages/settings_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/settings_page.dart)

### Tasks:
- [x] **5.1. Penanganan Akun PENDING pada `LoginPage`**
  - Jika `authService.message` mengindikasikan akun belum diverifikasi (status 403), tampilkan tombol cepat:
    *"Akun belum aktif? Verifikasi OTP Sekarang"* yang langsung mengarahkan ke `AppRoutePaths.otp?email=<email_terinput>`.

- [x] **5.2. Penyelarasan OTP Resend pada `OtpVerificationPage`**
  - Pastikan pemanggilan kirim ulang OTP mengirimkan `type: 'REGISTRATION'`.

- [x] **5.3. Penyelarasan `ResetPasswordPage`**
  - Gunakan `AuthValidators.otp` (6 digit) untuk field kode reset.
  - Sediakan tombol *"Kirim Ulang Kode"* yang memanggil `resendOtp(widget.email, type: 'PASSWORD_RESET')`.

- [x] **5.4. Perbaikan `ChangePasswordPage`**
  - Ganti validator minimal 6 karakter dengan `AuthValidators.password` (min 8 karakter + 1 digit).
  - Teruskan `currentPassword` dan `newPassword` ke `authService.resetPassword(...)`.

- [x] **5.5. Redesain Form `KycPage` (Lengkap dengan Input NIK)**
  - Tambahkan `TextFormField` untuk **Nomor Induk Kependudukan (NIK)** dengan `validator: AuthValidators.nik` dan `maxLength: 16`.
  - Tambahkan `TextFormField` opsional untuk **Nomor SIM**.
  - Panggil `submitVerification` dengan seluruh field dokumen dan teks dalam 1 request terpadu.
  - Tampilkan banner jika pengajuan KYC sebelumnya berstatus `REJECTED` beserta alasannya.

- [x] **5.6. Pembaruan Status Badge KYC di `ProfilePage`**
  - Ganti tombol sederhana dengan status banner dinamis:
    - **VERIFIED**: Badge hijau centang *"Terverifikasi"*.
    - **PENDING**: Badge kuning jam pasir *"Menunggu Peninjauan Admin"* (tombol KYC dinonaktifkan sementara).
    - **REJECTED**: Badge merah *"Verifikasi Ditolak: <alasan>"* dengan tombol *"Ajukan Ulang"*.
    - **UNVERIFIED**: Badge abu-abu/oranye *"Belum Verifikasi Identitas (KYC)"*.
  - Buat field `phoneNumber` pada halaman edit profil menjadi *read-only* dengan catatan *"Nomor telepon dapat diubah melalui menu Pengaturan"*.

- [x] **5.7. Perbaikan Dialog Nomor Telepon pada `SettingsPage`**
  - Simpan nilai nomor telepon baru yang diinput pada langkah 1, lalu kirimkan bersama kode OTP ke `verifyPhoneUpdate(phoneNumber: phoneController.text.trim(), code: otpController.text.trim())`.

---

## Fase 6: Pengujian, Validasi Statis & Definition of Done (DoD)

### Tasks:
- [x] **6.1. Validasi Sintaks & Static Analyzer**
  - Seluruh file modul auth (`UserModel`, `AuthRemoteDataSource`, `AuthRepository`, `AuthService`, `AuthValidators`, `LoginPage`, `OtpVerificationPage`, `ResetPasswordPage`, `ChangePasswordPage`, `KycPage`, `ProfilePage`, `SettingsPage`) bebas dari error sintaks dan type mismatch.
- [x] **6.2. Verifikasi Kompilasi Backend**
  - Penyelarasan skema Zod `resetPasswordSchema` dan controller `resetPassword` di [`Backend/src/controllers/auth.controller.ts`](file:///d:/Retal-Apps/Backend/src/controllers/auth.controller.ts) serta service [`Backend/src/services/auth.service.ts`](file:///d:/Retal-Apps/Backend/src/services/auth.service.ts) telah selesai tanpa error.
- [x] **6.3. Skenario Uji End-to-End Checklist**
  - [x] Registrasi customer baru -> OTP 6 digit -> aktivasi akun.
  - [x] Penanganan akun `PENDING` saat login -> tombol cepat verifikasi OTP.
  - [x] Forgot password -> OTP 6 digit `PASSWORD_RESET` -> update password baru (min 8 karakter + 1 digit).
  - [x] Ganti password user login -> verifikasi `currentPassword` & `newPassword`.
  - [x] Update nomor telepon 2-langkah via OTP `phoneNumber` + `code`.
  - [x] Upload berkas KYC tunggal (KTP, SIM, Selfie, NIK 16-digit, Nomor SIM) -> status `PENDING` dengan badge dinamis.
  - [x] Preservasi data `_user` saat refresh token berlangsung.
