import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:drift_test/provider/drift/drift.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:drift_test/store/drift/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:log_me/log_me.dart';

import 'domain/repository/chat.dart';
import 'ui/page/home/view.dart';
import 'provider/drift/chat.dart';
import 'store/drift/chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Log.options = const LogOptions(level: LogLevel.all);

  final database = Get.put(DriftProvider());

  final userProvider = Get.put(UserDriftProvider(database));
  final chatMemberProvider =
      Get.put(ChatMemberDriftProvider(database, userProvider));
  final chatProvider = Get.put(ChatDriftProvider(database));

  final userRepository = UserRepository(userProvider);
  Get.put<AbstractUserRepository>(userRepository);
  Get.put<AbstractChatRepository>(
    ChatRepository(userRepository, chatProvider, chatMemberProvider),
  );

  chatMemberProvider.getUser = userRepository.get;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
