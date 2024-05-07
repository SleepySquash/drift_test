import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/util/diff.dart';
import 'package:get/get.dart';

import 'chat.dart';

class RxChatImpl extends RxChat {
  RxChatImpl(Chat chat, this._repository) : chat = Rx(chat);

  @override
  final Rx<Chat> chat;

  @override
  final RxList<RxChatMember> members = RxList();

  @override
  final RxList<Rx<ChatItem>> items = RxList();

  final ChatRepository _repository;

  StreamSubscription? _itemsSubscription;
  StreamSubscription? _membersSubscription;

  Future<void> init() async {}

  void dispose() {
    _itemsSubscription?.cancel();
    items.clear();
  }

  @override
  Future<void> addMember(RxUser user) async {
    await _repository.membersDrift.create(
      id,
      ChatMember(user: user.user.value, joinedAt: DateTime.now()),
    );
  }

  @override
  Future<void> deleteMember(UserId id) async {
    await _repository.membersDrift.delete(id);
  }

  @override
  Future<void> updateAvatar(String url) async {
    chat.update((v) => v?..avatar = url.isEmpty ? null : Avatar(url));

    await _repository.chatDrift.txn(() async {
      final Chat? stored = await _repository.chatDrift.chat(id);
      if (stored != null) {
        stored.avatar = url.isEmpty ? null : Avatar(url);
        await _repository.chatDrift.update(stored);
      }
    });
  }

  @override
  Future<void> around() async {
    _itemsSubscription?.cancel();
    _itemsSubscription = _repository.itemDrift.watch(id).listen((e) {
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          final item = items.where((p) => p.value.id == e.key);
          if (item.isEmpty) {
            items.add(Rx(e.value!));
          } else {
            for (var i in item) {
              i.value = e.value!;
            }
          }
          break;

        case OperationKind.removed:
          items.removeWhere((i) => i.value.id == e.key);
          break;
      }
    });

    _membersSubscription?.cancel();
    _membersSubscription = _repository.membersDrift.watch(id).listen((e) async {
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          final member = members.where((p) => p.user.id == e.key);
          if (member.isEmpty) {
            final user = await _repository.getUser(e.key!);
            if (user != null) {
              members.add(RxChatMember(user, e.value!.joinedAt));
            }
          }
          break;

        case OperationKind.removed:
          members.removeWhere((i) => i.user.id == e.key);
          break;
      }
    });
  }
}
