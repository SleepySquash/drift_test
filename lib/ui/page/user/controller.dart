import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  UserController(this.id, this._userRepository);

  final UserId id;
  final Rx<RxStatus> status = Rx(RxStatus.empty());
  RxUser? user;

  final AbstractUserRepository _userRepository;

  @override
  void onInit() {
    _fetchUser();
    super.onInit();
  }

  Future<void> updateAvatar(String url) async {
    await user?.updateAvatar(url);
  }

  Future<void> delete() async {
    await _userRepository.delete(id);
  }

  Future<void> _fetchUser() async {
    status.value = RxStatus.loading();

    try {
      user = await _userRepository.get(id);
      status.value = RxStatus.success();
    } catch (e) {
      status.value = RxStatus.error(e.toString());
      rethrow;
    }
  }
}
