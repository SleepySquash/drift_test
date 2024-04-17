import '/domain/model/user.dart';
import '/util/diff.dart';
import 'drift.dart';

class UserDriftProvider {
  UserDriftProvider(this.database);

  final DriftProvider database;

  Future<List<User>> users() async {
    final dto = await database.select(database.dtoUser).get();
    return dto.map(UserDtoExtension.fromDto).toList();
  }

  Future<void> create(User user) async {
    final int affected =
        await database.into(database.dtoUser).insert(user.toDto());

    print('create($user): affected $affected rows');
  }

  Future<void> delete(UserId id) async {
    final stmt = database.delete(database.dtoUser)
      ..where((e) => e.idVal.equals(id.val));
    final int affected = await stmt.go();

    print('delete($id): affected $affected rows');
  }

  Stream<MapChangeNotification<UserId, User>> watch() {
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

    return database
        .select(database.dtoUser)
        .watch()
        .map(
          (users) => {
            for (var e in users.map(UserDtoExtension.fromDto)) e.id: e,
          },
        )
        .changes();
  }
}
