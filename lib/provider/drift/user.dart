import 'dart:convert';

import 'package:drift/drift.dart';

import '/domain/model/user.dart';
import '/util/diff.dart';
import 'chat.dart';
import 'common.dart';
import 'drift.dart';

@DataClassName('UserRow')
class Users extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get num => text().unique()();
  TextColumn get name => text().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get avatar => text().nullable()(); // JSON
  TextColumn get callCover => text().nullable()(); // JSON
  IntColumn get mutualContactsCount =>
      integer().withDefault(const Constant(0))();
  BoolColumn get online => boolean().withDefault(const Constant(false))();
  IntColumn get presenceIndex => integer().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get dialog => text().nullable().references(
        Chats,
        #id,
        onDelete: KeyAction.setNull,
        onUpdate: KeyAction.cascade,
      )();
  IntColumn get createdAt => integer().map(const DateTimeConverter())();
}

class UserDriftProvider extends DriftProviderBase {
  UserDriftProvider(super.database);

  Future<List<User>> users({int? limit, int? offset}) async {
    final stmt = db.select(db.users);
    stmt.orderBy([(u) => OrderingTerm.desc(u.createdAt)]);

    if (limit != null) {
      stmt.limit(limit, offset: offset);
    }

    final List<UserRow> rows = await stmt.get();
    return rows.map(UserDb.fromDb).toList();
  }

  Future<User?> user(UserId id) async {
    final dto = await (db.select(db.users)..where((u) => u.id.equals(id.val)))
        .getSingleOrNull();

    if (dto == null) {
      return null;
    }

    return UserDb.fromDb(dto);
  }

  Future<User> create(User user) async {
    return UserDb.fromDb(await db.into(db.users).insertReturning(user.toDb()));
  }

  Future<void> update(User user) async {
    final stmt = db.update(db.users);
    await stmt.replace(user.toDb());
  }

  Future<void> delete(UserId id) async {
    final stmt = db.delete(db.users);
    stmt.where((e) => e.id.equals(id.val));
    await stmt.go();
  }

  Stream<MapChangeNotification<UserId, User>> watch() {
    final stmt = db.select(db.users);
    stmt.orderBy([(u) => OrderingTerm.desc(u.createdAt)]);

    return const Stream.empty();

    // return stmt
    //     .watch()
    //     .map((users) => {for (var e in users.map(UserDb.fromDb)) e.id: e})
    //     .changes();
  }

  Stream<User?> watchSingle(UserId id) {
    final stmt = db.select(db.users)..where((u) => u.id.equals(id.val));

    return stmt.watch().map((e) {
      if (e.isEmpty) {
        return null;
      }

      return UserDb.fromDb(e.first);
    });
  }
}

extension UserDb on User {
  static User fromDb(UserRow e) {
    return User(
      id: UserId(e.id),
      num: UserNum(e.num),
      name: e.name == null ? null : UserName(e.name!),
      avatar: e.avatar == null ? null : Avatar.fromJson(jsonDecode(e.avatar!)),
      createdAt: e.createdAt,
    );
  }

  UserRow toDb() {
    return UserRow(
      id: id.val,
      num: this.num.val,
      name: name?.val,
      createdAt: createdAt,
      online: false,
      isDeleted: false,
      mutualContactsCount: 0,
      avatar: avatar == null ? null : jsonEncode(avatar?.toJson()),
    );
  }
}
