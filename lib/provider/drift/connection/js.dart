import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'package:log_me/log_me.dart';

/// Obtains a database connection for running drift on the web.
QueryExecutor connect() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'my_app_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    Log.info('Using ${result.chosenImplementation} for `drift` backend.');

    if (result.missingFeatures.isNotEmpty) {
      Log.warning(
        'Browser misses the following features in order for `drift` to be as performant as possible: ${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  }));
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {}
