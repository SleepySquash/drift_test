import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomeController(Get.find(), Get.find()),
      builder: (HomeController c) {
        return Obx(() {
          return Scaffold(
            body: [
              _users(context, c),
              _chats(context, c),
            ].elementAt(c.tab.value.index),
            bottomNavigationBar: BottomNavigationBar(
              items: HomeTab.values.map((e) {
                return switch (e) {
                  HomeTab.chats => BottomNavigationBarItem(
                      icon: const Icon(Icons.chat),
                      label: e.name,
                    ),
                  HomeTab.users => BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: e.name,
                    ),
                };
              }).toList(),
              currentIndex: c.tab.value.index,
              onTap: (i) => c.tab.value = HomeTab.values[i],
            ),
          );
        });
      },
    );
  }

  Widget _users(BuildContext context, HomeController c) {
    return Scaffold(
      body: Obx(() {
        return ListView(
          children: [
            ...c.users.map((e) {
              return ListTile(
                title: Text(e.name.val),
                subtitle: Text(e.id.val),
                trailing: IconButton(
                  onPressed: () => c.deleteUser(e.id),
                  icon: const Icon(Icons.delete),
                ),
              );
            }),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: c.createUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _chats(BuildContext context, HomeController c) {
    return Scaffold(
      body: Obx(() {
        return ListView(
          children: [
            ...c.chats.map((e) {
              return ListTile(
                title: Text(e.name.val),
                subtitle: Text(e.id.val),
                trailing: IconButton(
                  onPressed: () => c.deleteChat(e.id),
                  icon: const Icon(Icons.delete),
                ),
              );
            }),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: c.createChat,
        child: const Icon(Icons.add),
      ),
    );
  }
}
