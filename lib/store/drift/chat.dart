import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:get/get.dart';

import '/domain/repository/chat.dart';
import '/util/diff.dart';

class ChatRepository extends DisposableInterface
    implements AbstractChatRepository {
  ChatRepository(this._provider);

  final ChatDriftProvider _provider;

  @override
  final RxMap<ChatId, Chat> chats = RxMap();

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
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          chats[e.key!] = e.value!;
          break;
        case OperationKind.removed:
          chats.remove(e.key);
      }
      print('[watch] e: ${e.op} ${e.key?.val}');
    });
  }
}
