import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class User {
  User({
    required this.id,
    this.name,
    required this.num,
    this.avatar,
    required this.createdAt,
  });

  factory User.random() => User(
        id: UserId(const Uuid().v4()),
        num: UserNum(
          List.generate(16, (_) => '0123456789'.split('').sample(1).first)
              .join(),
        ),
        name: UserName(
          'qwertyuiopasdfghjklzxcvbnm'.toUpperCase().split('').sample(1).first,
        ),
        createdAt: DateTime.now(),
      );

  final UserId id;
  final UserNum num;
  UserName? name;
  Avatar? avatar;
  final DateTime createdAt;

  String get title => name?.val ?? num.val;

  @override
  int get hashCode => Object.hash(id, name, createdAt);

  @override
  bool operator ==(Object other) =>
      other is User &&
      id == other.id &&
      name == other.name &&
      avatar == other.avatar &&
      createdAt == other.createdAt;

  User copyWith({
    UserId? id,
    UserNum? num,
    UserName? name,
    Avatar? avatar,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      num: num ?? this.num,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'User(id: $id, num: $num, name: $name, avatar: $avatar, createdAt: $createdAt)';
}

class UserId {
  const UserId(this.val);
  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is UserId && val == other.val;

  @override
  String toString() => val;
}

class UserNum {
  const UserNum(this.val);
  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is UserNum && val == other.val;

  @override
  String toString() => val;
}

class UserName {
  const UserName(this.val);
  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is UserName && val == other.val;

  @override
  String toString() => val;
}

class Avatar {
  const Avatar(this.url);

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(json['url']);
  }

  final String url;

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(Object other) => other is Avatar && url == other.url;

  Map<String, dynamic> toJson() {
    return {'url': url};
  }

  @override
  String toString() => url;
}
