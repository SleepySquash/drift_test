import 'package:drift_test/domain/model/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class ChatView extends StatelessWidget {
  const ChatView(this.id, {super.key});

  final ChatId id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ChatController(id, Get.find()),
      builder: (ChatController c) {
        return Container();
      },
    );
  }
}
