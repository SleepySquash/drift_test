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

  @override
  int get hashCode => Object.hash(id, name, createdAt);

  @override
  bool operator ==(Object other) =>
      other is User &&
      id == other.id &&
      name == other.name &&
      createdAt == other.createdAt;
}

class UserId {
  const UserId(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is UserId && val == other.val;
}

class UserName {
  const UserName(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is UserName && val == other.val;
}
