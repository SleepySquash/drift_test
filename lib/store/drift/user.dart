import 'dart:async';

import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:get/get.dart';

import '/domain/repository/user.dart';
import '/util/diff.dart';

class UserRepository extends DisposableInterface
    implements AbstractUserRepository {
  UserRepository(this._provider);

  final UserDriftProvider _provider;

  @override
  final RxMap<UserId, User> users = RxMap();

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

  Future<User> get(UserId id) async {
    if(users.containsKey(id)) {
      return users[id]!;
    } else {
      return _provider.user(id);
    }
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
    final User? user = users[id];

    if (user != null) {
      await _provider.update(user.copyWith(name: User.random().name));
    }
  }

  Future<void> _init() async {
    _subscription = _provider.watch().listen((e) {
      switch (e.op) {
        case OperationKind.added:
        case OperationKind.updated:
          users[e.key!] = e.value!;
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
