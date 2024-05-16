import 'package:json_annotation/json_annotation.dart';

import 'attachment.dart';
import 'chat_item.dart';
import 'chat_item_quote.dart';
import 'chat.dart';
import 'user.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage extends ChatItem {
  ChatMessage(
    super.id,
    super.chatId,
    super.authorId,
    super.at, {
    super.status,
    this.text,
    this.attachments = const [],
    this.repliesTo = const [],
  });

  final String? text;
  final List<ChatItemQuote> repliesTo;
  final List<Attachment> attachments;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChatMessageToJson(this)..['runtimeType'] = 'ChatMessage';

  @override
  String toString() => 'ChatMessage($text)';
}
