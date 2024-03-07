// ignore_for_file: avoid_print

import 'package:Goala/model/user.dart';

class FeedModel {
  late bool isGroupGoal;
  late bool isHabit;
  late bool isCheckedIn;
  late bool isPrivate;
  String? grandparentKey;
  String? key;
  String? parentkey;
  String? childRetwetkey;
  String? parentName;
  String? title;
  String? description;
  late String userId;
  int? likeCount;
  List<String>? likeList;
  int? commentCount;
  int? retweetCount;
  int? memberCount;
  int? GoalSum;
  int? GoalAchieved;
  late String createdAt;
  String? deadlineDate;
  String? imagePath;
  List<String>? tags;
  List<String?>? goalPhotoList;
  List<String>? memberList;
  List<String?>? replyTweetKeyList;
  List<bool>? checkInList;
  String? lanCode; //Saving the language of the tweet so to not translate to check which language
  UserModel? user;
  FeedModel(
      {required this.isGroupGoal,
        required this.isCheckedIn,
        required this.isPrivate,
        required this.isHabit,
        this.grandparentKey,
        this.key,
        this.parentName,
        this.title,
        this.description,
        required this.userId,
        this.likeCount,
        this.commentCount,
        this.retweetCount,
        this.memberCount,
        this.GoalAchieved,
        this.GoalSum,
        required this.createdAt,
        this.deadlineDate,
        this.imagePath,
        this.likeList,
        this.tags,
        this.goalPhotoList,
        this.memberList,
        this.checkInList,
        this.user,
        this.replyTweetKeyList,
        this.parentkey,
        this.lanCode,
        this.childRetwetkey});
  toJson() {
    return {
      "isGroupGoal": isGroupGoal,
      "isCheckedIn": isCheckedIn,
      "isPrivate": isPrivate,
      "isHabit": isHabit,
      "grandparentKey": grandparentKey,
      "userId": userId,
      "title": title,
      "GoalSum": GoalSum,
      "description": description,
      "likeCount": likeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "memberCount": memberCount ?? 0,
      "GoalAchieved": GoalAchieved ?? 0,
      "createdAt": createdAt,
      "deadlineDate": deadlineDate,
      "imagePath": imagePath,
      "likeList": likeList,
      "tags": tags,
      "goalPhotoList": goalPhotoList,
      "memberList": memberList,
      "replyTweetKeyList": replyTweetKeyList,
      "checkInList": checkInList,
      "user": user == null ? null : user!.toJson(),
      "parentkey": parentkey,
      "parentName" : parentName,
      "lanCode": lanCode,
      "childRetwetkey": childRetwetkey
    };
  }

  FeedModel.fromJson(Map<dynamic, dynamic> map) {
    isGroupGoal = map['isGroupGoal'];
    isCheckedIn = map['isCheckedIn'];
    isPrivate = map['isPrivate'];
    isHabit = map['isHabit'];
    key = map['key'];
    grandparentKey = map['grandparentKey'];
    title = map['title'];
    description = map['description'];
    userId = map['userId'];
    likeCount = map['likeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    memberCount = map["memberCount"] ?? 0;
    GoalAchieved = map["GoalAchieved"] ?? 0;
    GoalSum = map["GoalSum"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    deadlineDate = map['deadlineDate'];
    imagePath = map['imagePath'];
    lanCode = map['lanCode'];
    user = UserModel.fromJson(map['user']);
    parentkey = map['parentkey'];
    parentName = map['parentName'];
    childRetwetkey = map['childRetwetkey'];
    if (map['checkInList'] != null) {
      checkInList = <bool>[];
      map['checkInList'].forEach((value) {
        checkInList!.add(value);
      });
    }
    if (map['tags'] != null) {
      tags = <String>[];
      map['tags'].forEach((value) {
        tags!.add(value);
      });
    }
    if (map['goalPhotoList'] != null) {
      goalPhotoList = <String>[];
      map['goalPhotoList'].forEach((value) {
        goalPhotoList!.add(value);
      });
    }
    if (map["likeList"] != null) {
      likeList = <String>[];

      final list = map['likeList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['likeList'].forEach((value) {
          if (value is String) {
            likeList!.add(value);
          }
        });
        likeCount = likeList!.length;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          likeList!.add(value["userId"]);
        });
        likeCount = list.length;
      }
    } else {
      likeList = [];
      likeCount = 0;
    }

    if (map["memberList"] != null) {
      memberList = <String>[];

      final list = map['memberList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['memberList'].forEach((value) {
          if (value is String) {
            memberList!.add(value);
          }
        });
        memberCount = memberList!.length;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          memberList!.add(value["userId"]);
        });
        memberCount = list.length;
      }
    } else {
      memberList = [];
      memberCount = 0;
    }
    if (map['replyTweetKeyList'] != null) {
      map['replyTweetKeyList'].forEach((value) {
        replyTweetKeyList = <String>[];
        map['replyTweetKeyList'].forEach((value) {
          replyTweetKeyList!.add(value);
        });
      });
      commentCount = replyTweetKeyList!.length;
    } else {
      replyTweetKeyList = [];
      commentCount = 0;
    }
  }



  bool get isValidTweet {
    bool isValid = false;
    if (user != null && user!.userName != null && user!.userName!.isNotEmpty) {
      isValid = true;
    } else {
      print("Invalid Tweet found. Id:- $key");
    }
    return isValid;
  }

  /// get tweet key to retweet.
  ///
  /// If tweet [TweetType] is [TweetType.Retweet] and its description is null
  /// then its retweeted child tweet will be shared.
  String get getTweetKeyToRetweet {
    if (description == null && imagePath == null && childRetwetkey != null) {
      return childRetwetkey!;
    } else {
      return key!;
    }
  }
}
