import '/domain/model/chat.dart';
import '/util/diff.dart';
import 'drift.dart';

class ChatDriftProvider {
  ChatDriftProvider(this.database);

  final DriftProvider database;

  Future<List<Chat>> chats() async {
    final dto = await database.select(database.dtoChat).get();
    return dto.map(ChatDtoExtension.fromDto).toList();
  }

  Future<void> create(Chat chat) async {
    await database.into(database.dtoChat).insert(chat.toDto());
  }

  Future<void> delete(ChatId id) async {
    final stmt = database.delete(database.dtoChat)
      ..where((e) => e.idVal.equals(id.val));

    await stmt.go();
  }

  Stream<MapChangeNotification<ChatId, Chat>> watch() {
    return database
        .select(database.dtoChat)
        .watch()
        .map(
          (chats) => {
            for (var e in chats.map(ChatDtoExtension.fromDto)) e.id: e,
          },
        )
        .changes();
  }
}
