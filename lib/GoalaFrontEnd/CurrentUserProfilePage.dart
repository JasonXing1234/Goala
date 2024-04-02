import 'package:Goala/GoalaFrontEnd/widgets/GoalGrid.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileHeader.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
          ProfileHeader(userModel: authState.userModel),
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
