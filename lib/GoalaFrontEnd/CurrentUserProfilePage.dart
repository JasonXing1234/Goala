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
import '../widgets/newWidget/rippleButton.dart';
import '../ui/page/profile/profileImageView.dart';
import 'TaskDetailPage.dart';

class CurrentUserProfilePage extends StatefulWidget {
  const CurrentUserProfilePage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _CurrentUserProfilePageState();
}

class _CurrentUserProfilePageState extends State<CurrentUserProfilePage>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('goala');
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
        child: CustomScrollView(
          slivers: <Widget>[
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
                                width: 400,
                                color: Color(0x69DC9E),
                                child: Center(
                                  child: Text("Personal", style: TextStyles.titleStyle),
                                ),
                              ),
                              Container(
                                width: 300,
                                color: Color(0x69DC9E),
                                child: Center(
                                  child: Text("Group", style: TextStyles.titleStyle),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // tab bar view here
                        SizedBox(height:10),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // first tab bar view widget
                              Stack(children: <Widget>[
                                Center(
                                    child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: GridView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        addAutomaticKeepAlives: false,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            _UserTile2(tweet: list![index]),
                                        itemCount: list?.length ?? 0,
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
                                    ),
                                  ],
                                )),
                              ]),
                              // second tab bar view widget
                              Center(
                                  child: Column(
                                children: <Widget>[
                                  Center(
                                    child: GridView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      addAutomaticKeepAlives: false,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) =>
                                          _UserTile2(tweet: GroupGoalList![index]),
                                      itemCount: GroupGoalList?.length ?? 0,
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
                                  ),
                                ],
                              )),
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
    return GridTile(
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
            ),]
          )),
    );
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

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            backgroundColor: AppColor.PROGRESS_COLOR,
            foregroundColor: Colors.white,
            onPressed: _toggle,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}

//29AB87
@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: AppColor.PROGRESS_COLOR,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey.shade300,
      ),
    );
  }
}
