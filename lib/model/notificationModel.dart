import 'dart:convert';

import 'package:Goala/model/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  String? id;
  String? tweetKey;
  String? updatedAt;
  String? createdAt;
  String? message;
  String? person;
  late String? type;
  Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    this.tweetKey,
    this.message,
    this.person,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    required this.data,
  });

  NotificationModel.fromJson(String tweetId, Map<dynamic, dynamic> map) {
    id = tweetId;
    Map<String, dynamic> data = {};
    if (map.containsKey('data')) {
      data = json.decode(json.encode(map["data"])) as Map<String, dynamic>;
    }
    tweetKey = map["tweetKey"];
    updatedAt = map["updatedAt"];
    type = map["type"];
    createdAt = map["createdAt"];
    person = map["person"];
    message = map["message"];
    this.data = data;
  }
}

extension NotificationModelHelper on NotificationModel {
  UserModel get user => UserModel.fromJson(data);

  DateTime? get timeStamp => updatedAt != null || createdAt != null
      ? DateTime.tryParse(updatedAt ?? createdAt!)
      : null;
}
