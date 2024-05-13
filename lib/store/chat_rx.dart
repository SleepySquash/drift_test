import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_member.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/util/diff.dart';
import 'package:get/get.dart';

import 'chat.dart';
import 'paginated.dart';
import 'pagination/drift.dart';

class RxChatImpl extends RxChat {
  RxChatImpl(Chat chat, this._repository) : chat = Rx(chat);

  @override
  final Rx<Chat> chat;

  @override
  late final PaginatedImpl<UserId, RxChatMember> members = PaginatedImpl(
    provider: DriftPageProvider(
      fetch: ({after, before, required count}) {
        return const Stream.empty();
        // final result = await _repository.membersDrift.members(
        //   id,
        //   limit: count,
        //   biggerThan: after?.joinedAt,
        //   lessThan: before?.joinedAt,
        // );

        // final List<RxChatMember> members = [];

        // for (var e in result) {
        //   final RxUser? user = await _repository.getUser(e.user.id);
        //   if (user != null) {
        //     members.add(RxChatMember(user, e.joinedAt));
        //   }
        // }

        // return members;
      },
      add: (e) async => await _repository.membersDrift.create(
        id,
        e.toChatMember(),
      ),
      delete: (e) async => await _repository.membersDrift.delete(e.id),
      reset: () async => await _repository.membersDrift.clear(),
      onKey: (e) => e.id,
    ),
    compare: (a, b) => a.joinedAt.compareTo(b.joinedAt),
    onKey: (e) => e.id,
  );

  @override
  late final PaginatedImpl<ChatItemId, Rx<ChatItem>> items = PaginatedImpl(
    provider: DriftPageProvider(
      fetch: ({after, before, required count}) {
        // Must subscribe to the items fetched via `watch` somehow.
        // Must be able to delete items easily and identify those in the list.
        // Must be able to update/create items easily.

        // int offset = 0;

        // if (after != null) {
        //   final int? pos = items.items.keys.indexed
        //       .firstWhereOrNull((e) => e.$2 == after.value.id)
        //       ?.$1;

        //   if (pos != null) {
        //     offset = items.items.keys.length - pos;
        //   }
        // } else if (before != null) {
        //   final int? pos = items.items.keys.indexed
        //       .firstWhereOrNull((e) => e.$2 == before.value.id)
        //       ?.$1;

        //   if (pos != null) {
        //     offset = items.items.keys.length - pos;
        //   }
        // }

        final result = _repository.itemDrift.watch(
          id,
          limit: count,
          // offset: offset,
          biggerThan: after?.value.at,
          lessThan: before?.value.at,
        );

        return result.map((e) {
          return e.map((m) {
            return MapChangeNotification(
              m.key!,
              m.oldKey,
              m.value == null ? null : Rx(m.value!),
              m.op,
            );
          }).toList();
        });
      },
      add: (e) async => await _repository.itemDrift.create(e.value),
      delete: (e) async => await _repository.itemDrift.delete(e.value.id),
      reset: () async => await _repository.itemDrift.clear(),
      onKey: (e) => e.value.id,
    ),
    compare: (a, b) => a.value.at.compareTo(b.value.at),
    onKey: (e) => e.value.id,
  );

  final ChatRepository _repository;

  StreamSubscription? _itemsSubscription;
  StreamSubscription? _membersSubscription;

  Future<void> init() async {
    // Here may lay remote subscription...
  }

  void dispose() {
    _itemsSubscription?.cancel();
    _membersSubscription?.cancel();
    items.dispose();
    members.dispose();
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
}
