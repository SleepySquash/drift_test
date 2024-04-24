import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/store/drift/user_rx.dart';
import 'package:get/get.dart';

abstract class AbstractUserRepository {
  RxMap<UserId, RxUser> get users;

  Future<User> getUser(UserId id);
  Future<void> create(User user);
  Future<void> delete(UserId id);
  Future<void> update(UserId id);
}
