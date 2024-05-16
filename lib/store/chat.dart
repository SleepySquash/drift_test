import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/chat_item.dart';
import 'package:drift_test/domain/model/chat_message.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/chat_item.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:drift_test/store/chat_rx.dart';
import 'package:drift_test/store/user.dart';
import 'package:drift_test/util/diff.dart';
import 'package:get/get.dart';
import 'package:log_me/log_me.dart';
import 'package:mutex/mutex.dart';

import '/domain/repository/chat.dart';

class ChatRepository extends DisposableInterface
    implements AbstractChatRepository {
  ChatRepository(
    this._userRepository,
    this.chatDrift,
    this.membersDrift,
    this.itemDrift,
  );

  @override
  final RxMap<ChatId, RxChatImpl> chats = RxMap();

  final ChatDriftProvider chatDrift;
  final ChatMemberDriftProvider membersDrift;
  final ChatItemDriftProvider itemDrift;

  final UserRepository _userRepository;

  StreamSubscription? _subscription;

  final Map<ChatId, Mutex> _guards = {};

  @override
  void onInit() {
    _subscription ??= chatDrift.watch().listen((e) {
      Log.debug('_provider.watch(${e.map((e) => e.op)})', '$runtimeType');

      for (var o in e) {
        switch (o.op) {
          case OperationKind.added:
          case OperationKind.updated:
            final RxChatImpl? rxChat = chats[o.key];
            if (rxChat == null) {
              put(o.value!);
            } else {
              rxChat.chat.value = o.value!;
            }
            break;

          case OperationKind.removed:
            onChatDeleted(o.key!);
            break;
        }
      }
    });

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
        final Chat? local = await chatDrift.chat(id);

        if (local != null) {
          return chats[id] = RxChatImpl(local, this)..init();
        }

        // Fetch from backend here....
      }

      return chat;
    });
  }

  @override
  Future<void> create(Chat chat) async {
    Log.debug('create($chat)', '$runtimeType');

    await chatDrift.create(chat);
  }

  @override
  Future<void> delete(ChatId id) async {
    Log.debug('delete($id)', '$runtimeType');

    await chatDrift.delete(id);
  }

  @override
  Future<void> postMessage(ChatMessage message) async {
    Log.debug('postMessage($message)', '$runtimeType');

    await itemDrift.create(message);
  }

  @override
  Future<void> deleteItem(ChatItemId itemId) async {
    Log.debug('deleteItem($itemId)', '$runtimeType');

    await itemDrift.delete(itemId);
  }

  Future<RxUser?> getUser(UserId id) async {
    return _userRepository.get(id);
  }

  void onChatDeleted(ChatId id) async {
    chats.remove(id)?.dispose();
  }

  RxChatImpl put(Chat chat) {
    RxChatImpl? rxChat = chats[chat.id];
    if (rxChat == null) {
      rxChat = RxChatImpl(chat, this)..init();
      chats[chat.id] = rxChat;
    }

    return rxChat;
  }
}
