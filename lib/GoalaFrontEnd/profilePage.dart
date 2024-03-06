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

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  bool isMyProfile = false;
  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      var authState = Provider.of<ProfileState>(context, listen:false);

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
    if(authState.isbusy == false) {
      if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId) == false || authState.profileUserModel.followingList?.any((x) => x ==
          authState.userId) == null )&&(
          authState.userModel.followingList?.any((x) => x == authState.profileId) == false || authState.userModel.followingList?.any((x) =>
          x == authState.profileId) == null)) {
        return "Add Friend";
      }
      else if (authState.profileUserModel.followingList?.any((x) => x == authState.userId) == true &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId) == false || authState.userModel.followingList?.any((x) => x == authState.profileId) == null)) {
        return "Accept Friend Request";
      }
      else if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId) == false || authState.profileUserModel.followingList?.any((x) =>
      x == authState.userId) == null) && (authState.userModel.followingList?.any((x) => x == authState.profileId)) == true) {
        return "Friend Request Sent";
      }
      else if ((authState.profileUserModel.followingList?.any((x) =>
      x ==
          authState.userId)) == true &&
          (authState.userModel.followingList?.any((x) =>
          x ==
              authState.profileId)) == true) {
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
          .any((x) => x == authState.userId)) && (authState.userModel.followingList!
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
    var authState = Provider.of<ProfileState>(context, listen:true);
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      list = feedstate.feedList!.where((x) => x.userId == widget.profileId && x.isGroupGoal == false && x.parentkey == null && x.isPrivate == false).toList();
      GroupGoalList = feedstate.feedList!.where((x) => x.memberList!.contains(widget.profileId) && x.isGroupGoal == true && x.parentkey == null && x.isPrivate == false).toList();
    }
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body:

      RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          return Future.value();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * .24,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const <StretchMode>[
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground
                  ],
                  centerTitle: true,
                  background:
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Add an image widget to display an image
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 5),
                                  shape: BoxShape.circle),
                              child: RippleButton(
                                child: authState.isbusy
                                    ? const SizedBox.shrink() :
                                  CircularImage(
                                    path: authState.profileUserModel!.profilePic!,
                                    height: 80,
                                  ),
                                borderRadius: BorderRadius.circular(50),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    ProfileImageView.getRoute(authState.profileUserModel!.profilePic!));
                                },
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                      alignment: Alignment(10.0, 1),
                                      margin: const EdgeInsets.only(top: 30, right: 30),
                                      child: authState.isbusy
                                          ? const SizedBox.shrink(): Text(
                                        authState.profileUserModel.displayName!,
                                        style: GoogleFonts.openSans(fontSize: 40,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height:20),
                                    RippleButton(
                                      splashColor:
                                      TwitterColor.dodgeBlue_50.withAlpha(100),
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(60)),
                                      onPressed: () {
                                        setState(() {
                                          if (isMyProfile) {
                                            Navigator.push(
                                                context, EditProfilePage.getRoute());
                                          } else {
                                            if(isFollower() == "Add Friend"){
                                              authState.addFriend();
                                            }
                                            else if(isFollower() == "Friend Request Sent"){

                                            }
                                            else if(isFollower() == "Accept Friend Request"){
                                              authState.acceptFriendRequest();
                                            }
                                            else if(isFollower() == "Friend Added"){

                                            }
                                        }});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMyProfile
                                              ? TwitterColor.white : authState.isbusy ?
                                              TwitterColor.dodgeBlue
                                              : isFollower() == "Friend Added"
                                              ? TwitterColor.dodgeBlue
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
                                              : isFollower() == "Friend Request Sent" ? 'Friend Request Sent'
                                              : isFollower() == "Accept Friend Request" ? 'Accept Friend Request'
                                              : isFollower() == "Friend Added" ? 'Friend Added':'',
                                          style: TextStyle(
                                            color: isMyProfile
                                                ? Colors.black87.withAlpha(180)
                                                : isFollower() == "Friend Added"
                                                ? TwitterColor.white
                                                : Colors.blue,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                )
                            )
                          ],
                        ),
                        authState.isbusy ? SizedBox(
                          width:20,
                        ): state.isbusy ? SizedBox(
                          width:20,
                        ):authState.profileUserModel.closenessMap == null ? SizedBox(
                          width:20,
                        ):Expanded(
                            child:
                            ListView(
                              scrollDirection: Axis.horizontal,
                              children:
                              authState.profileUserModel.closenessMap!.map((model) {

                                return Row(children:[
                                  state.getUserList() == null ? SizedBox(
                                    width:20,
                                  ):
                                  CircularImage(path: state.getSingleUserDetail(model.split(' ')[0]).profilePic, height: 37),
                                  SizedBox(
                                    width:20,
                                  )
                                ]);
                              },

                              ).toList(),
                            )
                        )
                      ]
                    ),
                  )
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 800,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // give the tab bar a height [can change hheight to preferred height]
                        Container(
                          height: 45,
                          width:330,
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
                                  child:Text("Personal Goals"),
                                ),
                              ),
                              Container(
                                width: 200,
                                color: Color(0x69DC9E),
                                child: Center(child:
                                Text("Group Goals"),
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
                              // first tab bar view widget
                              Stack(
                                  children: <Widget>[
                                    Center(
                                        child: Column(
                                          children: <Widget>[
                                            SingleChildScrollView(child:
                                            Center(
                                              child: ListView.separated(
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                addAutomaticKeepAlives: false,
                                                physics: const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) => _UserTile(tweet: list![index]),
                                                separatorBuilder: (_, index) => const Divider(
                                                  height: 0,
                                                ),
                                                itemCount: list?.length ?? 0,
                                              ),
                                            ),),
                                          ],
                                        )
                                    ),
                                  ]
                              ),
                              // second tab bar view widget
                              Center(
                                  child: Column(
                                    children: <Widget>[
                                      Center(
                                        child: ListView.separated(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          addAutomaticKeepAlives: false,
                                          physics: const BouncingScrollPhysics(),
                                          itemBuilder: (context, index) => _UserTile(tweet: GroupGoalList![index]),
                                          separatorBuilder: (_, index) => const Divider(
                                            height: 0,
                                          ),
                                          itemCount: GroupGoalList?.length ?? 0,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
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
          SizedBox (width: 5),
          SizedBox(
            height: 20,
            width:120,
            child:
            CustomProgressBar(
                progress: widget.tweet.isHabit == false ? widget.tweet
                    .GoalAchieved! / widget.tweet.GoalSum!
                    : widget.tweet.checkInList!.where((item) => item == true)
                    .length / 8,
                height: 20,
                width: 120,
                backgroundColor: Colors.grey[300]!,
                progressColor: Color(0xFF29AB87)),
          )
        ],
      ),
      subtitle: Text(widget.tweet.description!),
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
