import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

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
