import '../errors/failure.dart';

/// Safe user-facing error text — never expose raw exception internals.
String userFacingError(Object error) {
  if (error is Failure) return error.message;
  return 'Terjadi kesalahan. Silakan coba lagi.';
}
