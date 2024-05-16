import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/ui/page/chat/view.dart';
import 'package:drift_test/ui/page/user/view.dart';
import 'package:drift_test/ui/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomeController(Get.find(), Get.find(), Get.find()),
      builder: (HomeController c) {
        return Obx(() {
          return Scaffold(
            body: [
              _users(context, c),
              _chats(context, c),
              _me(context, c),
            ].elementAt(c.tab.value.index),
            bottomNavigationBar: BottomNavigationBar(
              items: HomeTab.values.map((e) {
                return switch (e) {
                  HomeTab.chats => BottomNavigationBarItem(
                      icon: const Icon(Icons.chat),
                      label: e.name,
                    ),
                  HomeTab.users => BottomNavigationBarItem(
                      icon: const Icon(Icons.people),
                      label: e.name,
                    ),
                  HomeTab.me => BottomNavigationBarItem(
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
              return Obx(() {
                final User user = e.user.value;

                return ListTile(
                  title: Text(user.title),
                  subtitle: Text('${user.createdAt}'),
                  leading: SizedBox.square(
                    dimension: 36,
                    child: AvatarWidget(user.avatar),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => c.deleteUser(e.id),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserView(e.id)),
                  ),
                );
              });
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
                      subtitle: Text('${e.chat.value.createdAt}'),
                      leading: SizedBox.square(
                        dimension: 36,
                        child: AvatarWidget(e.chat.value.avatar),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => c.deleteChat(e.id),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatView(e.id)),
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

  Widget _me(BuildContext context, HomeController c) {
    return Scaffold(
      body: Obx(() {
        if (c.me.value == null) {
          return Center(
            child: ElevatedButton(
              onPressed: c.authorize,
              child: const Text('Authorize'),
            ),
          );
        }

        return Center(child: Text('${c.me.value}'));
      }),
    );
  }
}
