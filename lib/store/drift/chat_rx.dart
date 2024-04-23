import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:get/get.dart';

import '/util/diff.dart';

class RxChat {
  RxChat(Chat chat, this._provider, this._membersProvider) : chat = Rx(chat);

  final ChatDriftProvider _provider;

  final ChatMemberDriftProvider _membersProvider;

  final Rx<Chat> chat;

  StreamSubscription? _subscription;

  ChatId get id => chat.value.id;

  void init() {
    _subscription = _membersProvider.watch(id).listen((e) {
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          final int i = chat.value.members
              .indexWhere((m) => m.user.id == e.value!.user.id);

          if (i == -1) {
            chat.value.members.add(e.value!);
          } else {
            chat.value.members[i] = e.value!;
          }

          chat.refresh();
          break;
        case OperationKind.removed:
          chat.value.members.removeWhere((m) => m.user.id == e.key);
          chat.refresh();
          break;
      }
      print('[watch] in rxChat e: ${e.op} ${e.key?.val}');
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> create(Chat chat) async {
    await _provider.create(chat);
  }

  Future<void> delete(ChatId id) async {
    await _provider.delete(id);
  }
}
