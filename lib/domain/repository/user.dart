import 'package:drift_test/domain/model/user.dart';
import 'package:get/get.dart';

abstract class AbstractUserRepository {
  RxMap<UserId, User> get users;

  Future<void> create(User user);
  Future<void> delete(UserId id);
}
