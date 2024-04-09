import 'dart:async';

import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:get/get.dart';

import '/domain/repository/user.dart';

class UserRepository extends DisposableInterface
    implements AbstractUserRepository {
  UserRepository(this._provider);

  final UserDriftProvider _provider;

  @override
  final RxList<User> users = RxList();

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
  Future<void> create(User user) async {
    await _provider.create(user);
  }

  @override
  Future<void> delete(UserId id) async {
    await _provider.delete(id);
  }

  Future<void> _init() async {
    _subscription = _provider.watch().listen((e) {
      users.value = e;
      print('[watch] e: $e');
    });
  }
}
