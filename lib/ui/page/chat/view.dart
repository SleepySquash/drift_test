import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/ui/page/chat/info/view.dart';
import 'package:drift_test/ui/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'widget/chat_item.dart';

class ChatView extends StatelessWidget {
  const ChatView(this.id, {super.key});

  final ChatId id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ChatController(id, Get.find(), Get.find()),
      tag: id.val,
      builder: (ChatController c) {
        return Obx(() {
          if (c.status.value.isLoading || c.status.value.isEmpty) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (c.status.value.isError) {
            return Scaffold(
              body: Center(
                child: Text(c.status.value.errorMessage ?? 'Error'),
              ),
            );
          }

          final RxChat rxChat = c.chat!;
          final Chat chat = rxChat.chat.value;

          return Scaffold(
            appBar: AppBar(
              title: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChatInfoView(id)),
                ),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 36,
                      child: AvatarWidget(chat.avatar),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(chat.name.val)),
                  ],
                ),
              ),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView(
                    children: rxChat.items.map((e) {
                      return Obx(() {
                        return ChatItemWidget(e.value);
                      });
                    }).toList(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black12),
                        child: TextField(
                          controller: c.message,
                          focusNode: c.focus,
                          decoration: const InputDecoration(
                            hintText: 'Message...',
                          ),
                          onSubmitted: (_) async {
                            await c.postMessage();
                            c.focus.requestFocus();
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: c.postMessage,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
