import 'package:Goala/GoalaFrontEnd/widgets/FriendButton.dart';
import 'package:Goala/GoalaFrontEnd/widgets/GoalGrid.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileHeader.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileImage.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:flutter/material.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../ui/page/profile/profileImageView.dart';
import '../widgets/newWidget/rippleButton.dart';

class CurrentUserProfilePage extends StatefulWidget {
  const CurrentUserProfilePage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _CurrentUserProfilePageState();
}

class _CurrentUserProfilePageState extends State<CurrentUserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<FeedModel>? personalGoalsList;
    List<FeedModel>? groupGoalsList;
    var feedstate = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context);
    String id = authState.userId;
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      personalGoalsList = feedstate.feedList!
          .where((x) =>
              x.userId == id && x.isGroupGoal == false && x.parentkey == null)
          .toList();
      groupGoalsList = feedstate.feedList!
          .where((x) =>
              x.memberList!.contains(id) &&
              x.isGroupGoal == true &&
              x.parentkey == null)
          .toList();
    }
    if (authState.isbusy) {
      if (authState.userModel!.closenessMap != null) {
        authState.userModel!.closenessMap!
            .sort((a, b) => a.split(' ')[1].compareTo(b.split(' ')[1]));
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.PROGRESS_COLOR,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).pushNamed('/CreateGroupGoal/tweet');
        },
        child: const Icon(Icons.create),
      ),
      body: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 16),
                  // Profile picture
                  RippleButton(
                    child: ProfileImage(
                      path: authState.userModel?.profilePic,
                    ),
                    borderRadius:
                        BorderRadius.circular(ProfileImage.BORDER_RADIUS),
                    onPressed: () {
                      Navigator.push(
                        context,
                        ProfileImageView.getRoute(
                          authState.userModel!.profilePic!,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Name
                  Expanded(
                    child: Text(
                      authState.userModel?.displayName ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik().copyWith(
                        fontSize: 30,
                        color: AppColor.PROGRESS_COLOR,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FriendButton(
                    friendsList: authState.userModel?.friendList ?? [],
                    user: authState.userModel,
                    isCurrentUser: true,
                    pendingRequestList:
                        authState.userModel?.pendingRequestList ?? [],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
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
