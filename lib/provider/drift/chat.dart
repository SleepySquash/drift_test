import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/provider/drift/chat_member.dart';

import '/domain/model/chat.dart';
import '/util/diff.dart';
import 'drift.dart';

class DtoChats extends Table {
  TextColumn get id => text().unique()();

  TextColumn get name => text()();

  DateTimeColumn get createdAt => dateTime()();
}

class ChatDriftProvider {
  ChatDriftProvider(this._database, this._membersProvider);

  final DriftProvider _database;

  final ChatMemberDriftProvider _membersProvider;

  $DtoChatsTable get dtoChats => _database.dtoChats;

  $DtoChatMembersTable get dtoChatMembers => _database.dtoChatMembers;

  Future<List<Chat>> chats() async {
    final dto = await _database.select(_database.dtoChats).get();
    return dto.map((e) => _ChatDb.fromDb(e, [])).toList();
  }

  Future<void> create(Chat chat) async {
    await _database.into(dtoChats).insert(chat.toDb());

    for (var e in chat.members) {
      await _membersProvider.create(e);
    }
  }

  Future<void> delete(ChatId id) async {
    final stmt = _database.delete(dtoChats)..where((e) => e.id.equals(id.val));

    await stmt.go();
  }

  Stream<MapChangeNotification<ChatId, Chat>> watch() {
    return _database
        .select(dtoChats)
        .watch()
        .map((dtoChats) {
          return {
            for (var e in dtoChats.map((c) => _ChatDb.fromDb(c, []))) e.id: e
          };
        })
        .changes()
        .asyncMap((event) async {
          if (event.op == OperationKind.added && event.value != null) {
            final members =
                await _membersProvider.members(event.value!.id, limit: 3);

            event.value?.members.addAll(members);
          }

          return event;
        });
  }
}

extension _ChatDb on Chat {
  static Chat fromDb(DtoChat e, List<ChatMember> members) {
    return Chat(
      id: ChatId(e.id),
      name: ChatName(e.name),
      createdAt: e.createdAt,
      members: members,
    );
  }

  DtoChat toDb() {
    return DtoChat(
      id: id.val,
      name: name.val,
      createdAt: createdAt,
    );
  }
}
