import 'package:drift_test/domain/model/user.dart';
import 'package:get/get.dart';

abstract class AbstractAuthRepository {
  Rx<UserId?> get me;

  Future<void> init();
  Future<void> set(UserId? id);
}
