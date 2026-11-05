import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:yamintto/core/database/yamintto_database.dart';
import 'package:yamintto/core/errors/domain_failure.dart';

/// Memoized, lazy, app-scoped owner for the single local database instance.
final databaseProvider = FutureProvider<YaminttoDatabase>((ref) async {
  YaminttoDatabase? database;
  try {
    final supportDirectory = await getApplicationSupportDirectory();
    final databaseDirectory = Directory(
      path.join(supportDirectory.path, 'database'),
    );
    await databaseDirectory.create(recursive: true);

    final openedDatabase = YaminttoDatabase.open(
      File(path.join(databaseDirectory.path, 'yamintto.sqlite')),
    );
    database = openedDatabase;
    await openedDatabase.customSelect('SELECT 1').get();
    ref.onDispose(() {
      unawaited(openedDatabase.close());
    });
    return openedDatabase;
  } on DomainFailure {
    await database?.close();
    rethrow;
  } catch (_) {
    await database?.close();
    throw const DomainFailure(
      DomainFailureCode.databaseInitialization,
      'The local database could not be opened safely.',
    );
  }
});
