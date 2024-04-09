import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class Chat {
  const Chat({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Chat.random() => Chat(
        id: ChatId(const Uuid().v4()),
        name: ChatName(
          'qwertyuiopasdfghjklzxcvbnm'.toUpperCase().split('').sample(1).first,
        ),
        createdAt: DateTime.now(),
      );

  final ChatId id;
  final ChatName name;
  final DateTime createdAt;
}

class ChatId {
  const ChatId(this.val);

  final String val;
}

class ChatName {
  const ChatName(this.val);

  final String val;
}
