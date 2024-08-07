import 'package:firebase_database/firebase_database.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/user.dart';
import '../model/feedModel.dart';
import 'appState.dart';

class SearchState extends AppState {
  bool isBusy = false;
  SortUser sortBy = SortUser.MaxFollower;
  List<UserModel>? _userFilterList;
  List<UserModel>? _userlist;
  List<FeedModel>? _feedList;
  List<FeedModel>? groupFilterList;
  List<FeedModel>? _groupList;
  List<UserModel>? get userlist {
    if (_userFilterList == null) {
      return null;
    } else {
      return List.from(_userFilterList!);
    }
  }

  List<FeedModel>? get groupList {
    if (_groupList == null) {
      return null;
    } else {
      return List.from(groupFilterList!.reversed);
    }
  }

  List<FeedModel>? get feedList {
    if (_feedList == null) {
      return null;
    } else {
      return List.from(_feedList!.reversed);
    }
  }

  /// get [UserModel list] from firebase realtime Database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      kDatabase.child('profile').once().then(
        (DatabaseEvent event) {
          final snapshot = event.snapshot;
          _userlist = <UserModel>[];
          _userFilterList = <UserModel>[];
          if (snapshot.value != null) {
            var map = snapshot.value as Map?;
            if (map != null) {
              map.forEach((key, value) {
                var model = UserModel.fromJson(value);
                model.key = key;
                _userlist!.add(model);
                _userFilterList!.add(model);
              });
              _userFilterList!
                  .sort((x, y) => y.followers!.compareTo(x.followers!));
              notifyListeners();
            }
          } else {
            _userlist = null;
          }
          isBusy = false;
        },
      );
      kDatabase.child('tweet').once().then(
        (DatabaseEvent event) {
          final snapshot = event.snapshot;
          _groupList = <FeedModel>[];
          groupFilterList = <FeedModel>[];
          if (snapshot.value != null) {
            var map = snapshot.value as Map?;
            if (map != null) {
              map.forEach((key, value) {
                var model = FeedModel.fromJson(value);
                model.key = key;
                if (model.isGroupGoal) {
                  cprint('yes');
                  _groupList!.add(model);
                  groupFilterList!.add(model);
                }
              });
              //_userFilterList!.sort((x, y) => y.followers!.compareTo(x.followers!));
              notifyListeners();
            }
          } else {
            _groupList = null;
          }
          isBusy = false;
        },
      );
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// It will reset filter list
  /// If user has use search filter and change screen and came back to search screen It will reset user list.
  /// This function call when search page open.
  void resetFilterList() {
    if (_userlist != null && _userlist!.length != _userFilterList!.length) {
      _userFilterList = List.from(_userlist!);
      _userFilterList!.sort((x, y) => y.followers!.compareTo(x.followers!));
      // notifyListeners();
    }
  }

  void getClosestFriends() {}
  List<FeedModel>? getTweetList(UserModel? userModel) {
    if (userModel == null) {
      return null;
    }

    List<FeedModel>? list;

    if (feedList != null && feedList!.isNotEmpty) {
      list = feedList!.where((x) {
        /// If Tweet is a comment then no need to add it in tweet list
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user!.userId != userModel.userId) {
          return false;
        }

        /// Only include Tweets of logged-in user's and his following user's
        // if (x.user!.userId == userModel.userId ||
        //     (userModel.followingList != null &&
        //         userModel.followingList!.contains(x.user!.userId))) {
        //   return true;
        // } else {
        //   return false;
        // }
        return true;
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  /// This function call when search fiels text change.
  /// UserModel list on  search field get filter by `name` string
  void filterByUsername(String? name) {
    if (name != null &&
        name.isEmpty &&
        _userlist != null &&
        _userlist!.length != _userFilterList!.length) {
      _userFilterList = List.from(_userlist!);
    }
    // return if userList is empty or null
    if (_userlist == null && _userlist!.isEmpty) {
      cprint("User list is empty");
      return;
    }
    // sortBy userlist on the basis of username
    else if (name != null) {
      _userFilterList = _userlist!
          .where((x) =>
              x.userName != null &&
              x.userName!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByGroup(String? name) {
    if (name != null &&
        name.isEmpty &&
        _groupList != null &&
        _groupList!.length != groupFilterList!.length) {
      groupFilterList = List.from(_groupList!);
    }
    // return if userList is empty or null
    if (_groupList == null && _groupList!.isEmpty) {
      cprint("User list is empty");
      return;
    }
    // sortBy userlist on the basis of username
    else if (name != null) {
      groupFilterList = _groupList!
          .where((x) =>
              x.title != null &&
              x.title!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Sort user list on search user page.
  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortUser.Alphabetically:
        _userFilterList!
            .sort((x, y) => x.displayName!.compareTo(y.displayName!));
        return "Alphabetically";

      case SortUser.MaxFollower:
        _userFilterList!.sort((x, y) => y.followers!.compareTo(x.followers!));
        return "Popular";

      case SortUser.Newest:
        _userFilterList!.sort((x, y) => DateTime.parse(y.createdAt!)
            .compareTo(DateTime.parse(x.createdAt!)));
        return "Newest user";

      case SortUser.Oldest:
        _userFilterList!.sort((x, y) => DateTime.parse(x.createdAt!)
            .compareTo(DateTime.parse(y.createdAt!)));
        return "Oldest user";

      case SortUser.Verified:
        _userFilterList!.sort((x, y) =>
            y.isVerified.toString().compareTo(x.isVerified.toString()));
        return "Verified user";

      default:
        return "Unknown";
    }
  }

  /// Return user list relative to provided `userIds`
  /// Method is used on
  List<UserModel> userList = [];
  List<UserModel> getuserDetail(List<String> userIds) {
    final list = _userlist!.where((x) {
      if (userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }

  UserModel getSingleUserDetail(String uId) {
    final user = _userlist!.firstWhere((x) => x.userId == uId);
    return user;
  }

  List<UserModel>? getUserList() {
    return _userlist;
  }
}
