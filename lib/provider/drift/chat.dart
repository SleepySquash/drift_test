import 'package:drift/drift.dart';

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

  Future<List<Chat>> chats() async {
    final dto = await database.select(database.dtoChats).get();
    return dto.map(_ChatDb.fromDb).toList();
  }

  Future<void> create(Chat chat) async {
    await database.into(database.dtoChats).insert(_ChatDb.toDb(chat));
  }

  Future<void> delete(ChatId id) async {
    final stmt = database.delete(database.dtoChats)
      ..where((e) => e.id.equals(id.val));

    await stmt.go();
  }

  Stream<MapChangeNotification<ChatId, Chat>> watch() {
    return database
        .select(database.dtoChats)
        .watch()
        .map((chats) => {for (var e in chats.map(_ChatDb.fromDb)) e.id: e})
        .changes();
  }
}

extension _ChatDb on Chat {
  static Chat fromDb(DtoChat e) {
    return Chat(
      id: ChatId(e.id),
      name: ChatName(e.name),
      createdAt: e.createdAt,
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
