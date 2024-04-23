import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:uuid/uuid.dart';

class ChatMember {
  const ChatMember({
    required this.id,
    required this.chatId,
  });

  factory ChatMember.random(ChatId id) => ChatMember(
        id: UserId(const Uuid().v4()),
        chatId: id,
      );

  final UserId id;
  final ChatId chatId;

  @override
  int get hashCode => Object.hash(id, chatId);

  @override
  bool operator ==(Object other) =>
      other is ChatMember && id == other.id && chatId == other.chatId;
}
