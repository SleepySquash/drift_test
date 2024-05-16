import 'package:drift_test/util/new_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'chat_item.dart';
import 'chat_member.dart';
import 'chat.dart';
import 'user.dart';

part 'chat_call.g.dart';

@JsonSerializable()
class ChatCall extends ChatItem {
  ChatCall(
    super.id,
    super.chatId,
    super.authorId,
    super.at, {
    super.status,
    required this.members,
    required this.withVideo,
    this.conversationStartedAt,
    this.finishReasonIndex,
    this.finishedAt,
    this.joinLink,
    this.dialed,
  });

  final bool withVideo;
  List<ChatCallMember> members;
  ChatCallRoomJoinLink? joinLink;
  DateTime? conversationStartedAt;
  DateTime? finishedAt;
  int? finishReasonIndex;
  ChatMembersDialed? dialed;

  factory ChatCall.fromJson(Map<String, dynamic> json) =>
      _$ChatCallFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChatCallToJson(this)..['runtimeType'] = 'ChatCall';
}

@JsonSerializable()
class ChatCallMember {
  ChatCallMember({
    required this.user,
    required this.handRaised,
    required this.joinedAt,
  });

  final User user;
  bool handRaised;
  final DateTime joinedAt;

  factory ChatCallMember.fromJson(Map<String, dynamic> json) =>
      _$ChatCallMemberFromJson(json);
  Map<String, dynamic> toJson() => _$ChatCallMemberToJson(this);
}

@JsonSerializable()
class ChatCallRoomJoinLink extends NewType<String> {
  const ChatCallRoomJoinLink(super.val);

  factory ChatCallRoomJoinLink.fromJson(Map<String, dynamic> json) =>
      _$ChatCallRoomJoinLinkFromJson(json);
  Map<String, dynamic> toJson() => _$ChatCallRoomJoinLinkToJson(this);
}

abstract class ChatMembersDialed {
  const ChatMembersDialed();

  factory ChatMembersDialed.fromJson(Map<String, dynamic> json) =>
      switch (json['runtimeType']) {
        'ChatMembersDialedAll' => ChatMembersDialedAll.fromJson(json),
        'ChatMembersDialedConcrete' => ChatMembersDialedConcrete.fromJson(json),
        _ => throw UnimplementedError(json['runtimeType'])
      };

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (ChatMembersDialedAll) => (this as ChatMembersDialedAll).toJson()
          ..['runtimeType'] = 'ChatMembersDialedAll',
        const (ChatMembersDialedConcrete) =>
          (this as ChatMembersDialedConcrete).toJson()
            ..['runtimeType'] = 'ChatMembersDialedConcrete',
        _ => throw UnimplementedError(runtimeType.toString()),
      };
}

@JsonSerializable()
class ChatMembersDialedAll implements ChatMembersDialed {
  const ChatMembersDialedAll(this.answeredMembers);
  final List<ChatMember> answeredMembers;

  factory ChatMembersDialedAll.fromJson(Map<String, dynamic> json) =>
      _$ChatMembersDialedAllFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMembersDialedAllToJson(this);
}

@JsonSerializable()
class ChatMembersDialedConcrete implements ChatMembersDialed {
  const ChatMembersDialedConcrete(this.members);
  final List<ChatMember> members;

  factory ChatMembersDialedConcrete.fromJson(Map<String, dynamic> json) =>
      _$ChatMembersDialedConcreteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMembersDialedConcreteToJson(this);
}
