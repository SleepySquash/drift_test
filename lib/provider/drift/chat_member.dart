import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/user.dart';

import '/domain/model/user.dart';
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

  DateTimeColumn get createdAt => dateTime()();
}

class ChatMemberDriftProvider {
  ChatMemberDriftProvider(this._database, this._userProvider);

  final DriftProvider _database;

  final UserDriftProvider _userProvider;

  Future<RxUser?> Function(UserId)? getUser;

  Future<List<ChatMember>> members(
    ChatId id, {
    int limit = 120,
    int offset = 0,
  }) async {
    final stmt = _database.select(_database.chatMembers).join([
      innerJoin(
        _database.users,
        _database.users.id.equalsExp(_database.chatMembers.userId),
      )
    ])
      ..where(_database.chatMembers.chatId.equals(id.val))
      ..limit(limit, offset: offset);

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
    await _userProvider.create(member.user);
  }

  Future<void> delete(UserId id) async {
    final stmt = _database.delete(_database.chatMembers)
      ..where((e) => e.userId.equals(id.val));
    await stmt.go();
  }

  // Stream<MapChangeNotification<UserId, ChatMember>> watch(ChatId id) {
  //   var query = _database.select(_database.chatMembers)
  //     ..where((m) => m.chatId.equals(id.val));

  //   return query.watch().asyncMap((rows) async {
  //     Map<UserId, ChatMember> members = {};

  //     for (var e in rows) {
  //       final RxUser? user = await getUser?.call(UserId(e.userId));

  //       if (user != null) {
  //         final member = ChatMemberDb.fromDb(e, user.user.value);
  //         members[member.user.id] = member;
  //       }
  //     }

  //     return members;
  //   }).changes();
  // }
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
