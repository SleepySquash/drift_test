import 'dart:async';

import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/store/drift/user.dart';
import 'package:get/get.dart';

class RxUserImpl extends RxUser {
  RxUserImpl(User user, this._repository) : user = Rx(user);

  @override
  final Rx<User> user;

  final UserRepository _repository;

  Future<void> init() async {}

  void dispose() {}

  @override
  Future<void> updateAvatar(String url) async {
    user.update((v) => v?..avatar = url.isEmpty ? null : Avatar(url));

    await _repository.drift.txn(() async {
      final User? stored = await _repository.drift.user(id);
      if (stored != null) {
        stored.avatar = url.isEmpty ? null : Avatar(url);
        await _repository.drift.update(stored);
      }
    });
  }
}
