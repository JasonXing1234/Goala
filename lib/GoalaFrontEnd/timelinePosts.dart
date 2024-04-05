import 'dart:convert';

import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/page/feed/feedPostDetail.dart';
import 'package:Goala/GoalaFrontEnd/ProfilePage.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:Goala/widgets/tweet/widgets/parentTweet.dart';
import 'package:Goala/widgets/url_text/customUrlText.dart';
import 'package:Goala/widgets/url_text/custom_link_media_info.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../state/authState.dart';
import '../widgets/customWidgets.dart';

class TimelinePosts extends StatelessWidget {
  final bool isLast;
  final bool isFirst;
  final FeedModel model;
  final Widget? trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TimelinePosts({
    Key? key,
    required this.model,
    this.trailing,
    this.type = TweetType.Tweet,
    this.isDisplayOnProfile = false,
    required this.scaffoldKey,
    required this.isFirst,
    required this.isLast,
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
                child: type == TweetType.Tweet || type == TweetType.Reply
                    ? Center(
                        child: _TweetBody(
                          isDisplayOnProfile: isDisplayOnProfile,
                          isEnd: isFirst,
                          model: model,
                          trailing: trailing,
                          type: type,
                          isFirst: isLast,
                        ),
                      )
                    : _TweetDetailBody(
                        model: model,
                        trailing: trailing,
                        type: type,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
              ),
              /*model.childRetwetkey == null
                  ? const SizedBox.shrink()
                  : RetweetWidget(
                      childRetwetkey: model.childRetwetkey!,
                      type: type,
                      isImageAvailable: model.imagePath != null &&
                          model.imagePath!.isNotEmpty,
                    ),*/
              //TODO: Comments section
              /*Padding(
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
              ),*/
              //const Divider(height: .5, thickness: .5)
            ],
          ),
        ),
      ],
    );
  }
}

class _TweetBody extends StatefulWidget {
  final bool isFirst;
  final bool isEnd;
  final FeedModel model;
  final Widget? trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  const _TweetBody(
      {Key? key,
      required this.model,
      this.trailing,
      required this.type,
      required this.isDisplayOnProfile,
      required this.isEnd,
      required this.isFirst})
      : super(key: key);

  @override
  State<_TweetBody> createState() => _TweetBodyState();
}

class _TweetBodyState extends State<_TweetBody> {
  late FeedModel? tempModel = widget.model;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
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
          return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    width: 330,
                    child: widget.model.isHabit == true
                        ? CustomProgressBar(
                            progress: tempModel!.checkInList!
                                    .where((item) => item == true)
                                    .length /
                                8,
                            backgroundColor: Colors.grey[300]!,
                            progressColor: AppColor.PROGRESS_COLOR,
                      percentage: 0,
                            isHabit: tempModel!.isHabit,
                            checkInDays: tempModel!.checkInList!,
                          )
                        : CustomProgressBar2(
                            GoalAchieved: tempModel!.GoalAchieved!,
                            GoalSum: tempModel!.GoalSum!,
                            oldProgress: widget.isEnd && widget.isFirst
                                ? 0
                                : widget.isFirst && !widget.isEnd
                                    ? widget.model.GoalAchievedToday! /
                                        widget.model.GoalSum!
                                    : widget.isEnd && !widget.isFirst
                                        ? (widget.model.GoalAchieved! -
                                                widget
                                                    .model.GoalAchievedToday!) /
                                            widget.model.GoalSum!
                                        : widget.model.GoalAchieved! /
                                            widget.model.GoalSum!,
                            height: 30,
                            width: 330,
                            backgroundColor: Colors.grey[300]!,
                            progressColor: AppColor.PROGRESS_COLOR,
                            percentage: widget.model.GoalAchieved! /
                                widget.model.GoalSum!,
                            isHabit: tempModel!.isHabit,
                            checkInDays: tempModel!.checkInList!,
                            newProgress: widget.isEnd && widget.isFirst
                                ? widget.model.GoalAchieved! /
                                    widget.model.GoalSum!
                                : widget.isFirst && !widget.isEnd
                                    ? 0
                                    : widget.isEnd && !widget.isFirst
                                        ? widget.model.GoalAchievedToday! /
                                            widget.model.GoalSum!
                                        : 0,
                          ),
                  ),
                  SizedBox(height: 5),
                  widget.model.goalPhotoList != null
                      ? Container(
                          width: 330,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFECECEC),
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 0.45, // Border width
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width:
                                    330, // Specify the width of the container
                                height:
                                    330, // Specify the height of the container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  // Use ClipRRect for borderRadius if needed
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.model.goalPhotoList![0]!,
                                    fit: BoxFit
                                        .cover, // This ensures the image covers the container
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(widget.model.description!,
                                    style: TextStyles.subtitleStyle),
                              )
                            ],
                          ))
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
                  SizedBox(height: 20),
                ],
              ));
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
                //trailing: trailing,
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
