import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/store/drift/chat_rx.dart';
import 'package:get/get.dart';

enum HomeTab { users, chats }

class HomeController extends GetxController {
  HomeController(
    this._userRepository,
    this._chatRepository,
  );

  final Rx<HomeTab> tab = Rx(HomeTab.users);

  final AbstractUserRepository _userRepository;

  final AbstractChatRepository _chatRepository;

  RxMap<UserId, User> get users => _userRepository.users;
  RxMap<ChatId, RxChat> get chats => _chatRepository.chats;

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

  Future<void> addMember(ChatId id) async {
    await _chatRepository.addMember(id);
  }

  Future<void> deleteMember(UserId id) async {
    await _chatRepository.deleteMember(id);
  }
}
