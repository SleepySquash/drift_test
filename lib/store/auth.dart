import 'dart:async';

import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/auth.dart';
import 'package:drift_test/provider/drift/account.dart';
import 'package:get/get.dart';

class AuthRepository extends DisposableInterface
    implements AbstractAuthRepository {
  AuthRepository(this._accountDrift);

  @override
  final Rx<UserId?> me = Rx(null);

  final AccountDriftProvider _accountDrift;

  StreamSubscription? _subscription;

  @override
  Future<void> init() async {
    me.value = await _accountDrift.get();

    _subscription = _accountDrift.watch().listen((e) {
      me.value = e;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  @override
  Future<void> set(UserId? id) async {
    me.value = id;
    await _accountDrift.set(id);
  }
}
