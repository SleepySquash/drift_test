import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/util/diff.dart';

import '/domain/model/chat.dart';
import 'chat.dart';
import 'drift.dart';
import 'user.dart';

// Should we use relation tables at all? For example, chat messages get quite
// hard to maintain: we have 4 types of messages, so `SELECT` would contain
// four `UNION`s, and when querying chat messages, we must implement a separate
// table for attachments, which may also be different kinds, so we must `JOIN`
// those as well. This will create hard to maintain queries and complex
// database, which frontend might not require at all?
//
// Also whenever adding `ChatItem`s, we must ensure `chatId` and `userId`
// reference the existing in the appropriate table row, so the `User`/`Chat`
// exists.
//
// Should we instead look for NoSQL solution, that doesn't introduce the
// problems Hive used to have?
//
// Or perhaps we might abuse normalization and simply store JSONs in some
// scenarios to make the table more maintainable. And remove the FKs
// constraints, however that makes it our responsibility to update/delete data.

// Two ways:
// 1. Store JSONs in single `chat_item` table.
// 2. Use 5 tables: one for `chat_item` and 4 for types: `chat_message`, `chat_call`, `chat_forward` and `chat_info`.
// The first one is easier, let's try it for now.

@DataClassName('ChatItemRow')
class ChatItems extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get chatId => text().references(Chats, #id)();
  TextColumn get authorId => text().references(Users, #id)();
  DateTimeColumn get at => dateTime()();
  IntColumn get status => intEnum<SendingStatus>()();

  // JSON for ChatMessage/ChatCall/ChatInfo/ChatForward specific data???
  TextColumn get data => text()();
}

@DataClassName('ChatItemViewRow')
class ChatItemViews extends Table {
  @override
  Set<Column> get primaryKey => {chatId, chatItemId, at};

  TextColumn get chatId => text().references(Chats, #id)();
  TextColumn get chatItemId => text().references(ChatItems, #id)();
  DateTimeColumn get at => dateTime()();
}

class ChatItemDriftProvider {
  ChatItemDriftProvider(this._database);

  final DriftProvider _database;

  Future<List<ChatItem>> items(
    ChatId chatId, {
    int? limit,
    int? offset,
    DateTime? biggerThan,
    DateTime? lessThan,
  }) async {
    final stmt = _database.select(_database.chatItems);
    stmt.where((u) => u.chatId.equals(chatId.val));

    if (biggerThan != null) {
      stmt.where((u) => u.at.isBiggerThanValue(biggerThan));
    }

    if (lessThan != null) {
      stmt.where((u) => u.at.isSmallerThanValue(lessThan));
    }

    stmt.orderBy([(u) => OrderingTerm.desc(u.at)]);

    if (limit != null) {
      stmt.limit(limit, offset: offset);
    }

    final response = await stmt.get();
    return response.map(_ChatItemDb.fromDb).toList();
  }

  Future<void> create(ChatItem item) async {
    await _database.into(_database.chatItems).insert(item.toDb());
  }

  Future<void> update(ChatItem item) async {
    final stmt = _database.update(_database.chatItems);
    await stmt.replace(item.toDb());
  }

  Future<void> delete(ChatItemId id) async {
    final stmt = _database.delete(_database.chatItems)
      ..where((e) => e.id.equals(id.val));

    await stmt.go();
  }

  Future<void> clear() async {
    await _database.delete(_database.chatItems).go();
  }

  Stream<List<MapChangeNotification<ChatItemId, ChatItem>>> watch(
    ChatId chatId, {
    int? limit,
    int? offset,
    DateTime? biggerThan,
    DateTime? lessThan,
  }) {
    final stmt = _database.select(_database.chatItems);
    stmt.where((u) => u.chatId.equals(chatId.val));

    if (biggerThan != null) {
      stmt.where((u) => u.at.isBiggerThanValue(biggerThan));
    }

    if (lessThan != null) {
      stmt.where((u) => u.at.isSmallerThanValue(lessThan));
    }

    stmt.orderBy([(u) => OrderingTerm.desc(u.at)]);

    if (limit != null) {
      stmt.limit(limit, offset: offset);
    }

    print('[built] ${stmt.constructQuery().buffer.toString()}');

    return stmt
        .watch()
        .map((items) => {for (var e in items.map(_ChatItemDb.fromDb)) e.id: e})
        .changes();
  }

  Future<void> txn<T>(Future<T> Function() action) async {
    await _database.transaction(action);
  }
}

extension _ChatItemDb on ChatItem {
  static ChatItem fromDb(ChatItemRow e) {
    return ChatItem.fromJson(jsonDecode(e.data));
  }

  ChatItemRow toDb() {
    return ChatItemRow(
      id: id.val,
      chatId: chatId.val,
      authorId: authorId.val,
      at: at,
      status: status.value,
      data: jsonEncode(toJson()),
    );
  }
}

// @DataClassName('ChatMessageRow')
// class ChatMessages extends Table {
//   @override
//   Set<Column> get primaryKey => {id};

//   TextColumn get id => text()();

//   // should it be FK at all?
//   TextColumn get chatId => text().references(Chats, #id)();

//   // should it be FK at all?
//   TextColumn get authorId => text().references(Users, #id)();

//   DateTimeColumn get at => dateTime()();
//   IntColumn get status => intEnum<SendingStatus>()();
//   TextColumn get message => text().nullable()();
//   DateTimeColumn get editedAt => dateTime().nullable()();
// }

// @DataClassName('ChatCallRow')
// class ChatCalls extends Table {
//   @override
//   Set<Column> get primaryKey => {id};

//   TextColumn get id => text()();

//   // should it be FK at all?
//   TextColumn get chatId => text().references(Chats, #id)();

//   // should it be FK at all?
//   TextColumn get authorId => text().references(Users, #id)();

//   DateTimeColumn get at => dateTime()();
// }
