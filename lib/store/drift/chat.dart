import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:get/get.dart';

import '/domain/repository/chat.dart';

class ChatRepository extends DisposableInterface
    implements AbstractChatRepository {
  ChatRepository(this._provider);

  final ChatDriftProvider _provider;

  @override
  final RxList<Chat> chats = RxList();

  StreamSubscription? _subscription;

  @override
  void onInit() {
    _init();
    super.onInit();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  @override
  Future<void> create(Chat chat) async {
    await _provider.create(chat);
  }

  @override
  Future<void> delete(ChatId id) async {
    await _provider.delete(id);
  }

  Future<void> _init() async {
    _subscription = _provider.watch().listen((e) {
      chats.value = e;
      print('[watch] e: $e');
    });
  }
}
