import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'chat.dart';
import 'chat_call.dart';
import 'chat_forward.dart';
import 'chat_info.dart';
import 'chat_message.dart';
import 'user.dart';

part 'chat_item.g.dart';

enum SendingStatus {
  @JsonValue(0)
  sending,

  @JsonValue(1)
  sent,

  @JsonValue(2)
  error;

  static int toJson(Rx<SendingStatus> value) => value.value.index;
  // static SendingStatus fromJson(SendingStatus value) => value;
}

abstract class ChatItem {
  ChatItem(
    this.id,
    this.chatId,
    this.authorId,
    this.at, {
    SendingStatus? status,
  }) : status = Rx(status ?? (SendingStatus.sent));

  final ChatItemId id;
  final ChatId chatId;
  final UserId authorId;
  final DateTime at;

  @JsonKey(toJson: SendingStatus.toJson)
  final Rx<SendingStatus> status;

  factory ChatItem.fromJson(Map<String, dynamic> json) =>
      switch (json['runtimeType']) {
        'ChatMessage' => ChatMessage.fromJson(json),
        'ChatCall' => ChatCall.fromJson(json),
        'ChatInfo' => ChatInfo.fromJson(json),
        'ChatForward' => ChatForward.fromJson(json),
        _ => throw UnimplementedError(json['runtimeType'])
      };

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (ChatMessage) => (this as ChatMessage).toJson(),
        const (ChatCall) => (this as ChatCall).toJson(),
        const (ChatInfo) => (this as ChatInfo).toJson(),
        const (ChatForward) => (this as ChatForward).toJson(),
        _ => throw UnimplementedError(runtimeType.toString()),
      };
}

@JsonSerializable()
class ChatItemId {
  const ChatItemId(this.val);
  factory ChatItemId.fromJson(Map<String, dynamic> json) =>
      _$ChatItemIdFromJson(json);
  factory ChatItemId.random() => ChatItemId(const Uuid().v4());

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is ChatItemId && val == other.val;

  @override
  String toString() => val;

  Map<String, dynamic> toJson() => _$ChatItemIdToJson(this);
}
