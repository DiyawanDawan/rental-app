class Failure {
  const Failure({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Object? details;

  @override
  String toString() => 'Failure($statusCode, $message)';
}
