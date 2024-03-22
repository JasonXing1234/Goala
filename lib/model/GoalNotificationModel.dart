import 'package:firebase_messaging/firebase_messaging.dart';

class GoalNotiModel {
  String GoalID;
  String userID;
  int day;
  String notiTime;
  GoalNotiModel(this.userID, this.day, this.GoalID, this.notiTime);
  toJson() {
    return {
      "userID": userID,
      "day": day,
      "GoalID": GoalID,
      "notiTime": notiTime
    };
  }
}

Future<GoalNotiModel> createNotiModel(
  int day,
  String feedID,
  int hour,
  int minute,
) async {
  final _messaging = FirebaseMessaging.instance;
  String? tempToken = await _messaging.getToken();
  GoalNotiModel temp = GoalNotiModel(tempToken!, day, feedID, '$hour:$minute');
  return temp;
}
