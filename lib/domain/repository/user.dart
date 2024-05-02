import 'package:get/get.dart';

import '/domain/model/user.dart';

abstract class AbstractUserRepository {
  // TODO: Use pagination.
  RxMap<UserId, RxUser> get users;

  Future<RxUser?> get(UserId id);
  Future<RxUser> create(User user);
  Future<void> delete(UserId id);
  Future<void> update(User user);
}

abstract class RxUser {
  Rx<User> get user;
  UserId get id => user.value.id;

  Future<void> updateAvatar(String url);
}
