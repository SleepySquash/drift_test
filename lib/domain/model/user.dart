import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '/generator/generator.dart';
import '/provider/drift/drift.dart';

part 'user.drift.g.dart';

@DriftType()
class User {
  const User({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory User.random() => User(
        id: UserId(const Uuid().v4()),
        name: UserName(
          'qwertyuiopasdfghjklzxcvbnm'.toUpperCase().split('').sample(1).first,
        ),
        createdAt: DateTime.now(),
      );

  final UserId id;
  final UserName name;
  final DateTime createdAt;
}

class UserId {
  const UserId(this.val);
  final String val;
}

class UserName {
  const UserName(this.val);
  final String val;
}
