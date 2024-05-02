import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  ChatController(this.id, this._chatRepository);

  final ChatId id;
  final Rx<RxStatus> status = Rx(RxStatus.empty());
  RxChat? chat;

  final AbstractChatRepository _chatRepository;

  @override
  void onInit() {
    _fetchChat();
    super.onInit();
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
