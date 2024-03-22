import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/state/profile_state.dart';
import 'package:Goala/ui/page/profile/EditProfilePage.dart';
import 'package:Goala/ui/page/profile/profileImageView.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/authState.dart';
import '../state/searchState.dart';
import '../widgets/newWidget/title_text.dart';
import 'TaskDetailPage.dart';

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
  @override
  late TabController _tabController;
  bool isMyProfile = false;
  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];

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
    List<FeedModel>? list;
    List<FeedModel>? GroupGoalList;
    final state = Provider.of<SearchState>(context);
    var feedstate = Provider.of<FeedState>(context);
    var authState = Provider.of<ProfileState>(context, listen: true);
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      list = feedstate.feedList!
          .where((x) =>
              x.userId == widget.profileId &&
              x.isGroupGoal == false &&
              x.parentkey == null &&
              x.isPrivate == false)
          .toList();
      GroupGoalList = feedstate.feedList!
          .where((x) =>
              x.memberList!.contains(widget.profileId) &&
              x.isGroupGoal == true &&
              x.parentkey == null &&
              x.isPrivate == false)
          .toList();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          return Future.value();
        },
        child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    return[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * .22,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Container(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    color: Colors.white,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Add an image widget to display an image
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 40),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 5),
                                    shape: BoxShape.circle),
                                child: RippleButton(
                                  child: authState.isbusy
                                      ? const SizedBox.shrink()
                                      : CircularImage(
                                          path: authState
                                              .profileUserModel!.profilePic!,
                                          height: 80,
                                        ),
                                  borderRadius: BorderRadius.circular(50),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        ProfileImageView.getRoute(authState
                                            .profileUserModel!.profilePic!));
                                  },
                                ),
                              ),
                              SingleChildScrollView(
                                  child: Column(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 2),
                                  alignment: Alignment(10.0, 1),
                                  margin:
                                      const EdgeInsets.only(top: 30, right: 30),
                                  child: authState.isbusy
                                      ? const SizedBox.shrink()
                                      : Text(
                                          authState
                                              .profileUserModel.displayName!,
                                          style: GoogleFonts.openSans(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  child: RippleButton(
                                    splashColor: TwitterColor.dodgeBlue_50
                                        .withAlpha(100),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    onPressed: () {
                                      setState(() {
                                        if (isMyProfile) {
                                          Navigator.push(context,
                                              EditProfilePage.getRoute());
                                        } else {
                                          if (isFollower() == "Add Friend") {
                                            authState.addFriend();
                                          } else if (isFollower() ==
                                              "Friend Request Sent") {
                                          } else if (isFollower() ==
                                              "Accept Friend Request") {
                                            authState.acceptFriendRequest();
                                          } else if (isFollower() ==
                                              "Friend Added") {}
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMyProfile
                                            ? TwitterColor.white
                                            : authState.isbusy
                                                ? TwitterColor.dodgeBlue
                                                : isFollower() == "Friend Added"
                                                    ? AppColor.PROGRESS_COLOR
                                                    : TwitterColor.white,
                                        border: Border.all(
                                            color: isMyProfile
                                                ? Colors.black87.withAlpha(180)
                                                : Colors.blue,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      /// If [isMyProfile] is true then Edit profile button will display
                                      // Otherwise Follow/Following button will be display
                                      child: Text(
                                        isMyProfile
                                            ? 'Edit Profile'
                                            : isFollower() == "Add Friend"
                                                ? 'Add Friend'
                                                : isFollower() ==
                                                        "Friend Request Sent"
                                                    ? 'Friend Request Sent'
                                                    : isFollower() ==
                                                            "Accept Friend Request"
                                                        ? 'Accept Friend Request'
                                                        : isFollower() ==
                                                                "Friend Added"
                                                            ? 'Friend Added'
                                                            : '',
                                        style: TextStyle(
                                          color: isMyProfile
                                              ? Colors.black87.withAlpha(180)
                                              : isFollower() == "Friend Added"
                                                  ? TwitterColor.white
                                                  : Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]))
                            ],
                          ),
                        ]),
                  )),
            )];},
            body: Container(
                height: 800,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // give the tab bar a height [can change hheight to preferred height]
                        Container(
                          height: 45,
                          width: 330,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          child: TabBar(
                            labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
                            controller: _tabController,
                            // give the indicator a decoration (color and border radius)
                            indicator: BoxDecoration(
                              color: Color(0xFF292A29),
                              borderRadius: BorderRadius.circular(
                                8.0,
                              ),
                            ),
                            labelColor: Colors.white,
                            //91F291
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Container(
                                width: 200,
                                color: Color(0x69DC9E),
                                child: Center(
                                  child: Text("Personal"),
                                ),
                              ),
                              Container(
                                width: 200,
                                color: Color(0x69DC9E),
                                child: Center(
                                  child: Text("Group"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // tab bar view here
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              GridView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                addAutomaticKeepAlives: false,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) =>
                                    _UserTile2(tweet: list![index]),
                                itemCount: list?.length ?? 0,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of items per row
                                  crossAxisSpacing:
                                      5.0, // Horizontal space between items
                                  mainAxisSpacing:
                                      5.0, // Vertical space between items
                                  childAspectRatio:
                                      0.8, // Aspect ratio of each item
                                ),
                              ),
                              GridView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                addAutomaticKeepAlives: false,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) =>
                                    _UserTile2(tweet: GroupGoalList![index]),
                                itemCount: GroupGoalList?.length ?? 0,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of items per row
                                  crossAxisSpacing:
                                      5.0, // Horizontal space between items
                                  mainAxisSpacing:
                                      5.0, // Vertical space between items
                                  childAspectRatio:
                                      0.8, // Aspect ratio of each item
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _UserTile extends StatefulWidget {
  const _UserTile({Key? key, required this.tweet}) : super(key: key);
  //final UserModel user;
  final FeedModel tweet;

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    var authState = Provider.of<AuthState>(context, listen: false);
    final feedState = Provider.of<FeedState>(context);
    return ListTile(
      onTap: () {
        feedState.getPostDetailFromDatabase(null, model: widget.tweet);
        Navigator.push(context, TaskDetailPage.getRoute(widget.tweet));
      },
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 90,
            child: TitleText(widget.tweet.title!,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 5),
          SizedBox(
            height: 20,
            width: 120,
            child: CustomProgressBar(
              progress: widget.tweet.isHabit == false
                  ? widget.tweet.GoalAchieved! / widget.tweet.GoalSum!
                  : widget.tweet.checkInList!
                          .where((item) => item == true)
                          .length /
                      8,
              height: 20,
              width: 120,
              backgroundColor: Colors.grey[300]!,
              progressColor: AppColor.PROGRESS_COLOR,
              daysLeft: DateTime(
                      int.parse(widget.tweet.deadlineDate!.split('-')[0]),
                      int.parse(widget.tweet.deadlineDate!.split('-')[1]),
                      int.parse(widget.tweet.deadlineDate!.split('-')[2]))
                  .difference(DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day))
                  .inDays,
              isHabit: widget.tweet.isHabit,
              checkInDays: widget.tweet.checkInList!,
            ),
          )
        ],
      ),
      subtitle: Text(widget.tweet.description!),
    );
  }
}

class _UserTile2 extends StatefulWidget {
  const _UserTile2({Key? key, required this.tweet}) : super(key: key);
  //final UserModel user;
  final FeedModel tweet;

  @override
  State<_UserTile2> createState() => _UserTile2State();
}

class _UserTile2State extends State<_UserTile2> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FeedState>(context);
    return GridTile(
      child: InkWell(
          onTap: () {
            state.getPostDetailFromDatabase(null, model: widget.tweet);
            Navigator.push(context, TaskDetailPage.getRoute(widget.tweet));
          },
          child: Row(children: [
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 160,
                  child: Text(
                    widget.tweet.title!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 3),
                SizedBox(
                  height: 25,
                  width: 160,
                  child: CustomProgressBar(
                    progress: widget.tweet.isHabit == false
                        ? widget.tweet.GoalAchieved! / widget.tweet.GoalSum!
                        : widget.tweet.checkInList!
                                .where((item) => item == true)
                                .length /
                            8,
                    height: 25,
                    width: 160,
                    backgroundColor: Colors.grey[300]!,
                    progressColor: widget.tweet.isCheckedIn == true
                        ? AppColor.PROGRESS_COLOR
                        : Colors.black,
                    daysLeft: DateTime(
                            int.parse(widget.tweet.deadlineDate!.split('-')[0]),
                            int.parse(widget.tweet.deadlineDate!.split('-')[1]),
                            int.parse(widget.tweet.deadlineDate!.split('-')[2]))
                        .difference(DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day))
                        .inDays,
                    isHabit: widget.tweet.isHabit,
                    checkInDays: widget.tweet.checkInList!,
                  ),
                ),
                SizedBox(height: 7),
                if (widget.tweet.coverPhoto != null)
                  Container(
                    width: 160, // Specify the width of the container
                    height: 160, // Specify the height of the container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      // Use ClipRRect for borderRadius if needed
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.tweet.coverPhoto!,
                        fit: BoxFit
                            .cover, // This ensures the image covers the container
                      ),
                    ),
                  ),
              ],
            ),
          ])),
    );
  }
}

class Choice {
  const Choice(
      {required this.title, required this.icon, this.isEnable = false});
  final bool isEnable;
  final IconData icon;
  final String title;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Share', icon: Icons.directions_car, isEnable: true),
  Choice(title: 'QR code', icon: Icons.directions_railway, isEnable: true),
  Choice(title: 'Draft', icon: Icons.directions_bike),
  Choice(title: 'View Lists', icon: Icons.directions_boat),
  Choice(title: 'View Moments', icon: Icons.directions_bus),
];
