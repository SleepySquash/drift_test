import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/user.dart';

import '/domain/model/user.dart';
import '/util/diff.dart';
import 'drift.dart';

class DtoChatMembers extends Table {
  TextColumn get userId => text().references(DtoUsers, #id).unique()();

  TextColumn get chatId => text().references(DtoChats, #id)();
}

class ChatMemberDriftProvider {
  ChatMemberDriftProvider(this.database);

  final DriftProvider database;

  $DtoChatMembersTable get dtoChatMembers => database.dtoChatMembers;

  Future<List<ChatMember>> members(ChatId id) async {
    final dto = await database.select(dtoChatMembers).get();
    return dto.map(ChatMemberDb.fromDb).toList();
  }

  Future<void> create(ChatMember member) async {
    final int affected =
        await database.into(dtoChatMembers).insert(ChatMemberDb.toDb(member));

    print('create($member): affected $affected rows');
  }

  Future<void> delete(UserId id) async {
    final stmt = database.delete(dtoChatMembers)
      ..where((e) => e.userId.equals(id.val));
    final int affected = await stmt.go();

    print('delete($id): affected $affected rows');
  }

  Stream<MapChangeNotification<UserId, ChatMember>> watch(ChatId id) {
    var query = database.select(dtoChatMembers);
    query.where((m) => m.chatId.equals(id.val));

    return query
        .watch()
        .map((users) => {for (var e in users.map(ChatMemberDb.fromDb)) e.id: e})
        .changes();
  }
}

extension ChatMemberDb on ChatMember {
  static ChatMember fromDb(DtoChatMember e) {
    return ChatMember(
      id: UserId(e.userId),
      chatId: ChatId(e.chatId),
    );
  }

  static DtoChatMember toDb(ChatMember e) {
    return DtoChatMember(
      userId: e.id.val,
      chatId: e.chatId.val,
    );
  }
}
