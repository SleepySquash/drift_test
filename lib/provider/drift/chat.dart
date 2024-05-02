import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat_member.dart';

import '/domain/model/chat.dart';
import 'drift.dart';

@DataClassName('ChatRow')
class Chats extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class ChatDriftProvider {
  ChatDriftProvider(this._database);

  final DriftProvider _database;

  Future<List<ChatMember>> Function(ChatId)? getMembers;

  Future<Chat?> chat(ChatId id) async {
    final dto = await (_database.select(_database.chats)
          ..where((u) => u.id.equals(id.val)))
        .getSingleOrNull();

    if (dto == null) {
      return null;
    }

    return _ChatDb.fromDb(dto);
  }

  Future<List<Chat>> chats() async {
    final dto = await _database.select(_database.chats).get();
    return dto.map(_ChatDb.fromDb).toList();
  }

  Future<void> create(Chat chat) async {
    await _database.into(_database.chats).insert(chat.toDb());
  }

  Future<void> delete(ChatId id) async {
    final stmt = _database.delete(_database.chats)
      ..where((e) => e.id.equals(id.val));

    await stmt.go();
  }

  // Stream<MapChangeNotification<ChatId, Chat>> watch() {
  //   return _database
  //       .select(dtoChats)
  //       .watch()
  //       .map((dtoChats) {
  //         return {
  //           for (var e in dtoChats.map((c) => _ChatDb.fromDb(c, []))) e.id: e
  //         };
  //       })
  //       .changes()
  //       .asyncMap((event) async {
  //         if ((event.op == OperationKind.added ||
  //                 event.op == OperationKind.updated) &&
  //             event.value != null) {
  //           final members = await getMembers?.call(event.value!.id);

  //           event.value!.members.addAll(members ?? []);
  //         }

  //         return event;
  //       });
  // }
}

extension _ChatDb on Chat {
  static Chat fromDb(ChatRow e) {
    return Chat(
      id: ChatId(e.id),
      name: ChatName(e.name),
      createdAt: e.createdAt,
    );
  }

  ChatRow toDb() {
    return ChatRow(
      id: id.val,
      name: name.val,
      createdAt: createdAt,
    );
  }
}
