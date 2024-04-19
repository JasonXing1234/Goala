// ignore_for_file: avoid_print

import 'package:Goala/model/user.dart';

class FeedModel {
  late bool isGroupGoal;
  late bool isHabit;
  late bool isCheckedIn;
  late bool isPrivate;
  late bool isComment;
  String? grandparentKey;
  String? key;
  String? parentkey;
  String? childRetwetkey;
  String? parentName;
  String? title;
  String? goalUnit;
  String? description;
  late String userId;
  String? deviceToken;
  int? likeCount;
  List<String>? likeList;
  int? commentCount;
  int? retweetCount;
  int? memberCount;
  int? GoalSum;
  int? GoalAchieved;
  int? GoalAchievedToday;
  late String createdAt;
  int? currentDays;
  String? deadlineDate;
  String? imagePath;
  List<String>? tags;
  List<String?>? goalPhotoList;
  String? coverPhoto;
  List<String>? memberList;
  List<String?>? replyTweetKeyList;
  List<String>? visibleUsersList;
  List<bool>? checkInList;
  List<bool>? checkInListPost;
  String?
      lanCode; //Saving the language of the tweet so to not translate to check which language
  UserModel? user;
  FeedModel(
      {required this.isGroupGoal,
      required this.isCheckedIn,
      required this.isPrivate,
      required this.isHabit,
      required this.isComment,
      this.grandparentKey,
      this.key,
      this.coverPhoto,
      this.parentName,
      this.title,
      this.description,
      this.goalUnit,
      required this.userId,
      this.deviceToken,
      this.likeCount,
      this.commentCount,
      this.retweetCount,
      this.memberCount,
      this.GoalAchieved,
      this.GoalSum,
        this.GoalAchievedToday,
        this.currentDays,
      required this.createdAt,
      this.deadlineDate,
      this.imagePath,
      this.likeList,
      this.tags,
      this.goalPhotoList,
      this.memberList,
        this.visibleUsersList,
      this.checkInList,
        this.checkInListPost,
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
      "isComment": isComment,
      "grandparentKey": grandparentKey,
      "userId": userId,
      "deviceToken": deviceToken,
      "title": title,
      "GoalSum": GoalSum ?? 0,
      "GoalAchievedToday": GoalAchievedToday ?? 0,
      "description": description,
      "goalUnit": goalUnit,
      "likeCount": likeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "memberCount": memberCount ?? 0,
      "GoalAchieved": GoalAchieved,
      "currentDays":currentDays ?? 0,
      "createdAt": createdAt,
      "deadlineDate": deadlineDate,
      "imagePath": imagePath,
      "likeList": likeList,
      "tags": tags,
      "goalPhotoList": goalPhotoList,
      "coverPhoto": coverPhoto,
      "memberList": memberList,
      "visibleUsersList": visibleUsersList,
      "replyTweetKeyList": replyTweetKeyList,
      "checkInList": checkInList,
      "checkInListPost": checkInListPost,
      "user": user == null ? null : user!.toJson(),
      "parentkey": parentkey,
      "parentName": parentName,
      "lanCode": lanCode,
      "childRetwetkey": childRetwetkey
    };
  }

  FeedModel.fromJson(Map<dynamic, dynamic> map) {
    isGroupGoal = map['isGroupGoal'];
    isCheckedIn = map['isCheckedIn'];
    isPrivate = map['isPrivate'];
    isHabit = map['isHabit'];
    isComment = map['isComment'];
    key = map['key'];
    grandparentKey = map['grandparentKey'];
    title = map['title'];
    description = map['description'];
    goalUnit = map['goalUnit'];
    userId = map['userId'];
    deviceToken = map['deviceToken'];
    likeCount = map['likeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    memberCount = map["memberCount"] ?? 0;
    GoalAchieved = map["GoalAchieved"];
    GoalSum = map["GoalSum"];
    GoalAchievedToday = map["GoalAchievedToday"];
    currentDays = map["currentDays"];
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    deadlineDate = map['deadlineDate'];
    imagePath = map['imagePath'];
    lanCode = map['lanCode'];
    user = UserModel.fromJson(map['user']);
    parentkey = map['parentkey'];
    parentName = map['parentName'];
    childRetwetkey = map['childRetwetkey'];
    coverPhoto = map['coverPhoto'];
    if (map['checkInList'] != null) {
      checkInList = <bool>[];
      map['checkInList'].forEach((value) {
        checkInList!.add(value);
      });
    }
    if (map['checkInListPost'] != null) {
      checkInListPost = <bool>[];
      map['checkInListPost'].forEach((value) {
        checkInListPost!.add(value);
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

    if (map["visibleUsersList"] != null) {
      visibleUsersList = <String>[];

      final list = map['visibleUsersList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['visibleUsersList'].forEach((value) {
          if (value is String) {
            visibleUsersList!.add(value);
          }
        });
      }

    } else {
      visibleUsersList = [];
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
