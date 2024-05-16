import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget(
    this.item, {
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final ChatItem item;
  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      contextMenu: ContextMenu(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        entries: [
          MenuItem(
            label: 'Edit',
            icon: Icons.edit,
            onSelected: onEdit,
          ),
          MenuItem(
            label: 'Delete',
            icon: Icons.delete,
            onSelected: onDelete,
          ),
        ],
      ),
      child: switch (item.runtimeType) {
        const (ChatMessage) => _message(context, item as ChatMessage),
        (_) => const Text('Unsupported'),
      },
    );
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                '${item.text}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              '${item.at.millisecondsSinceEpoch}',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}
