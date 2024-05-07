import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/repository/chat.dart';
import 'package:drift_test/ui/page/user/widget/single_field.dart';
import 'package:drift_test/ui/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class ChatInfoView extends StatelessWidget {
  const ChatInfoView(this.id, {super.key});

  final ChatId id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ChatInfoController(id, Get.find(), Get.find()),
      builder: (ChatInfoController c) {
        return SelectionArea(
          child: Scaffold(
            appBar: AppBar(),
            body: Obx(() {
              if (c.status.value.isLoading || c.status.value.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else if (c.status.value.isError) {
                return Center(
                  child: Text(c.status.value.errorMessage ?? 'Error'),
                );
              }

              final RxChat rxChat = c.chat!;
              final Chat chat = rxChat.chat.value;

              return ListView(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final url = await showDialog(
                          context: context,
                          builder: (context) {
                            return const SingleFieldWidget();
                          },
                        );

                        if (url is String) {
                          c.updateAvatar(url);
                        }
                      },
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: AvatarWidget(chat.avatar),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('ID'),
                    subtitle: Text('${chat.id}'),
                  ),
                  ListTile(
                    title: const Text('Name'),
                    subtitle: Text('${chat.name}'),
                  ),
                  ListTile(
                    title: const Text('Created at'),
                    subtitle: Text('${chat.createdAt}'),
                  ),
                  ListTile(
                    title: const Text('Members:'),
                    trailing: IconButton(
                      onPressed: c.addMember,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  ...rxChat.members.map((e) {
                    return ListTile(
                      leading: SizedBox.square(
                        dimension: 32,
                        child: AvatarWidget(e.user.user.value.avatar),
                      ),
                      title: Text(e.user.user.value.title),
                      subtitle: Text('Joined at ${e.joinedAt}'),
                      trailing: IconButton(
                        onPressed: () => c.removeMember(e),
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  }),
                  ListTile(
                    title: ElevatedButton(
                      onPressed: () {
                        c.delete();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
