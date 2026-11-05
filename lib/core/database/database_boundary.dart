import 'package:yamintto/core/errors/domain_failure.dart';

/// Converts unexpected storage-layer exceptions into a safe typed failure.
abstract final class DatabaseBoundary {
  static Future<T> guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DomainFailure {
      rethrow;
    } catch (_) {
      throw const DomainFailure(
        DomainFailureCode.databaseConstraint,
        'The local database operation could not be completed.',
      );
    }
  }
}
