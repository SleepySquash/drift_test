import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/store/drift/chat_rx.dart';
import 'package:get/get.dart';

abstract class AbstractChatRepository {
  RxMap<ChatId, RxChat> get chats;

  Future<void> create(Chat chat);

  Future<void> delete(ChatId id);

  Future<void> addMember(ChatId id);

  Future<void> deleteMember(UserId id);

  Future<List<ChatMember>> getMembers(ChatId id);
}
