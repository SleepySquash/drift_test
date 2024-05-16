import 'package:drift_test/domain/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_member.g.dart';

@JsonSerializable()
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

  factory ChatMember.fromJson(Map<String, dynamic> json) =>
      _$ChatMemberFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMemberToJson(this);
}
