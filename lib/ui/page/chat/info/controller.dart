import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:get/get.dart';

class ChatInfoController extends GetxController {
  ChatInfoController(this.id, this._chatRepository, this._userRepository);

  final ChatId id;
  final Rx<RxStatus> status = Rx(RxStatus.empty());
  RxChat? chat;

  final AbstractChatRepository _chatRepository;
  final AbstractUserRepository _userRepository;

  @override
  void onInit() {
    _fetchChat();
    super.onInit();
  }

  Future<void> updateAvatar(String url) async {
    await chat?.updateAvatar(url);
  }

  Future<void> delete() async {
    await _chatRepository.delete(id);
  }

  Future<void> addMember() async {
    final user = await _userRepository.create(User.random());
    await chat?.addMember(user);
  }

  Future<void> removeMember(RxChatMember member) async {
    await chat?.deleteMember(member.user.id);
  }

  Future<void> _fetchChat() async {
    status.value = RxStatus.loading();

    try {
      chat = await _chatRepository.get(id);
      status.value = RxStatus.success();
    } catch (e) {
      status.value = RxStatus.error(e.toString());
      rethrow;
    }
  }
}
