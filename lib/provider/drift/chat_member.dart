import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:drift_test/util/diff.dart';

import '/domain/model/user.dart';
import 'common.dart';
import 'drift.dart';

@DataClassName('ChatMemberRow')
class ChatMembers extends Table {
  @override
  Set<Column> get primaryKey => {userId, chatId};

  TextColumn get userId => text().references(
        Users,
        #id,
        onUpdate: KeyAction.cascade,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get chatId => text().references(
        Chats,
        #id,
        onUpdate: KeyAction.cascade,
        onDelete: KeyAction.cascade,
      )();

  IntColumn get createdAt => integer().map(const DateTimeConverter())();
}

class ChatMemberDriftProvider {
  ChatMemberDriftProvider(this._database);

  final DriftProvider _database;

  Future<RxUser?> Function(UserId)? getUser;

  Future<List<ChatMember>> members(
    ChatId id, {
    int? limit,
    int? offset,
  }) async {
    final stmt = _database.select(_database.chatMembers).join([
      innerJoin(
        _database.users,
        _database.users.id.equalsExp(_database.chatMembers.userId),
      )
    ]);
    stmt.where(_database.chatMembers.chatId.equals(id.val));

    if (limit != null) {
      stmt.limit(limit, offset: offset);
    }

    final rows = await stmt.get();

    final List<ChatMember> members = rows.map((row) {
      return ChatMember(
        joinedAt: row.readTable(_database.chatMembers).createdAt,
        user: UserDb.fromDb(row.readTable(_database.users)),
      );
    }).toList();

    return members;
  }

  Future<void> create(ChatId chatId, ChatMember member) async {
    await _database.into(_database.chatMembers).insert(member.toDb(chatId));
  }

  Future<void> delete(UserId id) async {
    final stmt = _database.delete(_database.chatMembers)
      ..where((e) => e.userId.equals(id.val));
    await stmt.go();
  }

  Future<void> clear() async {
    await _database.delete(_database.chatMembers).go();
  }

  Stream<MapChangeNotification<UserId, ChatMember>> watch(
    ChatId id, {
    int limit = 120,
    int offset = 0,
  }) {
    final stmt = _database.select(_database.chatMembers).join([
      innerJoin(
        _database.users,
        _database.users.id.equalsExp(_database.chatMembers.userId),
      )
    ]);
    stmt.where(_database.chatMembers.chatId.equals(id.val));
    stmt.limit(limit, offset: offset);

    return const Stream.empty();

    // return stmt.watch().map((rows) {
    //   return {
    //     for (var e in rows.map((e) {
    //       return ChatMember(
    //         joinedAt: e.readTable(_database.chatMembers).createdAt,
    //         user: UserDb.fromDb(e.readTable(_database.users)),
    //       );
    //     }))
    //       e.user.id: e
    //   };
    // }).changes();
  }
}

extension ChatMemberDb on ChatMember {
  ChatMemberRow toDb(ChatId chatId) {
    return ChatMemberRow(
      userId: user.id.val,
      chatId: chatId.val,
      createdAt: joinedAt,
    );
  }
}
