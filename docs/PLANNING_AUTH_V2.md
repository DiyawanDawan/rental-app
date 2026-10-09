# Perencanaan Arsitektur & Integrasi API - Modul Autentikasi & Profil Pengguna v1

Dokumen ini mendefinisikan spesifikasi kontrak API (Backend DTO), audit kesenjangan (*gap analysis*), desain struktur data frontend, arsitektur keamanan sesi, dan panduan integrasi modul Autentikasi, Verifikasi (OTP & KYC), dan Manajemen Profil antara **Backend (Express + Prisma + JWT)** dan **Frontend (Flutter `travelindo`)**.

Acuan file backend: [`Backend/src/routes/auth.ts`](file:///d:/Retal-Apps/Backend/src/routes/auth.ts)

---

## 1. Ringkasan Eksekutif & Konteks Integrasi

Modul Autentikasi merupakan gerbang utama seluruh transaksi di aplikasi Travelindo (Customer & Mitra). Backend telah mengimplementasikan 18 endpoint komprehensif pada [`Backend/src/routes/auth.ts`](file:///d:/Retal-Apps/Backend/src/routes/auth.ts) yang mencakup:
1. **Pendaftaran Akun Terpisah**: Registrasi Customer & Mitra dengan validasi Zod ketat dan pengiriman kode OTP 6-digit.
2. **Aktivasi Akun (OTP Verification)**: Transisi status pengguna dari `PENDING` menjadi `ACTIVE` dengan penerbitan JWT awal dan welcoming email.
3. **Autentikasi Kredensial & Sosial**: Login berbasis Email/Password dengan rate limiter (`authLimiter`), serta Social Login via Google ID Token & Facebook Access Token.
4. **Keamanan Sesi Berbasis `tokenVersion`**: Mekanisme pembatalan sesi (*server-side token revocation*) seketika saat pengguna logout atau mereset password.
5. **Pemulihan Password 2-Langkah**: `forgot-password` (kirim OTP) -> `verify-reset-code` (penerbitan JWT `resetToken` berdurasi 10 menit) -> `reset-password/:token` (eksekusi kata sandi baru).
6. **Verifikasi Identitas Resmi (KYC)**: Endpoint multipart `POST /me/verify` yang menerima berkas foto KTP, SIM, Selfie secara terenkripsi di Cloudflare R2 bersama NIK 16 digit dan nomor SIM.
7. **Pembaruan Nomor Telepon Terverifikasi**: Alur 2-faktor `request-update` -> `verify-update` untuk memastikan nomor baru aktif dan belum digunakan akun lain.
8. **Pengiriman Ulang OTP Multi-Tipe**: Endpoint `POST /resend-otp` dengan payload tipe eksplisit (`REGISTRATION` | `PASSWORD_RESET`).

---

## 2. Audit Kesenjangan (Gap Analysis) Backend vs Frontend Saat Ini

Dari hasil inspeksi mendalam antara kode backend ([`auth.ts`](file:///d:/Retal-Apps/Backend/src/routes/auth.ts), [`auth.controller.ts`](file:///d:/Retal-Apps/Backend/src/controllers/auth.controller.ts), [`auth.validation.ts`](file:///d:/Retal-Apps/Backend/src/validations/auth.validation.ts)) dan frontend ([`auth_remote_datasource.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/data/auth_remote_datasource.dart), [`auth_repository.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/data/auth_repository.dart), [`auth_service.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/application/auth_service.dart), [`kyc_page.dart`](file:///d:/Retal-Apps/travelindo/lib/features/auth/presentation/pages/kyc_page.dart), dll.), ditemukan beberapa ketidaksesuaian kritis:

| No | Modul / Alur | Kondisi Backend (`Backend/src/routes/auth.ts`) | Kondisi Frontend Saat Ini (`travelindo`) | Dampak / Risiko |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Verifikasi Dokumen KYC (`/me/verify`)** | Menerima 1 request multipart dengan file `ktp`, `sim`, `selfie`, serta body wajib `ktpNumber` (NIK min 16 digit) & opsional `simNumber`. | `auth_remote_datasource.dart` melakukan *loop* 3x memanggil endpoint terpisah per dokumen dan sama sekali **tidak mengirimkan `ktpNumber`**. UI `kyc_page.dart` juga tidak memiliki input NIK. | Request selalu ditolak dengan `400 Bad Request` (`ktpNumber: Required`). User tidak bisa menyelesaikan KYC. |
| **2** | **Verifikasi Update Telepon (`/me/phone/verify-update`)** | Skema Zod mewajibkan `{ phoneNumber: string, code: string }`. | `verifyPhoneUpdate(String code)` di datasource & service hanya mengirim `{ code }`. Nilai `phoneNumber` hilang. | Request selalu ditolak dengan `400 Bad Request` (`phoneNumber: Required`). |
| **3** | **Kirim Ulang OTP (`/resend-otp`)** | Skema Zod mewajibkan `{ email: string, type: 'REGISTRATION' \| 'PASSWORD_RESET' }`. | `resendOtp(String email)` hanya mengirim `{ email }`. Parameter `type` tidak disertakan. | Request selalu ditolak backend dengan pesan `Tipe OTP harus REGISTRATION atau PASSWORD_RESET`. |
| **4** | **Refresh Token & State User** | Endpoint `POST /refresh-token` hanya mengembalikan `{ token: newToken }` (tanpa data profil user). | `AuthService.refreshSession()` mengeksekusi `_user = response.data?.user;`. Karena `user` bernilai null pada response, properti `_user` menjadi `null`. | Data profil pengguna mendadak hilang di UI (nama kosong, avatar kosong) meskipun sesi token aktif. |
| **5** | **Field Status KYC pada UserModel** | Backend mengembalikan field `verificationStatus: 'UNVERIFIED' \| 'PENDING' \| 'VERIFIED' \| 'REJECTED'`. | `user_model.dart` hanya memiliki `isVerified: bool?`. | Frontend tidak bisa membedakan status apakah KYC sedang ditinjau admin (`PENDING`), ditolak (`REJECTED`), atau belum mengajukan. |
| **6** | **Ganti Password User Login (`/reset-password`)** | Backend validation mewajibkan field `newPassword`. Controller membaca `req.body.password`. Terdapat *mismatch* di backend (`password` vs `newPassword`). | Frontend mengirim `currentPassword` & `newPassword`. Validator frontend di `change_password_page.dart` hanya memvalidasi min 6 karakter, sedangkan backend mewajibkan min 8 karakter + 1 angka. | Request berpotensi crash di backend (`bcrypt.hash(undefined)`) atau gagal validasi password format. |
| **7** | **Validasi Kredensial di Client (`auth_validators.dart`)** | Backend Zod: Password min 8 char + 1 angka (`/\d/`); OTP tepat 6 digit (`length(6)`). | Frontend validator: Password hanya cek `length < 8` (tanpa angka); OTP cek `length < 4` (lolos 4 atau 5 digit). | Input lolos di form Flutter namun langsung ditolak backend saat submit. |
| **8** | **Edit Profil Telepon via `PATCH /me`** | `updateProfileSchema` hanya mengizinkan `fullName` dan `avatarUrl`. Perubahan telepon wajib via alur OTP `/me/phone/*`. | `ProfilePage` menyertakan `phoneNumber` pada payload `PATCH /me`. | Payload ditolak atau perubahan nomor telepon tidak tersimpan karena tidak melalui verifikasi OTP. |
| **9** | **Penanganan Login Status `PENDING`** | Backend melempar error `403 Forbidden` jika user login dengan akun berstatus `PENDING` (belum OTP). | Frontend `LoginPage` hanya menampilkan pesan error merah biasa tanpa navigasi otomatis ke halaman OTP. | Pengguna kebingungan dan terhambat untuk memverifikasi akun mereka yang belum aktif. |

---

## 3. Spesifikasi Kontrak API Backend (Ground Truth)

Base URL: `{{AppEnv.apiV1BaseUrl}}` (misal: `http://localhost:3000/api/v1` atau `https://api.travelindo.com/api/v1`).
Semua response dibungkus dalam envelope standar:
```json
{
  "meta": {
    "success": true,
    "status": 200,
    "message": "Pesan deskriptif"
  },
  "data": ...
}
```

---

### 3.1 Registrasi & Aktivasi Akun

#### 1. Registrasi Akun Customer
- **Endpoint**: `POST /auth/register/customer`
- **Auth**: Public
- **Request Body (`application/json`)**:
  ```json
  {
    "email": "budi@example.com",
    "password": "Password123!",
    "fullName": "Budi Santoso",
    "phoneNumber": "081234567890"
  }
  ```
- **Validasi Backend**:
  - `email`: Format email valid, unik (belum terdaftar).
  - `password`: Minimal 8 karakter, wajib mengandung minimal 1 angka.
  - `fullName`: Minimal 2 karakter.
  - `phoneNumber`: Opsional, jika diisi minimal 9 karakter & unik.
- **Response (`201 Created`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 201,
      "message": "Customer berhasil terdaftar. Silakan cek OTP Anda."
    },
    "data": {
      "id": "b3e944d1-8d2a-43c2-a9b0-98ff2a8e3211",
      "email": "budi@example.com",
      "role": "CUSTOMER",
      "fullName": "Budi Santoso",
      "status": "PENDING"
    }
  }
  ```

#### 2. Registrasi Akun Mitra
- **Endpoint**: `POST /auth/register/mitra`
- **Auth**: Public
- **Request Body (`application/json`)**:
  ```json
  {
    "email": "mitra.rental@example.com",
    "password": "Password123!",
    "fullName": "Ahmad Dani",
    "phoneNumber": "081298765432"
  }
  ```
- **Validasi Backend**: Sama dengan customer, namun `phoneNumber` **wajib** diisi (min 9 digit).
- **Response (`201 Created`)**: Sama dengan registrasi customer dengan `role: "MITRA"`.

#### 3. Verifikasi Registrasi (Aktivasi OTP)
- **Endpoint**: `POST /auth/verify-registration`
- **Auth**: Public
- **Request Body**:
  ```json
  {
    "email": "budi@example.com",
    "code": "123456"
  }
  ```
- **Validasi Backend**: `code` tepat 6 digit angka, belum kadaluwarsa (TTL 10 menit), maksimal 5 kali percobaan gagal sebelum terkena rate limit `429 Too Many Requests`.
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Akun berhasil diverifikasi dan diaktifkan"
    },
    "data": {
      "id": "b3e944d1-8d2a-43c2-a9b0-98ff2a8e3211",
      "email": "budi@example.com",
      "role": "CUSTOMER",
      "fullName": "Budi Santoso",
      "status": "ACTIVE",
      "avatarUrl": null,
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```

#### 4. Pengiriman Ulang Kode OTP
- **Endpoint**: `POST /auth/resend-otp`
- **Auth**: Public
- **Request Body**:
  ```json
  {
    "email": "budi@example.com",
    "type": "REGISTRATION"
  }
  ```
  *(Catatan: `type` harus bernilai `"REGISTRATION"` atau `"PASSWORD_RESET"`).*
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Kode OTP baru telah dikirim"
    },
    "data": null
  }
  ```

---

### 3.2 Login, Sesi, dan Autentikasi Sosial

#### 5. Login Email & Password
- **Endpoint**: `POST /auth/login`
- **Auth**: Public (Diproteksi `authLimiter`: 10 request per 15 menit)
- **Request Body**:
  ```json
  {
    "email": "budi@example.com",
    "password": "Password123!"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Login berhasil"
    },
    "data": {
      "user": {
        "id": "b3e944d1-8d2a-43c2-a9b0-98ff2a8e3211",
        "email": "budi@example.com",
        "role": "CUSTOMER",
        "fullName": "Budi Santoso",
        "status": "ACTIVE",
        "avatarUrl": "https://pub-r2.travelindo.com/avatars/user_1.webp"
      },
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```

#### 6. Social Login Google
- **Endpoint**: `POST /auth/google`
- **Auth**: Public
- **Request Body**: `{ "token": "<Google_ID_Token>" }`
- **Response (`200 OK`)**: Format data sama dengan login kredensial `{ user, token }`.

#### 7. Social Login Facebook
- **Endpoint**: `POST /auth/facebook`
- **Auth**: Public
- **Request Body**: `{ "token": "<Facebook_Access_Token>" }`
- **Response (`200 OK`)**: Format data sama dengan login kredensial `{ user, token }`.

#### 8. Refresh Token
- **Endpoint**: `POST /auth/refresh-token`
- **Auth**: Public (Mengirimkan token lama)
- **Request Body**: `{ "token": "<Current_JWT_Token>" }`
- **Validasi Backend**: Memeriksa tanda tangan JWT dan memastikan `tokenVersion` pada token cocok dengan nilai di database.
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Token berhasil direfresh"
    },
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new..."
    }
  }
  ```

#### 9. Logout Pengguna
- **Endpoint**: `POST /auth/logout`
- **Auth**: Bearer Token
- **Perilaku Backend**: Menginkrementasi `tokenVersion` di tabel `User`, membatalkan seluruh token JWT yang telah terbit sebelumnya di server.
- **Response (`200 OK`)**: `{ "meta": { "success": true, "status": 200, "message": "Logout berhasil" }, "data": null }`

---

### 3.3 Pemulihan & Pengubahan Password

#### 10. Lupa Password (Request Reset Code)
- **Endpoint**: `POST /auth/forgot-password`
- **Request Body**: `{ "email": "budi@example.com" }`
- **Perilaku Backend**: Mengirimkan OTP 6-digit ke email. Selalu mengembalikan status sukses untuk mencegah *email enumeration attack*.
- **Response (`200 OK`)**: `{ "meta": { "success": true, "status": 200, "message": "Kode reset password telah dikirim ke email Anda" }, "data": null }`

#### 11. Verifikasi Kode Reset Password
- **Endpoint**: `POST /auth/verify-reset-code`
- **Request Body**: `{ "email": "budi@example.com", "code": "123456" }`
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Kode berhasil diverifikasi. Silakan ubah password Anda."
    },
    "data": {
      "resetToken": "eyJhbGciOiJIUzI1NiIs..."
    }
  }
  ```
  *(Catatan: `resetToken` adalah JWT bertanda khusus `purpose: "password_reset"` dengan masa aktif 10 menit).*

#### 12. Eksekusi Reset Password Dengan Token (Forgot Password Flow)
- **Endpoint**: `POST /auth/reset-password/:token`
- **Parameters**: `token` (nilai `resetToken` dari endpoint nomor 11)
- **Request Body**: `{ "password": "NewSecurePassword123!" }`
- **Perilaku Backend**: Mengupdate hash password dan menaikkan `tokenVersion` agar seluruh sesi aktif terputus.
- **Response (`200 OK`)**: `{ "meta": { "success": true, "status": 200, "message": "Password berhasil direset. Silakan login kembali." }, "data": null }`

#### 13. Ganti Password Pengguna yang Sedang Login (In-App Change Password)
- **Endpoint**: `POST /auth/reset-password`
- **Auth**: Bearer Token
- **Request Body**:
  ```json
  {
    "newPassword": "NewPassword123!",
    "currentPassword": "OldPassword123!"
  }
  ```
- **Response (`200 OK`)**: `{ "meta": { "success": true, "status": 200, "message": "Password berhasil direset" }, "data": null }`

---

### 3.4 Profil Pengguna, Avatar, & Verifikasi Identitas (KYC)

#### 14. Ambil Data Profil Pengguna Saat Ini
- **Endpoint**: `GET /auth/me`
- **Auth**: Bearer Token
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Data profil"
    },
    "data": {
      "id": "b3e944d1-8d2a-43c2-a9b0-98ff2a8e3211",
      "email": "budi@example.com",
      "role": "CUSTOMER",
      "fullName": "Budi Santoso",
      "phoneNumber": "081234567890",
      "avatarUrl": "https://pub-r2.travelindo.com/avatars/b3e944d1_1727248000.png",
      "status": "ACTIVE",
      "isVerified": false,
      "verificationStatus": "PENDING",
      "createdAt": "2026-09-01T04:00:00.000Z",
      "updatedAt": "2026-09-25T05:00:00.000Z",
      "mitraProfile": null
    }
  }
  ```

#### 15. Perbarui Profil & Upload Avatar
- **Endpoint**: `PATCH /auth/me`
- **Auth**: Bearer Token
- **Content-Type**: `multipart/form-data` atau `application/json`
- **Fields**:
  - `fullName`: String (min 2 karakter, opsional)
  - `avatar`: File gambar (`image/jpeg`, `image/png`, `image/webp`, maks 5MB, opsional)
- **Response (`200 OK`)**: Mengembalikan data profil terupdate dengan URL avatar publik Cloudflare R2.

#### 16. Request Ganti Nomor Telepon
- **Endpoint**: `POST /auth/me/phone/request-update`
- **Auth**: Bearer Token
- **Request Body**: `{ "phoneNumber": "081299998888" }`
- **Perilaku Backend**: Memastikan nomor belum dipakai akun lain, lalu mengirimkan OTP 6-digit ke nomor baru.
- **Response (`200 OK`)**: `{ "meta": { "success": true, "status": 200, "message": "Kode OTP telah dikirim ke nomor baru Anda" }, "data": null }`

#### 17. Verifikasi Ganti Nomor Telepon
- **Endpoint**: `POST /auth/me/phone/verify-update`
- **Auth**: Bearer Token
- **Request Body**:
  ```json
  {
    "phoneNumber": "081299998888",
    "code": "654321"
  }
  ```
- **Response (`200 OK`)**: Mengembalikan data profil dengan `phoneNumber` baru yang telah terverifikasi.

#### 18. Pengajuan Verifikasi Dokumen Identitas (KYC)
- **Endpoint**: `POST /auth/me/verify`
- **Auth**: Bearer Token
- **Content-Type**: `multipart/form-data`
- **Multipart Fields**:
  - `ktp`: File dokumen foto KTP (Wajib, maks 10MB)
  - `sim`: File dokumen foto SIM (Wajib/Opsional tergantung role, maks 10MB)
  - `selfie`: File foto selfie memegang identitas (Wajib, maks 10MB)
  - `ktpNumber`: String NIK 16 digit angka (Wajib)
  - `simNumber`: String nomor SIM min 10 digit (Opsional)
- **Perilaku Backend**: Berkas disimpan ke bucket R2 privat, NIK/SIM dienkripsi menggunakan AES-256 (`encryptField`), dan status verifikasi diubah menjadi `PENDING`.
- **Response (`200 OK`)**:
  ```json
  {
    "meta": {
      "success": true,
      "status": 200,
      "message": "Dokumen identitas berhasil dikirim untuk verifikasi"
    },
    "data": {
      "id": "b3e944d1-8d2a-43c2-a9b0-98ff2a8e3211",
      "verificationStatus": "PENDING",
      "isVerified": false
    }
  }
  ```

---

## 4. Rencana Perbaikan Backend (Backend Fixes & Hardening)

Untuk menjamin kelancaran integrasi kontrak, perbaikan teknis minor perlu diterapkan pada backend:

1. **Sinkronisasi Parameter Ubah Password ([`Backend/src/controllers/auth.controller.ts`](file:///d:/Retal-Apps/Backend/src/controllers/auth.controller.ts#L106-L110))**:
   - Di `authController.resetPassword`, baca nilai `req.body.newPassword || req.body.password`.
   - Update `auth.validation.ts` agar `resetPasswordSchema` menerima `newPassword` dan opsional `currentPassword`.
   - Di `auth.service.ts`, tambahkan verifikasi password lama (`currentPassword`) jika dikirimkan untuk keamanan akun.
2. **Fleksibilitas Schema Phone Number**:
   - Pastikan nomor telepon mendukung format internasional `+62` dan lokal `08`.

---

## 5. Desain Arsitektur & Refactor Frontend Flutter (`travelindo`)

Penyelarasan arsitektur frontend mencakup data layer, application layer, dan presentation layer:

```text
travelindo/lib/features/auth/
├── data/
│   ├── models/
│   │   ├── user_model.dart              <-- [REFACTOR] Tambah verificationStatus, NIK/SIM status
│   │   └── auth_session_model.dart      <-- [REFACTOR] Penanganan parsedUser saat token refresh
│   ├── auth_remote_datasource.dart      <-- [REFACTOR] Fix KYC multipart single request, phone update DTO, resend-otp type
│   └── auth_repository.dart             <-- [REFACTOR] Sesuaikan parameter & persisten sesi
├── application/
│   └── auth_service.dart                <-- [REFACTOR] Pertahankan data _user saat refresh token, state status KYC
└── presentation/
    ├── pages/
    │   ├── login_page.dart              <-- [REFACTOR] Tambah penanganan error 403 PENDING -> redirect ke OTP
    │   ├── register_page.dart           <-- [REFACTOR] Validasi password min 8 char + 1 angka
    │   ├── otp_verification_page.dart   <-- [REFACTOR] Kirim parameter type: 'REGISTRATION' saat resend OTP
    │   ├── forgot_password_page.dart    <-- [REFACTOR] UX loading & transisi ke reset password
    │   ├── reset_password_page.dart     <-- [REFACTOR] Validator OTP 6 digit, tombol kirim ulang OTP
    │   ├── change_password_page.dart    <-- [REFACTOR] Form ganti password dengan currentPassword & newPassword
    │   ├── kyc_page.dart                <-- [REFACTOR] Tambah field NIK 16 digit, nomor SIM, upload multipart tunggal
    │   ├── profile_page.dart            <-- [REFACTOR] Status badge KYC (Pending/Verified/Rejected), phone read-only
    │   └── settings_page.dart           <-- [REFACTOR] Dialog update nomor telepon mengirimkan phone & OTP lengkap
    └── widgets/
        └── auth_validators.dart         <-- [REFACTOR] Update password regex (min 1 digit) & OTP (exact 6 digit)
```

---

### 5.1 Standarisasi Model Data (`user_model.dart`)

Field `verificationStatus` ditambahkan agar frontend dapat merespons status verifikasi KYC secara akurat:

```dart
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    @Default('') String id,
    @Default('') String email,
    @Default('') String role,
    String? fullName,
    String? phoneNumber,
    String? status,
    String? avatarUrl,
    bool? isVerified,
    String? verificationStatus, // 'UNVERIFIED' | 'PENDING' | 'VERIFIED' | 'REJECTED'
    String? rejectionReason,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
```

---

### 5.2 Perbaikan Manajemen Sesi (`AuthService`)

Saat aplikasi melakukan `refreshSession()`, backend hanya merespons token baru. Logika `AuthService` diperbarui agar tidak menghapus profil pengguna yang sedang aktif:

```dart
Future<bool> refreshSession() async {
  _setLoading();
  try {
    final response = await _authRepository.refreshToken();
    // Hanya perbarui token, jangan timpa _user dengan null
    if (response.data?.user != null) {
      _user = response.data!.user;
    } else if (_user == null) {
      // Jika _user belum ada di memori, ambil profil lengkap
      await loadProfile();
    }
    _status = AuthStatus.authenticated;
    notifyListeners();
    await _postAuthSetup();
    return true;
  } catch (error) {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }
}
```

---

### 5.3 Perbaikan Pengajuan KYC (`KycPage` & `AuthRemoteDataSource`)

Mengganti pemanggilan 3x loop dengan 1 kali pengiriman multipart form menggunakan `MultipartUploadHelper.buildNamedDocForm`:

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

---

## 6. Matriks Penanganan Error (Error Handling & Edge Cases)

| Skenario | Response Code / Error | Tindakan & Feedback UI Frontend |
| :--- | :--- | :--- |
| Login akun belum diverifikasi | `403 Forbidden` (`Akun belum diverifikasi`) | Tampilkan dialog / banner: *"Akun Anda belum aktif. Masukkan kode OTP untuk mengaktifkan akun."* dengan tombol CTA *"Verifikasi OTP"* menuju `OtpVerificationPage`. |
| Akun ditangguhkan / dibanned | `403 Forbidden` (`Akun Anda telah ditangguhkan`) | Tampilkan AlertDialog peringatan merah dengan tautan menuju CS / WhatsApp Support. |
| Percobaan OTP melebihi batas (5x) | `429 Too Many Requests` (`Terlalu banyak percobaan`) | Kunci input OTP, tampilkan hitung mundur (*cooldown timer*) 15 menit. |
| OTP salah atau kadaluwarsa | `400 Bad Request` (`Sisa percobaan: X`) | Tampilkan pesan sisa kesempatan pada `AuthMessage` dan getar *haptic feedback*. |
| NIK tidak 16 digit | `400 Bad Request` (`NIK harus 16 digit`) | Validasi sebelum submit di form Flutter, cegah pengiriman ke server. |
| Format Password tidak ada angka | `400 Bad Request` (`Password harus mengandung minimal 1 angka`) | Indikator *real-time password strength checklist* di bawah field password. |
| Token refresh kadaluwarsa / versi dicabut | `401 Unauthorized` (`Token telah direvoke`) | Hapus session storage, reset state ke `unauthenticated`, arahkan pengguna ke `LoginPage`. |

---

## 7. Kesimpulan & Langkah Eksekusi

Dokumen perencanaan ini menjadi panduan arsitektur komprehensif untuk memastikan seluruh alur autentikasi dan keamanan Travelindo berjalan tanpa celah. Detail langkah implementasi bertahap, checklist pengujian, dan *Definition of Done* (DoD) dijabarkan pada file pendamping: [`travelindo/docs/TASK_AUTH_V2.md`](file:///d:/Retal-Apps/travelindo/docs/TASK_AUTH_V2.md).
