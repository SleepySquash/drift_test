import 'package:drift/drift.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:log_me/log_me.dart';
import 'account.dart';
import 'chat_item.dart';
import 'connection/connection.dart' as impl;

import 'chat.dart';
import '/domain/model/chat_item.dart';
import 'user.dart';

part 'drift.g.dart';

@DriftDatabase(tables: [Account, Users, Chats, ChatMembers, ChatItems])
class DriftProvider extends _$DriftProvider {
  DriftProvider() : super(impl.connect()) {
    notifyUpdates({for (final table in allTables) TableUpdate.onTable(table)});
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, a, b) async {
        Log.debug('onUpgrade($a, $b)', 'MigrationStrategy');

        // TODO: Implement proper migrations.
        if (a != b) {
          for (var e in m.database.allTables) {
            await m.deleteTable(e.actualTableName);
          }
        }

        await m.createAll();
      },
      beforeOpen: (_) async {
        Log.debug('beforeOpen()', 'MigrationStrategy');

        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

class DriftProviderBase {
  DriftProviderBase(this.db);

  final DriftProvider db;

  Future<void> txn<T>(Future<T> Function() action) async {
    await db.transaction(action);
  }
}
