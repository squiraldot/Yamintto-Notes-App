sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class UnexpectedAppException extends AppException {
  const UnexpectedAppException(super.message);
}
