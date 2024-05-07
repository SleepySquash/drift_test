import 'package:json_annotation/json_annotation.dart';

import 'chat_item_quote.dart';
import 'chat_item.dart';
import 'chat.dart';
import 'user.dart';

part 'chat_forward.g.dart';

@JsonSerializable()
class ChatForward extends ChatItem {
  ChatForward(
    super.id,
    super.chatId,
    super.authorId,
    super.at, {
    super.status,
    required this.quote,
  });

  final ChatItemQuote quote;

  factory ChatForward.fromJson(Map<String, dynamic> json) =>
      _$ChatForwardFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChatForwardToJson(this)..['runtimeType'] = 'ChatInfo';
}
