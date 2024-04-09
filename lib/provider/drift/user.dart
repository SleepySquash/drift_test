import 'package:drift/drift.dart';

import '/domain/model/user.dart';
import 'drift.dart';

class DtoUsers extends Table {
  TextColumn get id => text().unique()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class UserDriftProvider {
  UserDriftProvider(this.database);

  final DriftProvider database;

  Future<List<User>> users() async {
    final dto = await database.select(database.dtoUsers).get();
    return dto.map(_UserDb.fromDb).toList();
  }

  Future<void> create(User user) async {
    final int affected =
        await database.into(database.dtoUsers).insert(_UserDb.toDb(user));

    print('create($user): affected $affected rows');
  }

  Future<void> delete(UserId id) async {
    final stmt = database.delete(database.dtoUsers)
      ..where((e) => e.id.equals(id.val));
    final int affected = await stmt.go();

    print('delete($id): affected $affected rows');
  }

  Stream<List<User>> watch() {
    // final query = database.select(database.dtoUsers);
    // final updateFilter = TableUpdateQuery.onTable(
    //   database.dtoUsers,
    //   limitUpdateKind: UpdateKind.insert,
    // );

    // return database.tableUpdates(updateFilter).asyncMap(query.get());
    // database
    //     .tableUpdates(TableUpdateQuery.onTable(yourTable,
    //         limitUpdateKind: UpdateKind.update))
    //     .asyncMap(query.get());

    // database
    //     .tableUpdates(TableUpdateQuery.onTable(database.dtoUsers))
    //     .asyncExpand(
    //   (events) async* {
    //     for (var e in events) {
    //       print('tableUpdates(): ${e.kind}');

    //       switch (e.kind) {
    //         case UpdateKind.insert:
    //           break;

    //         case UpdateKind.update:
    //           break;

    //         case UpdateKind.delete:
    //           break;

    //         case null:
    //           // No-op.
    //           break;
    //       }
    //     }
    //   },
    // ).listen((_) {});

    return database.select(database.dtoUsers).watch().expand(
          (users) => [users.map(_UserDb.fromDb).toList()],
        );
  }
}

extension _UserDb on User {
  static User fromDb(DtoUser e) {
    return User(
      id: UserId(e.id),
      name: UserName(e.name),
      createdAt: e.createdAt,
    );
  }

  static DtoUser toDb(User e) {
    return DtoUser(
      id: e.id.val,
      name: e.name.val,
      createdAt: e.createdAt,
    );
  }
}
