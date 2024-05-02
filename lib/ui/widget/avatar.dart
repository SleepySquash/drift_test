import 'package:drift_test/domain/model/user.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget(this.avatar, {super.key});

  final Avatar? avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: avatar == null ? Colors.amber : null,
        image: avatar == null
            ? null
            : DecorationImage(
                image: NetworkImage(avatar!.url),
                fit: BoxFit.cover,
              ),
        shape: BoxShape.circle,
      ),
    );
  }
}
