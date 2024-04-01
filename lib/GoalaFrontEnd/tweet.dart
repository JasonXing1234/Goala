import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/page/feed/feedPostDetail.dart';
import 'package:Goala/GoalaFrontEnd/profilePage.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:Goala/widgets/tweet/widgets/parentTweet.dart';
import 'package:Goala/widgets/tweet/widgets/tweetIconsRow.dart';
import 'package:Goala/widgets/url_text/customUrlText.dart';
import 'package:Goala/widgets/url_text/custom_link_media_info.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../state/authState.dart';
import '../widgets/customWidgets.dart';
import '../widgets/tweet/widgets/PokeButton.dart';
import '../widgets/tweet/widgets/tweetImage.dart';

class Tweet extends StatelessWidget {
  final FeedModel model;
  final Widget? trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const Tweet({
    Key? key,
    required this.model,
    this.trailing,
    this.type = TweetType.Tweet,
    this.isDisplayOnProfile = false,
    required this.scaffoldKey,
  }) : super(key: key);

  void onLongPressedTweet(BuildContext context) {
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      Utility.copyToClipBoard(
          context: context,
          text: model.description ?? "",
          message: "Tweet copy to clipboard");
    }
  }

  void onTapTweet(BuildContext context) {
    var feedState = Provider.of<FeedState>(context, listen: false);
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      return;
    }
    if (type == TweetType.Tweet && !isDisplayOnProfile) {
      feedState.clearAllDetailAndReplyTweetStack();
    }
    feedState.getPostDetailFromDatabase(null, model: model);
    Navigator.push(context, FeedPostDetail.getRoute(model.key!));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        /// Left vertical bar of a tweet
        /*type != TweetType.ParentTweet
            ? const SizedBox.shrink()
            : Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 38,
                    top: 75,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 2.0, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),*/
        InkWell(
          onLongPress: () {
            onLongPressedTweet(context);
          },
          onTap: () {
            onTapTweet(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: type == TweetType.Tweet || type == TweetType.Reply
                      ? 12
                      : 0,
                ),
                child: type == TweetType.Tweet || type == TweetType.Reply
                    ? _TweetBody(
                        isDisplayOnProfile: isDisplayOnProfile,
                        model: model,
                        trailing: trailing,
                        type: type,
                      )
                    : _TweetDetailBody(
                        model: model,
                        trailing: trailing,
                        type: type,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TweetImage(
                  model: model,
                  type: type,
                ),
              ),
              /*model.childRetwetkey == null
                  ? const SizedBox.shrink()
                  : RetweetWidget(
                      childRetwetkey: model.childRetwetkey!,
                      type: type,
                      isImageAvailable: model.imagePath != null &&
                          model.imagePath!.isNotEmpty,
                    ),*/
              Padding(
                padding:
                    EdgeInsets.only(left: type == TweetType.Detail ? 10 : 60),
                child: TweetIconsRow(
                  type: type,
                  model: model,
                  isTweetDetail: type == TweetType.Detail,
                  iconColor: Theme.of(context).textTheme.bodySmall!.color!,
                  iconEnableColor: TwitterColor.ceriseRed,
                  size: 20,
                  scaffoldKey: GlobalKey<ScaffoldState>(),
                ),
              ),
              type == TweetType.ParentTweet
                  ? const SizedBox.shrink()
                  : const Divider(height: .5, thickness: .5)
            ],
          ),
        ),
      ],
    );
  }
}

class _TweetBody extends StatefulWidget {
  final FeedModel model;
  final Widget? trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  const _TweetBody(
      {Key? key,
      required this.model,
      this.trailing,
      required this.type,
      required this.isDisplayOnProfile})
      : super(key: key);

  @override
  State<_TweetBody> createState() => _TweetBodyState();
}

class _TweetBodyState extends State<_TweetBody> {
  late FeedModel? tempModel = widget.model;

  @override
  void initState() {
    super.initState();
    getParentModel();
  }

  Future<void> _onPressPoke(String? token, String? displayName) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAv0Rlcww:APA91bElZKaKqCu2rk6NTlubBQ93BGfB_RVbT-Gn89tgrirBzXcXt1EZpFulH2OjsTymUul9LfXnlrTdHOiab_cuwajAcvbrxWpd9P8z-9W4Ppb093v2b9v-0TCSAUf5At91l8Ybu9SK'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': 'Goala',
              'title': '${displayName} poked you!',
            },
            "notification": <String, dynamic>{
              'title': 'Goala',
              'body': '${displayName} poked you!',
              'android_channel_id': 'dbfood'
            },
            "to": token,
          },
        ),
      );
      print('good');
    } catch (e) {
      print('error');
    }
    /*try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendPokeNotification');
      final result = await callable.call({
        "data": {
          'token': token,
          'user': displayName
        }
      });
      print('Function result: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      print(e);
    }*/
  }

  Future<void> getParentModel() async {
    var feedState = Provider.of<FeedState>(context, listen: false);
    tempModel = await feedState.fetchTweet(widget.model.parentkey!);
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    double descriptionFontSize = widget.type == TweetType.Tweet
        ? 15
        : widget.type == TweetType.Detail ||
                widget.type == TweetType.ParentTweet
            ? 18
            : 14;
    FontWeight descriptionFontWeight =
        widget.type == TweetType.Tweet || widget.type == TweetType.Tweet
            ? FontWeight.w400
            : FontWeight.w400;

    TextStyle textStyle = TextStyle(
        color: Colors.black,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    TextStyle urlStyle = TextStyle(
        color: Colors.blue,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    return FutureBuilder(
        future: getParentModel(),
        builder: (context, snapshot) {
          /*if (snapshot.connectionState != ConnectionState.done) {
            // Future hasn't finished yet, return a placeholder
            return Text('Loading');
          }*/
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    // If tweet is displaying on someone's profile then no need to navigate to same user's profile again.
                    if (widget.isDisplayOnProfile) {
                      return;
                    }
                    Navigator.push(context,
                        ProfilePage.getRoute(profileId: widget.model.userId));
                  },
                  child: CircularImage(path: widget.model.user!.profilePic),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: context.width - 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: 0, maxWidth: context.width * .5),
                                child: Text(
                                  widget.model.user!.displayName!,
                                  style: TextStyles.titleStyle,
                                ),
                              ),
                              const SizedBox(width: 3),
                              widget.model.user!.isVerified!
                                  ? customIcon(
                                      context,
                                      icon: AppIcon.blueTick,
                                      iconColor: AppColor.primary,
                                      size: 13,
                                    )
                                  : const SizedBox(width: 0),
                              SizedBox(
                                width: widget.model.user!.isVerified! ? 5 : 0,
                              ),
                              const SizedBox(width: 4),
                              customText(
                                '· ${Utility.getChatTime(widget.model.createdAt)}',
                                style: TextStyles.userNameStyle
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        //TODO: Pop-up menu, might be useful for the future
                        //Container(child: widget.trailing ?? const SizedBox()),
                      ],
                    ),
                    SizedBox(height: 10),
                    widget.model.parentName != null
                        ? Text(
                            widget.model.parentName!,
                            style: TextStyles.bigSubtitleStyle,
                          )
                        : Text(''),
                    widget.model.grandparentKey == null
                        ? Row(
                            children: [
                              SizedBox(
                                height: 25,
                                width: 230,
                                child: CustomProgressBar(
                                  progress: widget.model.isHabit == false
                                      ? tempModel!.GoalAchieved! /
                                          tempModel!.GoalSum!
                                      : tempModel!.checkInList!
                                              .where((item) => item == true)
                                              .length /
                                          8,
                                  height: 25,
                                  width: 230,
                                  backgroundColor: Colors.grey[300]!,
                                  progressColor: AppColor.PROGRESS_COLOR,
                                  daysLeft: DateTime(
                                          int.parse(tempModel!.deadlineDate!
                                              .split('-')[0]),
                                          int.parse(tempModel!.deadlineDate!
                                              .split('-')[1]),
                                          int.parse(tempModel!.deadlineDate!
                                              .split('-')[2]))
                                      .difference(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day))
                                      .inDays,
                                  isHabit: tempModel!.isHabit,
                                  checkInDays: tempModel!.checkInList!,
                                ),
                              ),
                              SizedBox(width: 20),
                              PokeButton(onPressed: () {
                                _onPressPoke(widget.model.deviceToken,
                                    authState.userModel!.displayName);
                              }),
                            ],
                          )
                        : SizedBox.shrink(),
                    widget.model.goalPhotoList != null
                        ? Container(
                            width: 230, // Specify the width of the container
                            height: 230, // Specify the height of the container
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              // Use ClipRRect for borderRadius if needed
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.model.goalPhotoList![0]!,
                                fit: BoxFit
                                    .cover, // This ensures the image covers the container
                              ),
                            ),
                          )
                        //TODO:Keep this listview gallery code, might be useful in the future
                        /*SizedBox(
                            height: 200,
                            child:
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.model.goalPhotoList!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(8.0),
                                  // Add some padding around each image
                                  child: Image.network(
                                    widget.model.goalPhotoList![0]!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            )
                    )*/
                        : SizedBox(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          );
        });
  }
}

class _TweetDetailBody extends StatelessWidget {
  final FeedModel model;
  final Widget? trailing;
  final TweetType type;
  const _TweetDetailBody({
    Key? key,
    required this.model,
    this.trailing,
    required this.type,
    /*this.isDisplayOnProfile*/
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = type == TweetType.Tweet
        ? context.getDimension(context, 15)
        : type == TweetType.Detail
            ? context.getDimension(context, 18)
            : type == TweetType.ParentTweet
                ? context.getDimension(context, 14)
                : 10;

    FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w300
            : FontWeight.w400;
    TextStyle textStyle = TextStyle(
        color: Colors.black,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    TextStyle urlStyle = TextStyle(
        color: Colors.blue,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        model.parentkey != null &&
                model.childRetwetkey == null &&
                type != TweetType.ParentTweet
            ? ParentTweetWidget(
                childRetwetkey: model.parentkey!,
                trailing: trailing,
                type: type,
              )
            : const SizedBox.shrink(),
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, ProfilePage.getRoute(profileId: model.userId));
                  },
                  child: CircularImage(path: model.user!.profilePic),
                ),
                title: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 0, maxWidth: context.width * .5),
                      child: TitleText(model.user!.displayName!,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 3),
                    model.user!.isVerified!
                        ? customIcon(
                            context,
                            icon: AppIcon.blueTick,
                            iconColor: AppColor.primary,
                            size: 13,
                          )
                        : const SizedBox(width: 0),
                    SizedBox(
                      width: model.user!.isVerified! ? 5 : 0,
                    ),
                  ],
                ),
                /*subtitle: customText('${model.user!.userName}',
                    style: TextStyles.userNameStyle),*/
                trailing: trailing,
              ),
              model.description == null
                  ? const SizedBox()
                  : Padding(
                      padding: type == TweetType.ParentTweet
                          ? const EdgeInsets.only(left: 80, right: 16)
                          : const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UrlText(
                              text: model.description!.removeSpaces,
                              onHashTagPressed: (tag) {
                                cprint(tag);
                              },
                              style: textStyle,
                              urlStyle: urlStyle),
                        ],
                      ),
                    ),
              if (model.imagePath == null && model.description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomLinkMediaInfo(text: model.description!),
                )
            ],
          ),
        ),
      ],
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final int daysLeft;
  final bool isHabit;
  final List<bool> checkInDays;

  const CustomProgressBar({
    Key? key,
    required this.width,
    required this.height,
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.daysLeft,
    required this.isHabit,
    required this.checkInDays,
  }) : super(key: key);

  int calculateStreak(List<bool> values) {
    int streak = 0;

    // Iterate over the list from the end to the beginning
    for (int i = values.length - 1; i >= 0; i--) {
      // If the value is true, increment the streak
      if (values[i]) {
        streak++;
      } else {
        // If a false is encountered, break the loop as we only want consecutive trues from the end
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: progress <= 1 ? width * progress : width,
          height: height,
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Center(
            child: isHabit == true
                ? Text(calculateStreak(checkInDays).toString() + ' days streak',
                    style: TextStyle(fontSize: height * 0.6))
                : Text(
                    daysLeft.toString() + ' days left',
                    style: TextStyle(fontSize: height * 0.6),
                  )),
      ],
    );
  }
}

class CustomProgressBar2 extends StatelessWidget {
  final double width;
  final double height;
  final double GoalAchieved;
  final double GoalSum;
  final double oldProgress;
  final double newProgress;
  final Color backgroundColor;
  final Color progressColor;
  final int daysLeft;
  final bool isHabit;
  final List<bool> checkInDays;

  const CustomProgressBar2({
    Key? key,
    required this.width,
    required this.height,
    required this.oldProgress,
    required this.backgroundColor,
    required this.progressColor,
    required this.daysLeft,
    required this.isHabit,
    required this.checkInDays,
    required this.newProgress, required this.GoalAchieved, required this.GoalSum,
  }) : super(key: key);

  int calculateStreak(List<bool> values) {
    int streak = 0;

    // Iterate over the list from the end to the beginning
    for (int i = values.length - 1; i >= 0; i--) {
      // If the value is true, increment the streak
      if (values[i]) {
        streak++;
      } else {
        // If a false is encountered, break the loop as we only want consecutive trues from the end
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Row(children: [
          Container(
            width: oldProgress <= 1 ? width * oldProgress : width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: newProgress <= 1 ? width * newProgress : width,
            height: height,
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: BorderRadius.circular(4),
            ),
          )
        ]),
        Center(
            child: Text(((newProgress / 1) * 100).toString() + '%',
                style: TextStyle(fontSize: height * 0.6))

        ),
      ],
    );
  }
}
