import 'package:drift_test/domain/model/chat.dart';
import 'package:get/get.dart';

abstract class AbstractChatRepository {
  RxMap<ChatId, Chat> get chats;

  Future<void> create(Chat chat);
  Future<void> delete(ChatId id);
}
