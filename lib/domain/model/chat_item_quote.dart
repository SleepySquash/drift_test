// Copyright © 2022-2024 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import 'package:json_annotation/json_annotation.dart';

import 'attachment.dart';
import 'chat_info.dart';
import 'chat_item.dart';
import 'user.dart';

part 'chat_item_quote.g.dart';

abstract class ChatItemQuote {
  const ChatItemQuote({
    this.original,
    required this.author,
    required this.at,
  });

  final ChatItem? original;
  final UserId author;
  final DateTime at;

  factory ChatItemQuote.fromJson(Map<String, dynamic> json) =>
      switch (json['runtimeType']) {
        'ChatMessageQuote' => ChatMessageQuote.fromJson(json),
        'ChatCallQuote' => ChatCallQuote.fromJson(json),
        'ChatInfoQuote' => ChatInfoQuote.fromJson(json),
        _ => throw UnimplementedError(json['runtimeType'])
      };

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (ChatMessageQuote) => (this as ChatMessageQuote).toJson()
          ..['runtimeType'] = 'ChatMessageQuote',
        const (ChatCallQuote) => (this as ChatCallQuote).toJson()
          ..['runtimeType'] = 'ChatCallQuote',
        const (ChatInfoQuote) => (this as ChatInfoQuote).toJson()
          ..['runtimeType'] = 'ChatInfoQuote',
        _ => throw UnimplementedError(runtimeType.toString()),
      };
}

@JsonSerializable()
class ChatMessageQuote extends ChatItemQuote {
  ChatMessageQuote({
    super.original,
    required super.author,
    required super.at,
    this.text,
    this.attachments = const [],
  });

  final String? text;
  final List<Attachment> attachments;

  factory ChatMessageQuote.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageQuoteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMessageQuoteToJson(this);
}

@JsonSerializable()
class ChatCallQuote extends ChatItemQuote {
  ChatCallQuote({
    super.original,
    required super.author,
    required super.at,
  });

  factory ChatCallQuote.fromJson(Map<String, dynamic> json) =>
      _$ChatCallQuoteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatCallQuoteToJson(this);
}

@JsonSerializable()
class ChatInfoQuote extends ChatItemQuote {
  ChatInfoQuote({
    super.original,
    required super.author,
    required super.at,
    required this.action,
  });

  final ChatInfoAction? action;

  factory ChatInfoQuote.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoQuoteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatInfoQuoteToJson(this);
}
