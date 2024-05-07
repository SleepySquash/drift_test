import 'dart:async';

import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:drift_test/store/drift/user_rx.dart';
import 'package:drift_test/util/diff.dart';
import 'package:get/get.dart';
import 'package:log_me/log_me.dart';
import 'package:mutex/mutex.dart';

import '/domain/repository/user.dart';

class UserRepository extends DisposableInterface
    implements AbstractUserRepository {
  UserRepository(this.drift);

  // TODO: Pagination.
  @override
  final RxMap<UserId, RxUserImpl> users = RxMap();

  final UserDriftProvider drift;

  StreamSubscription? _subscription;

  final Map<UserId, Mutex> _guards = {};

  @override
  void onInit() {
    Log.debug('onInit()', '$runtimeType');

    _subscription ??= drift.watch().listen((e) {
      Log.debug('_provider.watch(${e.op})', '$runtimeType');

      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          final RxUserImpl? rxUser = users[e.key];
          if (rxUser == null) {
            put(e.value!);
          } else {
            rxUser.user.value = e.value!;
          }
          break;

        case OperationKind.removed:
          onUserDeleted(e.key!);
          break;
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    Log.debug('onClose()', '$runtimeType');

    _subscription?.cancel();

    super.onClose();
  }

  @override
  Future<RxUser?> get(UserId id) async {
    Log.debug('get($id)', '$runtimeType');

    RxUserImpl? user = users[id];
    if (user != null) {
      return user;
    }

    Mutex? mutex = _guards[id];
    if (mutex == null) {
      mutex = Mutex();
      _guards[id] = mutex;
    }

    return await mutex.protect(() async {
      user = users[id];

      if (user == null) {
        final User? local = await drift.user(id);

        if (local != null) {
          user = put(local);
        } else {
          // Fetch from backend here...
        }
      }

      return user;
    });
  }

  @override
  Future<RxUser> create(User user) async {
    Log.debug('create($user)', '$runtimeType');

    Mutex? mutex = _guards[user.id];
    if (mutex == null) {
      mutex = Mutex();
      _guards[user.id] = mutex;
    }

    return await mutex.protect(() async {
      final User local = await drift.create(user);
      return put(local);
    });
  }

  @override
  Future<void> delete(UserId id) async {
    Log.debug('delete($id)', '$runtimeType');
    await drift.delete(id);
  }

  @override
  Future<void> update(User user) async {
    Log.debug('update($user)', '$runtimeType');

    Mutex? mutex = _guards[user.id];
    if (mutex == null) {
      mutex = Mutex();
      _guards[user.id] = mutex;
    }

    return await mutex.protect(() async {
      await drift.update(user);

      RxUserImpl? rxUser = users[user.id];
      if (rxUser == null) {
        put(user);
      } else {
        rxUser.user.value = user;
      }
    });
  }

  void onUserDeleted(UserId id) async {
    users.remove(id)?.dispose();
  }

  RxUserImpl put(User user) {
    RxUserImpl? rxUser = users[user.id];
    if (rxUser == null) {
      rxUser = RxUserImpl(user, this)..init();
      users[user.id] = rxUser;
    }

    return rxUser;
  }
}
