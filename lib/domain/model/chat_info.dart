import 'package:json_annotation/json_annotation.dart';

import 'chat.dart';
import 'chat_item.dart';
import 'user.dart';

part 'chat_info.g.dart';

@JsonSerializable()
class ChatInfo extends ChatItem {
  ChatInfo(
    super.id,
    super.chatId,
    super.authorId,
    super.at, {
    required this.action,
  });

  final ChatInfoAction action;

  factory ChatInfo.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChatInfoToJson(this)..['runtimeType'] = 'ChatInfo';
}

enum ChatInfoActionKind {
  @JsonValue(0)
  avatarUpdated,

  @JsonValue(1)
  created,

  @JsonValue(2)
  memberAdded,

  @JsonValue(3)
  memberRemoved,

  @JsonValue(4)
  nameUpdated,
}

abstract class ChatInfoAction {
  const ChatInfoAction();

  ChatInfoActionKind get kind;

  factory ChatInfoAction.fromJson(Map<String, dynamic> json) =>
      switch (json['runtimeType']) {
        'ChatInfoActionAvatarUpdated' =>
          ChatInfoActionAvatarUpdated.fromJson(json),
        'ChatInfoActionCreated' => ChatInfoActionCreated.fromJson(json),
        'ChatInfoActionMemberAdded' => ChatInfoActionMemberAdded.fromJson(json),
        'ChatInfoActionMemberRemoved' =>
          ChatInfoActionMemberRemoved.fromJson(json),
        'ChatInfoActionNameUpdated' => ChatInfoActionNameUpdated.fromJson(json),
        _ => throw UnimplementedError(json['runtimeType'])
      };

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (ChatInfoActionAvatarUpdated) =>
          (this as ChatInfoActionAvatarUpdated).toJson()
            ..['runtimeType'] = 'ChatInfoActionAvatarUpdated',
        const (ChatInfoActionCreated) =>
          (this as ChatInfoActionCreated).toJson()
            ..['runtimeType'] = 'ChatInfoActionCreated',
        const (ChatInfoActionMemberAdded) =>
          (this as ChatInfoActionMemberAdded).toJson()
            ..['runtimeType'] = 'ChatInfoQuote',
        const (ChatInfoActionMemberRemoved) =>
          (this as ChatInfoActionMemberRemoved).toJson()
            ..['runtimeType'] = 'ChatInfoActionMemberRemoved',
        const (ChatInfoActionNameUpdated) =>
          (this as ChatInfoActionNameUpdated).toJson()
            ..['runtimeType'] = 'ChatInfoActionNameUpdated',
        _ => throw UnimplementedError(runtimeType.toString()),
      };
}

@JsonSerializable()
class ChatInfoActionAvatarUpdated implements ChatInfoAction {
  const ChatInfoActionAvatarUpdated(this.avatar);

  final Avatar? avatar;

  @override
  ChatInfoActionKind get kind => ChatInfoActionKind.avatarUpdated;

  factory ChatInfoActionAvatarUpdated.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoActionAvatarUpdatedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatInfoActionAvatarUpdatedToJson(this);
}

@JsonSerializable()
class ChatInfoActionCreated implements ChatInfoAction {
  const ChatInfoActionCreated();

  @override
  ChatInfoActionKind get kind => ChatInfoActionKind.created;

  factory ChatInfoActionCreated.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoActionCreatedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatInfoActionCreatedToJson(this);
}

@JsonSerializable()
class ChatInfoActionMemberAdded implements ChatInfoAction {
  const ChatInfoActionMemberAdded(this.user);

  final User user;

  @override
  ChatInfoActionKind get kind => ChatInfoActionKind.memberAdded;

  factory ChatInfoActionMemberAdded.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoActionMemberAddedFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ChatInfoActionMemberAddedToJson(this);
}

@JsonSerializable()
class ChatInfoActionMemberRemoved implements ChatInfoAction {
  const ChatInfoActionMemberRemoved(this.user);

  final User user;

  @override
  ChatInfoActionKind get kind => ChatInfoActionKind.memberRemoved;

  factory ChatInfoActionMemberRemoved.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoActionMemberRemovedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatInfoActionMemberRemovedToJson(this);
}

@JsonSerializable()
class ChatInfoActionNameUpdated implements ChatInfoAction {
  const ChatInfoActionNameUpdated(this.name);

  final ChatName? name;

  @override
  ChatInfoActionKind get kind => ChatInfoActionKind.nameUpdated;

  factory ChatInfoActionNameUpdated.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoActionNameUpdatedFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatInfoActionNameUpdatedToJson(this);
}
