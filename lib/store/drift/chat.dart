import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:drift_test/store/drift/chat_rx.dart';
import 'package:drift_test/store/drift/user.dart';
import 'package:get/get.dart';
import 'package:log_me/log_me.dart';
import 'package:mutex/mutex.dart';

import '/domain/repository/chat.dart';

class ChatRepository extends DisposableInterface
    implements AbstractChatRepository {
  ChatRepository(this._userRepository, this._provider, this._membersProvider);

  @override
  final RxMap<ChatId, RxChatImpl> chats = RxMap();

  final UserRepository _userRepository;

  final ChatDriftProvider _provider;

  final ChatMemberDriftProvider _membersProvider;

  StreamSubscription? _subscription;

  final Map<ChatId, Mutex> _guards = {};

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
  Future<RxChat?> get(ChatId id) async {
    Log.debug('get($id)', '$runtimeType');

    RxChatImpl? chat = chats[id];
    if (chat != null) {
      return chat;
    }

    Mutex? mutex = _guards[id];
    if (mutex == null) {
      mutex = Mutex();
      _guards[id] = mutex;
    }

    return await mutex.protect(() async {
      chat = chats[id];

      if (chat == null) {
        final Chat? local = await _provider.chat(id);

        if (local != null) {
          return chats[id] =
              RxChatImpl(local, this, _provider, _membersProvider)..init();
        }

        // Fetch from backend here....
      }

      return chat;
    });
  }

  @override
  Future<void> create(Chat chat) async {
    await _provider.create(chat);
  }

  @override
  Future<void> delete(ChatId id) async {
    await _provider.delete(id);
  }

  Future<RxUser?> getUser(UserId id) async {
    return _userRepository.get(id);
  }

  Future<void> _init() async {
    // _subscription = _provider.watch().listen((e) {
    //   switch (e.op) {
    //     case OperationKind.added:
    //     case OperationKind.updated:
    //       if (chats.containsKey(e.key!)) {
    //         chats[e.key!]!.chat.value = e.value!;
    //       } else {
    //         chats[e.key!] =
    //             RxChatImpl(e.value!, this, _provider, _membersProvider)..init();
    //       }
    //       break;

    //     case OperationKind.removed:
    //       chats.remove(e.key);
    //   }

    //   print('ChatRepository [watch] e: ${e.op} ${e.key?.val}');
    // });
  }
}
