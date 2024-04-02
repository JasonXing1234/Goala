import 'package:Goala/GoalaFrontEnd/widgets/GoalGrid.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileHeader.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:flutter/material.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class CurrentUserProfilePage extends StatefulWidget {
  const CurrentUserProfilePage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _CurrentUserProfilePageState();
}

class _CurrentUserProfilePageState extends State<CurrentUserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('goala');

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
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
          ProfileHeader(
            userModel: authState.userModel,
            isCurrentUser: true,
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
