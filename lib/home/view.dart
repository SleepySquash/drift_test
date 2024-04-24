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
            ...c.users.values.map((e) {
              return ListTile(
                title: Text(e.user.value.name.val),
                subtitle: Text(e.id.val),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => c.updateUser(e.id),
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () => c.deleteUser(e.id),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
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
            ...c.chats.values.map((e) {
              return Obx(() {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(e.chat.value.name.val),
                      subtitle: Text(e.id.val),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => c.addMember(e.id),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: () => c.deleteChat(e.id),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                    ...e.members.map(
                      (e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(e.user.value.id.val),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(e.user.value.name.val),
                          ),
                          IconButton(
                            onPressed: () => c.deleteMember(e.user.value.id),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
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
