import 'package:drift/drift.dart';

import '/domain/model/user.dart';
import '/util/diff.dart';
import 'drift.dart';

class DtoUsers extends Table {
  TextColumn get id => text().unique()();

  TextColumn get name => text()();

  DateTimeColumn get createdAt => dateTime()();
}

class UserDriftProvider {
  UserDriftProvider(this._database);

  final DriftProvider _database;

  $DtoUsersTable get dtoUsers => _database.dtoUsers;

  Future<List<User>> users() async {
    final dto = await _database.select(dtoUsers).get();
    return dto.map(UserDb.fromDb).toList();
  }

  Future<User> user(UserId id) async {
    final dto = await (_database.select(dtoUsers)
          ..where((u) => u.id.equals(id.val)))
        .getSingle();

    return UserDb.fromDb(dto);
  }

  Future<void> create(User user) async {
    final int affected = await _database.into(dtoUsers).insert(user.toDb());

    print('create($user): affected $affected rows');
  }

  Future<void> update(User user) async {
    final int affected = await (_database.update(dtoUsers)
          ..where((u) => u.id.equals(user.id.val)))
        .write(user.toDb());

    print('update($user): affected $affected rows');
  }

  Future<void> delete(UserId id) async {
    final stmt = _database.delete(dtoUsers)..where((e) => e.id.equals(id.val));
    final int affected = await stmt.go();

    print('delete($id): affected $affected rows');
  }

  Stream<MapChangeNotification<UserId, User>> watch() {
    return _database
        .select(dtoUsers)
        .watch()
        .map((users) => {for (var e in users.map(UserDb.fromDb)) e.id: e})
        .changes();
  }
}

extension UserDb on User {
  static User fromDb(DtoUser e) {
    return User(
      id: UserId(e.id),
      name: UserName(e.name),
      createdAt: e.createdAt,
    );
  }

  DtoUser toDb() {
    return DtoUser(
      id: id.val,
      name: name.val,
      createdAt: createdAt,
    );
  }
}
