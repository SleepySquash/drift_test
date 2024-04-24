import 'package:collection/collection.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:uuid/uuid.dart';

class Chat {
  const Chat({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.members,
  });

  factory Chat.random() {
    final id = ChatId(const Uuid().v4());
    return Chat(
      id: id,
      name: ChatName(
        'qwertyuiopasdfghjklzxcvbnm'.toUpperCase().split('').sample(1).first,
      ),
      createdAt: DateTime.now(),
      members: List.generate(5, (_) => ChatMember.random(id)),
    );
  }

  final ChatId id;
  final ChatName name;
  final DateTime createdAt;
  final List<ChatMember> members;

  @override
  int get hashCode => Object.hash(id, name, createdAt);

  @override
  bool operator ==(Object other) =>
      other is Chat &&
      id == other.id &&
      name == other.name &&
      createdAt == other.createdAt;
}

class ChatId {
  const ChatId(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is ChatId && val == other.val;
}

class ChatName {
  const ChatName(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is ChatName && val == other.val;
}
