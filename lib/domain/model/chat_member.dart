import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:uuid/uuid.dart';

class ChatMember {
  const ChatMember({
    required this.user,
    required this.chatId,
  });

  factory ChatMember.random(ChatId id) => ChatMember(
        user: User.random(),
        chatId: id,
      );

  final User user;
  final ChatId chatId;

  @override
  int get hashCode => Object.hash(user, chatId);

  @override
  bool operator ==(Object other) =>
      other is ChatMember && user == other.user && chatId == other.chatId;
}
