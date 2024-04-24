import 'dart:async';

import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:drift_test/store/drift/user_rx.dart';
import 'package:get/get.dart';

import '/domain/repository/user.dart';
import '/util/diff.dart';

class UserRepository extends DisposableInterface
    implements AbstractUserRepository {
  UserRepository(this._provider);

  final UserDriftProvider _provider;

  @override
  final RxMap<UserId, RxUser> users = RxMap();

  final Map<UserId, StreamSubscription> _subscriptions = {};

  @override
  void onClose() {
    for (var e in _subscriptions.values) {
      e.cancel();
    }
    super.onClose();
  }

  @override
  Future<User> getUser(UserId id) async {
    return (await getRxUser(id)).user.value;
  }

  @override
  Future<void> create(User user) async {
    await _provider.create(user);
  }

  @override
  Future<void> delete(UserId id) async {
    await _provider.delete(id);
  }

  @override
  Future<void> update(UserId id) async {
    final RxUser? user = users[id];

    if (user != null) {
      await _provider.update(user.user.value.copyWith(name: User.random().name));
    }
  }

  Future<RxUser> getRxUser(UserId id) async {
    if (users.containsKey(id)) {
      return users[id]!;
    } else {
      users[id] = RxUser(await _provider.user(id));
      watch(id);
      return users[id]!;
    }
  }

  void watch(UserId id) {
    _subscriptions[id] = _provider.watchSingle(id).listen((e) {
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          users[e.key!]?.user.value = e.value!;
          break;
        case OperationKind.removed:
          users.remove(e.key);
      }
      print(
        'UserRepository [watch] e: ${e.op} ${e.key?.val}, ${e.value?.name.val}',
      );
    });
  }
}
