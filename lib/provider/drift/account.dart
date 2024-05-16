import 'package:drift/drift.dart';

import '/domain/model/user.dart';
import 'drift.dart';

@DataClassName('AccountRow')
class Account extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get userId => text()();
}

class AccountDriftProvider extends DriftProviderBase {
  AccountDriftProvider(super.db);

  Future<UserId?> get() async {
    final dto = await (db.select(db.account)).getSingleOrNull();
    if (dto == null) {
      return null;
    }

    return _AccountDb.fromDb(dto);
  }

  Future<void> set(UserId? id) async {
    if (id == null) {
      await db.delete(db.users).go();
    } else {
      await db.into(db.account).insertOnConflictUpdate(id.toDb());
    }
  }

  Stream<UserId?> watch() {
    final stmt = db.select(db.account);
    return stmt
        .watchSingleOrNull()
        .map((e) => e == null ? null : _AccountDb.fromDb(e));
  }
}

extension _AccountDb on UserId {
  static UserId fromDb(AccountRow e) {
    return UserId(e.userId);
  }

  AccountRow toDb() {
    return AccountRow(id: '0', userId: val);
  }
}
