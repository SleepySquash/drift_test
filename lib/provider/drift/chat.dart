import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/util/diff.dart';

import '/domain/model/chat.dart';
import 'drift.dart';

@DataClassName('ChatRow')
class Chats extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatar => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
}

class ChatDriftProvider extends DriftProviderBase {
  ChatDriftProvider(super.db);

  Future<List<ChatMember>> Function(ChatId)? getMembers;

  Future<Chat?> chat(ChatId id) async {
    final dto = await (db.select(db.chats)..where((u) => u.id.equals(id.val)))
        .getSingleOrNull();

    if (dto == null) {
      return null;
    }

    return _ChatDb.fromDb(dto);
  }

  Future<List<Chat>> chats() async {
    final dto = await db.select(db.chats).get();
    return dto.map(_ChatDb.fromDb).toList();
  }

  Future<void> create(Chat chat) async {
    await db.into(db.chats).insert(chat.toDb());
  }

  Future<void> update(Chat chat) async {
    final stmt = db.update(db.chats);
    await stmt.replace(chat.toDb());
  }

  Future<void> delete(ChatId id) async {
    final stmt = db.delete(db.chats)..where((e) => e.id.equals(id.val));

    await stmt.go();
  }

  Stream<List<MapChangeNotification<ChatId, Chat>>> watch() {
    return db.select(db.chats).watch().map((chats) {
      return {for (var e in chats.map(_ChatDb.fromDb)) e.id: e};
    }).changes();
  }
}

extension _ChatDb on Chat {
  static Chat fromDb(ChatRow e) {
    return Chat(
      id: ChatId(e.id),
      name: ChatName(e.name),
      avatar: e.avatar == null ? null : Avatar(e.avatar!),
      createdAt: e.createdAt,
    );
  }

  ChatRow toDb() {
    return ChatRow(
      id: id.val,
      name: name.val,
      avatar: avatar?.url,
      createdAt: createdAt,
    );
  }
}
