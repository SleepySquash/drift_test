import 'package:collection/collection.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  Chat({
    required this.id,
    required this.name,
    this.avatar,
    required this.createdAt,
  });

  factory Chat.random() {
    final id = ChatId(const Uuid().v4());
    return Chat(
      id: id,
      name: ChatName(
        'qwertyuiopasdfghjklzxcvbnm'.toUpperCase().split('').sample(1).first,
      ),
      createdAt: DateTime.now(),
    );
  }

  final ChatId id;
  ChatName name;
  Avatar? avatar;
  final DateTime createdAt;

  @override
  int get hashCode => Object.hash(id, name, avatar, createdAt);

  @override
  bool operator ==(Object other) =>
      other is Chat &&
      id == other.id &&
      name == other.name &&
      avatar == other.avatar &&
      createdAt == other.createdAt;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}

@JsonSerializable()
class ChatId {
  const ChatId(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is ChatId && val == other.val;

  @override
  String toString() => val;

  factory ChatId.fromJson(Map<String, dynamic> json) => _$ChatIdFromJson(json);
  Map<String, dynamic> toJson() => _$ChatIdToJson(this);
}

@JsonSerializable()
class ChatName {
  const ChatName(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is ChatName && val == other.val;

  @override
  String toString() => val;

  factory ChatName.fromJson(Map<String, dynamic> json) =>
      _$ChatNameFromJson(json);
  Map<String, dynamic> toJson() => _$ChatNameToJson(this);
}
