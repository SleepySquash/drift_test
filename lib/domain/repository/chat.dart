import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/model/chat_message.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:get/get.dart';

import '/domain/model/chat.dart';
import 'pagination.dart';
import 'user.dart';

abstract class AbstractChatRepository {
  RxMap<ChatId, RxChat> get chats; // TODO: Use pagination.

  Future<RxChat?> get(ChatId id);
  Future<void> create(Chat chat);
  Future<void> delete(ChatId id);

  Future<void> postMessage(ChatMessage message);
  Future<void> deleteItem(ChatItemId itemId);
}

abstract class RxChat {
  Rx<Chat> get chat;

  Paginated<UserId, RxChatMember> get members;
  Paginated<ChatItemId, Rx<ChatItem>> get items;

  ChatId get id => chat.value.id;

  Future<void> addMember(RxUser user);
  Future<void> deleteMember(UserId id);

  Future<void> updateAvatar(String url);
}

class RxChatMember {
  const RxChatMember(this.user, this.joinedAt);

  final RxUser user;
  final DateTime joinedAt;

  UserId get id => user.id;

  ChatMember toChatMember() => ChatMember(
        user: user.user.value,
        joinedAt: joinedAt,
      );
}
