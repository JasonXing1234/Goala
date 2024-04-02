import 'package:Goala/GoalaFrontEnd/widgets/GoalGrid.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileHeader.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/state/profile_state.dart';
import 'package:provider/provider.dart';
import '../state/searchState.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.profileId}) : super(key: key);

  final String profileId;
  static MaterialPageRoute getRoute({required String profileId}) {
    return MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => ProfileState(profileId),
        child: ChangeNotifierProvider(
          create: (BuildContext context) => ProfileState(profileId),
          builder: (_, child) => ProfilePage(
            profileId: profileId,
          ),
        ),
      ),
    );
  }

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isMyProfile = false;

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      var authState = Provider.of<ProfileState>(context, listen: false);

      isMyProfile = authState.isMyProfile;

      state.resetFilterList();
    });
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  String? isFollower() {
    var authState = Provider.of<ProfileState>(context, listen: false);
    if (authState.isbusy == false) {
      if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId) == false ||
              authState.profileUserModel.followingList?.any((x) => x == authState.userId) ==
                  null) &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId) == false ||
              authState.userModel.followingList?.any((x) => x == authState.profileId) ==
                  null)) {
        return "Add Friend";
      } else if (authState.profileUserModel.followingList?.any((x) => x == authState.userId) == true &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId) == false ||
              authState.userModel.followingList?.any((x) => x == authState.profileId) ==
                  null)) {
        return "Accept Friend Request";
      } else if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId) == false ||
              authState.profileUserModel.followingList
                      ?.any((x) => x == authState.userId) ==
                  null) &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId)) ==
              true) {
        return "Friend Request Sent";
      } else if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId)) == true &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId)) == true) {
        return "Friend Added";
      }
    }
    return "";
  }

  bool isFriendRequestSent() {
    var authState = Provider.of<ProfileState>(context, listen: false);
    if (authState.profileUserModel.followingList != null &&
        authState.profileUserModel.followingList!.isNotEmpty &&
        authState.userModel.followingList != null &&
        authState.userModel.followingList!.isNotEmpty) {
      return (authState.profileUserModel.followingList!
              .any((x) => x == authState.userId)) &&
          (authState.userModel.followingList!
              .any((x) => x == authState.profileId));
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FeedModel>? personalGoalsList;
    List<FeedModel>? groupGoalsList;
    var feedstate = Provider.of<FeedState>(context);
    var authState = Provider.of<ProfileState>(context, listen: true);
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      personalGoalsList = feedstate.feedList!
          .where((x) =>
              x.userId == widget.profileId &&
              x.isGroupGoal == false &&
              x.parentkey == null &&
              x.isPrivate == false)
          .toList();
      groupGoalsList = feedstate.feedList!
          .where((x) =>
              x.memberList!.contains(widget.profileId) &&
              x.isGroupGoal == true &&
              x.parentkey == null &&
              x.isPrivate == false)
          .toList();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            userModel: authState.profileUserModel,
            isCurrentUser: false,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GoalGrid(
                groupGoals: groupGoalsList ?? [],
                personalGoals: personalGoalsList ?? [],
                tabController: _tabController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

