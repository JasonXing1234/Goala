
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
