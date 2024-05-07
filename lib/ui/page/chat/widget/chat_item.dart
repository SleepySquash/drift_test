import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_message.dart';
import 'package:flutter/material.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget(this.item, {super.key});

  final ChatItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.runtimeType) {
      const (ChatMessage) => _message(context, item as ChatMessage),
      (_) => const Text('Unsupported'),
    };
  }

  Widget _message(BuildContext context, ChatMessage item) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue,
        ),
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(1),
        child: Text(
          '${item.text}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
