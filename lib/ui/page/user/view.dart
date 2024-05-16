import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/ui/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'widget/single_field.dart';

class UserView extends StatelessWidget {
  const UserView(this.id, {super.key});

  final UserId id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UserController(id, Get.find()),
      builder: (UserController c) {
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

              final User user = c.user!.user.value;

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
                        child: AvatarWidget(user.avatar),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('ID'),
                    subtitle: Text('${user.id}'),
                  ),
                  ListTile(
                    title: const Text('Num'),
                    subtitle: Text('${user.num}'),
                  ),
                  ListTile(
                    title: const Text('Name'),
                    subtitle: Text('${user.name}'),
                  ),
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
