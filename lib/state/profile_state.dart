import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter/foundation.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:collection/collection.dart';
class ProfileState extends ChangeNotifier {
  ProfileState(this.profileId) {
    databaseInit();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _getloggedInUserProfile(userId);
    _getProfileUser(profileId);
  }

  /// This is the id of user who is logegd into the app.
  late String userId;

  /// Profile data of logged in user.
  late UserModel _userModel;
  UserModel get userModel => _userModel;

  dabase.Query? _profileQuery;
  late StreamSubscription<DatabaseEvent> profileSubscription;

  /// This is the id of user whose profile is open.
  final String profileId;

  /// Profile data of user whose profile is open.
  late UserModel _profileUserModel;
  UserModel get profileUserModel => _profileUserModel;

  bool _isBusy = true;
  bool get isbusy => _isBusy;
  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(profileId);
        profileSubscription = _profileQuery!.onValue.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  bool get isMyProfile => profileId == userId;

  /// Fetch profile of logged in  user
  void _getloggedInUserProfile(String userId) async {
    kDatabase.child("profile").child(userId).once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        var map = snapshot.value as Map<dynamic, dynamic>?;
        if (map != null) {
          _userModel = UserModel.fromJson(map);
        }
      }
    });
  }

  /*String? getProfilePic(String? userProfileId){
    return kDatabase
        .child("profile")
        .child(userProfileId!).child("profilePic").get() as String?;
  }
  String? getProfileUsername(String? userProfileId){
    return kDatabase
        .child("profile")
        .child(userProfileId!).child("disP").get() as String?;
  }*/
  /// Fetch profile data of user whoose profile is opened
  void _getProfileUser(String? userProfileId) {
    assert(userProfileId != null);
    try {
      loading = true;
      kDatabase
          .child("profile")
          .child(userProfileId!)
          .once()
          .then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map;
          // ignore: unnecessary_null_comparison
          if (map != null) {
            _profileUserModel = UserModel.fromJson(map);
            Utility.logEvent('get_profile', parameter: {});
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  followUser({bool removeFollower = false}) {
    /// `userModel` is user who is logged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    try {
      if (removeFollower) {
        /// If logged-in user `alredy follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUserModel.followersList!.remove(userModel.userId);

        /// Remove profile user from logged-in user's following list
        userModel.followingList!.remove(profileUserModel.userId);
        cprint('user removed from following list', event: 'remove_follow');
      } else {
        /// if logged in user is `not following` profile user then
        /// 1.Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        ///
        profileUserModel.followersList ??= [];
        profileUserModel.followersList!.add(userModel.userId!);
        // Adding profile user to logged-in user's following list
        userModel.followingList ??= [];
        addFollowNotification();
        userModel.followingList!.add(profileUserModel.userId!);
        profileUserModel.following = profileUserModel.followingList!.length;
        userModel.following = userModel.followingList!.length;
      }
      kDatabase
          .child('profile')
          .child(profileUserModel.userId!)
          .child('followerList')
          .set(profileUserModel.followersList);
      kDatabase
          .child('profile')
          .child(userModel.userId!)
          .child('followingList')
          .set(userModel.followingList);
      cprint('user added to following list', event: 'add_follow');

      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }
  acceptFriendRequest() {
    /// `userModel` is user who is logged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    try {

      addCloseness(profileId, 1);
      // update profile user's user follower count
      userModel.followingList ??= [];
      userModel.followingList!.add(profileUserModel.userId!);
      // update logged-in user's following count
      userModel.following = userModel.followingList!.length;
      kDatabase
          .child('profile')
          .child(userModel.userId!)
          .child('followingList')
          .set(userModel.followingList);
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }
  addFriend() {
    /// `userModel` is user who is logged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    try {

      // update profile user's user follower count
      userModel.followingList ??= [];
      userModel.followingList!.add(profileUserModel.userId!);
      // update logged-in user's following count
      userModel.following = userModel.followingList!.length;
      kDatabase
          .child('profile')
          .child(userModel.userId!)
          .child('followingList')
          .set(userModel.followingList);
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }
  addCloseness(String userI, int addition){
    if(userModel.closenessMap == null || profileUserModel.closenessMap == null){
      if(profileUserModel.closenessMap != null && profileUserModel.closenessMap?.firstWhereOrNull((element) =>
          element.contains(userId)) == null){
        List<String?> tempList = [];
        tempList.add(profileId + ' ' + 1.toString());
        kDatabase
            .child('profile')
            .child(userId)
            .update({
          'closenessMap': tempList,
        });
        cprint('user added to following list', event: 'add_follow');

        List<String?> tempList2 = profileUserModel.closenessMap!;
        String tempString2 = userId + ' ' + 1.toString();
        tempList2.add(tempString2);
        kDatabase
            .child('profile')
            .child(profileId)
            .update({
          'closenessMap': tempList2,
        });
        cprint('user added to following list', event: 'add_follow');
      }
      else if(userModel.closenessMap != null && userModel.closenessMap?.firstWhereOrNull((element) =>
          element.contains(profileId)) == null){
        List<String?> tempList = [];
        tempList.add(userId + ' ' + 1.toString());
        kDatabase
            .child('profile')
            .child(profileId)
            .update({
          'closenessMap': tempList,
        });
        cprint('user added to following list', event: 'add_follow');

        List<String?> tempList2 = userModel.closenessMap!;
        String tempString2 = profileId + ' ' + 1.toString();
        tempList2.add(tempString2);
        kDatabase
            .child('profile')
            .child(userId)
            .update({
          'closenessMap': tempList2,
        });
        cprint('user added to following list', event: 'add_follow');
      }
      else if(userModel.closenessMap == null || profileUserModel.closenessMap == null){
        List<String?> tempList = [];
        tempList.add(profileId + ' ' + 1.toString());
        kDatabase
            .child('profile')
            .child(userId)
            .update({
          'closenessMap': tempList,
        });
        cprint('user added to following list', event: 'add_follow');

        List<String?> tempList2 = [];
        tempList2.add(userId + ' ' + 1.toString());
        kDatabase
            .child('profile')
            .child(profileId)
            .update({
          'closenessMap': tempList2,
        });
        cprint('user added to following list', event: 'add_follow');
      }
    }
    else if (userModel.closenessMap?.firstWhereOrNull((element) =>
        element.contains(profileId)) == null || profileUserModel.closenessMap?.firstWhereOrNull((element) =>
        element.contains(userId)) == null){
      List<String?> tempList = userModel.closenessMap!;
      String tempString = profileId + ' ' + 1.toString();
      tempList.add(tempString);

      List<String?> tempList2 = profileUserModel.closenessMap!;
      String tempString2 = userId + ' ' + 1.toString();
      tempList2.add(tempString2);
      kDatabase
          .child('profile')
          .child(userModel.userId!)
          .update({
        'closenessMap': tempList,
      });
      cprint(
          'user added to following list', event: 'add_follow');
      kDatabase
          .child('profile')
          .child(profileId)
          .update({
        'closenessMap': tempList2,
      });
      cprint(
          'user added to following list', event: 'add_follow');
    }
    else {
      List<String?> tempList = userModel.closenessMap!;
      String tempString = userModel.closenessMap!
          .firstWhere((element) =>
          element.contains(profileId));
      int tempIndex = userModel.closenessMap!
          .indexWhere((element) =>
          element.contains(profileId));
      String uid = tempString.split(' ')[0];
      String closeness = tempString.split(' ')[1];
      closeness = (int.parse(closeness) + 1).toString();
      tempString = uid + ' ' + closeness;
      tempList[tempIndex] = tempString;

      List<String?> tempList2 = profileUserModel.closenessMap!;
      String tempString2 = profileUserModel.closenessMap!
          .firstWhere((element) =>
          element.contains(userId));
      int tempIndex2 = profileUserModel.closenessMap!
          .indexWhere((element) =>
          element.contains(userId));
      String uid2 = tempString2.split(' ')[0];
      String closeness2 = tempString2.split(' ')[1];
      closeness2 = (int.parse(closeness2) + 1).toString();
      tempString2 = uid2 + ' ' + closeness2;
      tempList2[tempIndex2] = tempString2;
      kDatabase
          .child('profile')
          .child(userModel.userId!)
          .update({
              'closenessMap': tempList,
      });
      cprint(
          'user added to following list', event: 'add_follow');
      kDatabase
          .child('profile')
          .child(profileId)
          .update({
            'closenessMap': tempList2,
      });
      cprint(
          'user added to following list', event: 'add_follow');
    }
  }

  void addFollowNotification() {
    // Sends notification to user who created tweet
    // UserModel owner can see notification on notification page
    kDatabase.child('notification').child(profileId).child(userId).set({
      'type': NotificationType.Follow.toString(),
      'createdAt': DateTime.now().toUtc().toString(),
      'data': UserModel(
              displayName: userModel.displayName,
              profilePic: userModel.profilePic,
              isVerified: userModel.isVerified,
              userId: userModel.userId,
              bio: userModel.bio == "Edit profile to update bio"
                  ? ""
                  : userModel.bio,
              userName: userModel.userName)
          .toJson()
    });
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(DatabaseEvent event) {
    final updatedUser = UserModel.fromJson(event.snapshot.value as Map);
    if (updatedUser.userId == profileId) {
      _profileUserModel = updatedUser;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _profileQuery!.onValue.drain();
    profileSubscription.cancel();
    super.dispose();
  }
}
