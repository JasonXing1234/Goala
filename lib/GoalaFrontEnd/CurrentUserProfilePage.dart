import 'dart:ui';
import 'dart:math' as math;
import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/feedModel.dart';
import '../state/authState.dart';
import '../state/feedState.dart';
import '../ui/page/profile/follow/followerListPage.dart';
import '../widgets/newWidget/rippleButton.dart';
import '../ui/page/profile/profileImageView.dart';
import 'EditGoalPage.dart';
import 'TaskDetailPage.dart';

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
  void dispose(){
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
    requestPermission();
    listenForForegroundNotifications();
    super.initState();
  }


  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User Granted Permission');
    } else {
      print('declined');
    }
  }

  void listenForForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('pushing goals!');
      // print('Message data: ${message.data}');

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FeedModel>? list;
    List<FeedModel>? GroupGoalList;
    late List<String> usersList;
    final state = Provider.of<SearchState>(context);
    var feedstate = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context);
    String id = authState.userId!;
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      list = feedstate.feedList!
          .where((x) =>
              x.userId == id && x.isGroupGoal == false && x.parentkey == null)
          .toList();
      GroupGoalList = feedstate.feedList!
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
      body: RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          return Future.value();
        },
        child: NestedScrollView(
          //controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * .20,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    background: Container(
                        padding: const EdgeInsets.all(8.0),
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
                                        horizontal: 20, vertical: 20),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 5),
                                        shape: BoxShape.circle),
                                    child: RippleButton(
                                      child: CircularImage(
                                        path: authState.userModel?.profilePic,
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
                                  Column(children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      alignment: Alignment(10.0, 1),
                                      margin:
                                      authState.userModel == null
                                          ? const EdgeInsets.only(top: 30, right: 20) : authState.userModel!.displayName!.length < 6 ? const EdgeInsets.only(top: 30, right: 20) : const EdgeInsets.only(top: 30, right: 0),
                                      child: Text(
                                        authState.userModel == null
                                            ? ''
                                            : authState.userModel!.displayName!,
                                        style: GoogleFonts.roboto(
                                          fontSize: 37,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Stack(children: [
                                      Container(
                                        margin:
                                        const EdgeInsets.only(right: 5, top: 10),
                                        child:

                                              RippleButton(
                                                splashColor:
                                                TwitterColor.dodgeBlue_50.withAlpha(100),
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(8)),
                                                onPressed: () {
                                                  if(authState.userModel!.friendList != null){
                                                    usersList = authState.userModel!.friendList!;
                                                  }
                                                  else{
                                                    usersList = [];
                                                  }
                                                  Navigator.push(
                                                    context,
                                                    FollowerListPage.getRoute(
                                                      profile: authState.userModel!,
                                                      userList: usersList,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: TwitterColor.white,
                                                    border: Border.all(
                                                        color: Colors.black87.withAlpha(180),
                                                        width: 1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),

                                                  /// If [isMyProfile] is true then Edit profile button will display
                                                  // Otherwise Follow/Following button will be display
                                                  child: Text(authState.isbusy == true || authState.userModel?.friendList == null ? '${0} Friend' : authState.userModel?.friendList!.length == 1 ? '1 Friend' : '${authState.userModel?.friendList!.length} Friends',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    //Text('${authState.isbusy == true || authState.userModel?.friendList == null ? 0 : authState.userModel?.friendList!.length} Friends',
                                                  ),
                                                ),
                                              ),
                                      ),
                                      if (authState.userModel?.pendingRequestList != null && !authState.userModel!.pendingRequestList!.isEmpty) // Show the red circle if there are new messages
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColor.PROGRESS_COLOR,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              authState.userModel!.pendingRequestList!.length.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),]
                                      )
                                    ]
                                  )
                                ],
                              ),

                              /*authState.isbusy
                                ? SizedBox(
                                    width: 20,
                                  )
                                : state.isbusy
                                    ? SizedBox(
                                        width: 20,
                                      )
                                    : authState.userModel?.closenessMap == null
                                        ? SizedBox(
                                            width: 20,
                                          )
                                        : Expanded(
                                            child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: authState
                                                .userModel!.closenessMap!
                                                .map(
                                              (model) {
                                                return Row(children: [
                                                  state.getUserList() == null
                                                      ? SizedBox(
                                                          width: 20,
                                                        )
                                                      : CircularImage(
                                                          path: state
                                                              .getSingleUserDetail(
                                                                  model.split(
                                                                      ' ')[0])
                                                              .profilePic,
                                                          height: 37),
                                                  SizedBox(
                                                    width: 20,
                                                  )
                                                ]);
                                              },
                                            ).toList(),
                                          ))*/
                            ]))),
              ),
            ];
          },
          body:
          Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                    Column(
                      children: [
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
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
                                          width: 180,
                                          color: Color(0x69DC9E),
                                          child: Center(
                                            child: Text("Personal", style: TextStyles.titleStyle),
                                          ),
                                        ),
                                        Container(
                                          width: 180,
                                          color: Color(0x69DC9E),
                                          child: Center(
                                            child: Text("Group", style: TextStyles.titleStyle),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),)),

                        SizedBox(height:10),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              list == null || list.isEmpty ?
                              Center(
                                child: Text('Add a personal goal now!',style: TextStyles.bigSubtitleStyle)
                              ) :
                              GridView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                addAutomaticKeepAlives: false,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) =>
                                    _UserTile2(tweet: list![index]),
                                itemCount: list.length ?? 0,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2, // Number of items per row
                                  crossAxisSpacing:
                                      5.0, // Horizontal space between items
                                  mainAxisSpacing:
                                      5.0, // Vertical space between items
                                  childAspectRatio:
                                      0.8, // Aspect ratio of each item
                                ),
                              ),
                              GroupGoalList == null || GroupGoalList.isEmpty ?
                              Center(
                                  child: Text('Add a group goal now!',style: TextStyles.bigSubtitleStyle)
                              ) :
                              GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  addAutomaticKeepAlives: false,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      _UserTile2(tweet: GroupGoalList![index]),
                                  itemCount: GroupGoalList.length ?? 0,
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                    2, // Number of items per row
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
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FeedState>(context);
    return ListTile(
        onTap: () {
          state.getPostDetailFromDatabase(null, model: widget.tweet);
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
                            .length / 8,
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
        trailing: widget.tweet.isCheckedIn
            ? Icon(AppIcon.bulbOn)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  fixedSize: Size(98, 20), //////// HERE
                ),
                onPressed: () async {
                  var state = Provider.of<FeedState>(context, listen: false);
                  var tempTweet = await state.fetchTweet(widget.tweet.key!);
                  tempTweet!.checkInList![tempTweet.checkInList!.length - 1] =
                      true;
                  FirebaseDatabase.instance
                      .reference()
                      .child("tweet")
                      .child(widget.tweet.key!)
                      .update({
                    "checkInList": tempTweet.checkInList,
                    "isCheckedIn": true,
                  }).then((_) {
                    if (tempTweet.isHabit == false) {
                      _showPopupWindow(context, tempTweet);
                    }
                  }).catchError((onError) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(onError)));
                  });
                },
                child: Text(
                  'Check In',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ));
  }

  void _showPopupWindow(BuildContext context, FeedModel tempFeed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter an Integer'),
          content: TextField(
            controller: _textEditingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter integer here"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Commit'),
              onPressed: () {
                var state = Provider.of<FeedState>(context, listen: false);
                state.addNumberToGoal(
                    tempFeed, int.parse(_textEditingController.text));
                print('Entered Integer: ${_textEditingController.text}');
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
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

    void _showBottomMenu(BuildContext context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    onTap: () {
                      state.setTweetToReply = widget.tweet;
                      Navigator.of(context).pushNamed('/CreateEditPage');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      var state = Provider.of<FeedState>(context, listen: false);
                      state.deleteTweet(widget.tweet.key!);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          });
    }

    return GestureDetector(
        onLongPress: () => _showBottomMenu(context),
    child:
      GridTile(
          child: InkWell(
            onTap: () {
              state.getPostDetailFromDatabase(null, model: widget.tweet);
              Navigator.push(context, TaskDetailPage.getRoute(widget.tweet));
            },
            child:
            Row(
            children:
            [
              SizedBox(width:12),
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
                    ),),
                ),
                SizedBox(height:3),
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
                    progressColor: widget.tweet.isCheckedIn == true ? AppColor.PROGRESS_COLOR : Colors.black,
                    daysLeft: DateTime(
                        int.parse(widget.tweet.deadlineDate!.split('-')[0]),
                        int.parse(widget.tweet.deadlineDate!.split('-')[1]),
                        int.parse(widget.tweet.deadlineDate!.split('-')[2]))
                        .difference(DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day))
                        .inDays,
                    isHabit: widget.tweet.isHabit, checkInDays: widget.tweet.checkInList!,
                  ),
                ),
                SizedBox(height:7),

                  Container(
                    width: 160, // Specify the width of the container
                    height: 160, // Specify the height of the container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      // Use ClipRRect for borderRadius if needed
                      borderRadius: BorderRadius.circular(12),
                      child: widget.tweet.coverPhoto != null ? Image.network(
                        widget.tweet.coverPhoto!,
                        fit: BoxFit
                            .cover, // This ensures the image covers the container
                      ) : Image.asset(
                        'assets/images/icon_512.png',
                        fit: BoxFit
                            .cover, // This ensures the image covers the container
                      )
                    ),
                  ),
              ],
            ),]
          )),
    ));
  }
}
