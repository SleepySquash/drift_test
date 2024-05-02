import 'package:get/get.dart';

import '/domain/model/chat.dart';
import 'user.dart';

abstract class AbstractChatRepository {
  RxMap<ChatId, RxChat> get chats; // TODO: Use pagination.

  Future<RxChat?> get(ChatId id);
  Future<void> create(Chat chat);
  Future<void> delete(ChatId id);
}

abstract class RxChat {
  Rx<Chat> get chat;

  // Paginated<RxChatMember> get members;

  ChatId get id => chat.value.id;

  // Future<List<ChatMember>> getMembers(ChatId id);
  // Future<void> addMember(ChatId id);
  // Future<void> deleteMember(UserId id);
}

abstract class RxChatMember {
  RxUser get user;
  DateTime get joinedAt;
}
