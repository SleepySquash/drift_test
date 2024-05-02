import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:get/get.dart';

import 'chat.dart';

class RxChatImpl extends RxChat {
  RxChatImpl(
    Chat chat,
    this._chatRepository,
    this._provider,
    this._membersProvider,
  ) : chat = Rx(chat);

  @override
  final Rx<Chat> chat;

  // @override
  // final RxList<RxChatMember> members = RxList();

  final ChatRepository _chatRepository;

  final ChatDriftProvider _provider;

  final ChatMemberDriftProvider _membersProvider;

  StreamSubscription? _subscription;

  Future<void> init() async {
    //   _subscription = _membersProvider.watch(id).listen((e) async {
    //     switch (e.op) {
    //       case OperationKind.added:
    //       case OperationKind.updated:
    //         final int i =
    //             members.indexWhere((m) => m.user.value.id == e.value!.user.id);

    //         final RxUser? user = await _chatRepository.getUser(e.value!.user.id);

    //         if (user != null) {
    //           if (i == -1) {
    //             members.add(user);
    //           } else {
    //             members[i] = user;
    //           }
    //         }
    //         break;

    //       case OperationKind.removed:
    //         members.removeWhere((m) => m.user.value.id == e.key);
    //         break;
    //     }

    //     print('RxChat [watch] e: ${e.op} ${e.key?.val}');
    //   });
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
