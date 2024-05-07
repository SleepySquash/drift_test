import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_message.dart';
import 'package:drift_test/domain/repository/auth.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  ChatController(
    this.id,
    this._chatRepository,
    this._authRepository,
  );

  final ChatId id;
  final Rx<RxStatus> status = Rx(RxStatus.empty());
  RxChat? chat;

  final TextEditingController message = TextEditingController();
  final FocusNode focus = FocusNode();

  final AbstractChatRepository _chatRepository;
  final AbstractAuthRepository _authRepository;

  @override
  void onInit() {
    _fetchChat();
    super.onInit();
  }

  Future<void> updateAvatar(String url) async {
    await chat?.updateAvatar(url);
  }

  Future<void> delete() async {
    await _chatRepository.delete(id);
  }

  Future<void> postMessage() async {
    if (message.text.isEmpty) {
      return;
    }

    await _chatRepository.postMessage(
      ChatMessage(
        ChatItemId.random(),
        id,
        _authRepository.me.value!,
        DateTime.now(),
        text: message.text,
      ),
    );

    message.clear();
  }

  Future<void> _fetchChat() async {
    status.value = RxStatus.loading();

    try {
      chat = await _chatRepository.get(id);
      status.value = RxStatus.loadingMore();
      await chat?.around();
      status.value = RxStatus.success();
    } catch (e) {
      status.value = RxStatus.error(e.toString());
      rethrow;
    }
  }
}
