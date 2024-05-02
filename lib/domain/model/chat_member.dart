import 'package:drift_test/domain/model/user.dart';

class ChatMember {
  const ChatMember({
    required this.user,
    required this.joinedAt,
  });

  factory ChatMember.random() => ChatMember(
        user: User.random(),
        joinedAt: DateTime.now(),
      );

  final User user;
  final DateTime joinedAt;

  @override
  int get hashCode => Object.hash(user, joinedAt);

  @override
  bool operator ==(Object other) =>
      other is ChatMember && user == other.user && joinedAt == other.joinedAt;
}
