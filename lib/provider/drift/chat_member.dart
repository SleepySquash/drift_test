import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/user.dart';

import '/domain/model/user.dart';
import '/util/diff.dart';
import 'drift.dart';

class DtoChatMembers extends Table {
  TextColumn get userId => text().unique()();

  TextColumn get chatId =>
      text().references(DtoChats, #id, onDelete: KeyAction.cascade)();
}

class ChatMemberDriftProvider {
  ChatMemberDriftProvider(this._database, this._userProvider);

  final DriftProvider _database;

  final UserDriftProvider _userProvider;

  $DtoChatMembersTable get dtoChatMembers => _database.dtoChatMembers;

  $DtoUsersTable get dtoUsers => _database.dtoUsers;

  Future<List<ChatMember>> members(ChatId id, {int? limit}) async {
    final query = (_database.select(dtoChatMembers)
          ..where((m) => m.chatId.equals(id.val)))
        .join([
      innerJoin(dtoUsers, dtoUsers.id.equalsExp(dtoChatMembers.userId)),
    ]);

    if (limit != null) {
      query.limit(limit);
    }

    return (await query.get())
        .map((e) {
          final userDto = e.readTableOrNull(dtoUsers);

          if (userDto != null) {
            return ChatMemberDb.fromDb(
              e.readTable(dtoChatMembers),
              UserDb.fromDb(userDto),
            );
          }
        })
        .whereNotNull()
        .toList();
  }

  Future<void> create(ChatMember member) async {
    final int affected =
        await _database.into(dtoChatMembers).insert(member.toDb());

    await _userProvider.create(member.user);

    print('create($member): affected $affected rows');
  }

  Future<void> delete(UserId id) async {
    final stmt = _database.delete(dtoChatMembers)
      ..where((e) => e.userId.equals(id.val));
    final int affected = await stmt.go();

    print('delete($id): affected $affected rows');
  }

  Stream<MapChangeNotification<UserId, ChatMember>> watch(ChatId id) {
    var query = _database.select(dtoChatMembers)
      ..where((m) => m.chatId.equals(id.val));

    return query
        .join(
          [innerJoin(dtoUsers, dtoUsers.id.equalsExp(dtoChatMembers.userId))],
        )
        .watch()
        .map((rows) {
          Map<UserId, ChatMember> members = {};

          for (var e in rows) {
            final userDto = e.readTableOrNull(dtoUsers);

            if (userDto != null) {
              final member = ChatMemberDb.fromDb(
                e.readTable(dtoChatMembers),
                UserDb.fromDb(userDto),
              );
              members[member.user.id] = member;
            }
          }

          return members;
        })
        .changes();
  }
}

extension ChatMemberDb on ChatMember {
  static ChatMember fromDb(DtoChatMember e, User user) {
    return ChatMember(
      user: user,
      chatId: ChatId(e.chatId),
    );
  }

  DtoChatMember toDb() {
    return DtoChatMember(
      userId: user.id.val,
      chatId: chatId.val,
    );
  }
}
