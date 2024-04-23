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
  ChatDriftProvider(this.database);

  final DriftProvider database;

  $DtoChatsTable get dtoChats => database.dtoChats;

  $DtoChatMembersTable get dtoChatMembers => database.dtoChatMembers;

  Future<List<Chat>> chats() async {
    final dto = await database.select(database.dtoChats).get();
    return dto.map((e) => _ChatDb.fromDb(e, [])).toList();
  }

  Future<void> create(Chat chat) async {
    await database.into(dtoChats).insert(_ChatDb.toDb(chat));

    for (var element in chat.members) {
      database.into(dtoChatMembers).insert(ChatMemberDb.toDb(element));
    }
  }

  Future<void> delete(ChatId id) async {
    final stmt = database.delete(dtoChats)..where((e) => e.id.equals(id.val));

    await stmt.go();
  }

  Stream<MapChangeNotification<ChatId, Chat>> watch() {
    return database
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
            final query = database.select(dtoChatMembers)
              ..where((m) => m.chatId.equals(event.value!.id.val))
              ..limit(3);

            event.value?.members
                .addAll((await query.get()).map(ChatMemberDb.fromDb));
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

  static DtoChat toDb(Chat e) {
    return DtoChat(
      id: e.id.val,
      name: e.name.val,
      createdAt: e.createdAt,
    );
  }
}
