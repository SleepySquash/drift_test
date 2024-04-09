import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<File> get databaseFile async {
  // We use `path_provider` to find a suitable path to store our data in.
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'todos.db');
  return File(dbPath);
}

Future<void> initDatabase() async {
  final DriftIsolate di = await createIsolate();
  IsolateNameServer.registerPortWithName(di.connectPort, "drift_isolate");
}

Future<DriftIsolate> createIsolate() async {
  final token = RootIsolateToken.instance;

  return await DriftIsolate.spawn(() {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;

      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      final db = NativeDatabase(
        file,
        logStatements: true,
        setup: (db) => db.execute('PRAGMA journal_mode=WAL;'),
      );

      return db;
    });
  });
}

/// Obtains a database connection for running drift in a Dart VM.
QueryExecutor connect() {
  return LazyDatabase(() async {
    final di = DriftIsolate.fromConnectPort(
      IsolateNameServer.lookupPortByName('drift_isolate')!,
    );
    final conn = await di.connect(isolateDebugLog: true);
    return conn.executor;

    // // put the database file, called db.sqlite here, into the documents folder
    // // for your app.
    // final dbFolder = await getApplicationDocumentsDirectory();
    // final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // // Also work around limitations on old Android versions
    // if (Platform.isAndroid) {
    //   await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    // }

    // // Make sqlite3 pick a more suitable location for temporary files - the
    // // one from the system may be inaccessible due to sandboxing.
    // final cachebase = (await getTemporaryDirectory()).path;

    // // We can't access /tmp on Android, which sqlite3 would try by default.
    // // Explicitly tell it about the correct temporary directory.
    // sqlite3.tempDirectory = cachebase;

    // return NativeDatabase.createInBackground(
    //   file,
    //   setup: (db) => db.execute('PRAGMA journal_mode = wal'),
    // );
  });
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // This method validates that the actual schema of the opened database matches
  // the tables, views, triggers and indices for which drift_dev has generated
  // code.
  // Validating the database's schema after opening it is generally a good idea,
  // since it allows us to get an early warning if we change a table definition
  // without writing a schema migration for it.
  //
  // For details, see: https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime
  if (kDebugMode) {
    await VerifySelf(database).validateDatabaseSchema();
  }
}
