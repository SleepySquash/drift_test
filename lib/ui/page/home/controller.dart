import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/auth.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:get/get.dart';

enum HomeTab { users, chats, me }

class HomeController extends GetxController {
  HomeController(
    this._userRepository,
    this._chatRepository,
    this._authRepository,
  );

  final Rx<HomeTab> tab = Rx(HomeTab.chats);

  final AbstractUserRepository _userRepository;
  final AbstractChatRepository _chatRepository;
  final AbstractAuthRepository _authRepository;

  RxMap<UserId, RxUser> get users => _userRepository.users;
  RxMap<ChatId, RxChat> get chats => _chatRepository.chats;
  Rx<UserId?> get me => _authRepository.me;

  Future<void> authorize() async {
    final user = await _userRepository.create(User.random());
    _authRepository.set(user.id);
  }

  Future<void> createUser() async {
    await _userRepository.create(User.random());
  }

  Future<void> deleteUser(UserId id) async {
    await _userRepository.delete(id);
  }

  Future<void> createChat() async {
    await _chatRepository.create(Chat.random());
  }

  Future<void> deleteChat(ChatId id) async {
    await _chatRepository.delete(id);
  }
}
