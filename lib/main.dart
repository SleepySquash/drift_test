import 'package:drift_test/domain/repository/user.dart';
import 'package:drift_test/provider/drift/drift.dart';
import 'package:drift_test/provider/drift/user.dart';
import 'package:drift_test/store/drift/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'domain/repository/chat.dart';
import 'home/view.dart';
import 'provider/drift/chat.dart';
import 'provider/drift/connection/connection.dart';
import 'store/drift/chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDatabase();
  final database = Get.put(DriftProvider());

  final userProvider = Get.put(UserDriftProvider(database));
  final chatProvider = Get.put(ChatDriftProvider(database));

  Get.put<AbstractUserRepository>(UserRepository(userProvider));
  Get.put<AbstractChatRepository>(ChatRepository(chatProvider));

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
