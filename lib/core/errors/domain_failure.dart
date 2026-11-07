enum DomainFailureCode {
  invalidName,
  invalidTagName,
  invalidColor,
  invalidTitle,
  nameConflict,
  notFound,
  deletedEntity,
  folderNotEmpty,
  depthExceeded,
  hierarchyCycle,
  invalidDestination,
  databaseConstraint,
  databaseInitialization,
  migrationUnsupported,
  unsupportedContentFormat,
  staleNoteEdit,
}

/// A typed, presentation-safe domain failure. SQLite details are never exposed.
final class DomainFailure implements Exception {
  const DomainFailure(this.code, this.message);

  final DomainFailureCode code;
  final String message;

  @override
  String toString() => message;
}
