import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:drift_test/store/drift/chat_rx.dart';
import 'package:get/get.dart';

import '/domain/repository/chat.dart';
import '/util/diff.dart';

class ChatRepository extends DisposableInterface
    implements AbstractChatRepository {
  ChatRepository(this._provider, this._membersProvider);

  final ChatDriftProvider _provider;

  final ChatMemberDriftProvider _membersProvider;

  @override
  final RxMap<ChatId, RxChat> chats = RxMap();

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

  @override
  Future<void> addMember(ChatId id) async {
    await _membersProvider.create(ChatMember.random(id));
  }

  @override
  Future<void> deleteMember(UserId id) async {
    await _membersProvider.delete(id);
  }

  Future<void> _init() async {
    _subscription = _provider.watch().listen((e) {
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          if (chats.containsKey(e.key!)) {
            chats[e.key!]!.chat.value = e.value!;
          } else {
            chats[e.key!] = RxChat(e.value!, _provider, _membersProvider);
          }
          break;
        case OperationKind.removed:
          chats.remove(e.key);
      }
      print('[watch] e: ${e.op} ${e.key?.val}');
    });
  }
}
