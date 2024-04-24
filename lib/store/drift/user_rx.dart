import 'dart:async';

import 'package:drift_test/domain/model/chat.dart';
import 'package:drift_test/domain/model/user.dart';
import 'package:drift_test/provider/drift/chat.dart';
import 'package:drift_test/provider/drift/chat_member.dart';
import 'package:get/get.dart';

import '/util/diff.dart';

class RxUser {
  RxUser(User user) : user = Rx(user);

  final Rx<User> user;

  UserId get id => user.value.id;
}
