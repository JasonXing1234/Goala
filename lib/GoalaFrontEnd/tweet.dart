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

import '../widgets/customWidgets.dart';
import '../widgets/tweet/widgets/PokeButton.dart';
import '../widgets/tweet/widgets/retweetWidget.dart';
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
  void _onPressPoke() {
    debugPrint("You pressed the poke button");
  }
  Future <void> getParentModel() async {
    var feedState = Provider.of<FeedState>(context, listen:false);
    tempModel = await feedState.fetchTweet(widget.model.parentkey!);
  }
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    double descriptionFontSize = widget.type == TweetType.Tweet
        ? 15
        : widget.type == TweetType.Detail || widget.type == TweetType.ParentTweet
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
                    Navigator.push(
                        context,
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
                                child: TitleText(widget.model.user!.displayName!,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 3),
                              widget.model.user!.isVerified!
                                  ? customIcon(
                                context,
                                icon: AppIcon.blueTick,
                                isTwitterIcon: true,
                                iconColor: AppColor.primary,
                                size: 13,
                                paddingIcon: 3,
                              )
                                  : const SizedBox(width: 0),
                              SizedBox(
                                width: widget.model.user!.isVerified! ? 5 : 0,
                              ),
                              const SizedBox(width: 4),
                              customText(
                                '· ${Utility.getChatTime(widget.model.createdAt)}',
                                style:
                                TextStyles.userNameStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(child: widget.trailing ?? const SizedBox()),
                      ],
                    ),
                    widget.model.grandparentKey == null ? Row(
                      children: [
                        CustomProgressBar(
                            progress: widget.model.isHabit == false ? tempModel!
                                .GoalAchieved! / tempModel!.GoalSum!
                                : tempModel!.checkInList!.where((item) => item == true)
                                .length / 8,
                            height: 20,
                            width: 200,
                            backgroundColor: Colors.grey[300]!,
                            progressColor: Color(0xFF29AB87),
                            daysLeft: DateTime(int.parse(tempModel!.deadlineDate!.split('-')[0]), int.parse(tempModel!.deadlineDate!.split('-')[1]), int.parse(tempModel!.deadlineDate!.split('-')[2]))
                              .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays,
                        ),
                        const Spacer(),
                        PokeButton(onPressed: _onPressPoke),
                      ],
                    ) :SizedBox.shrink(),
                    widget.model.parentName != null ? Text(widget.model.parentName!) : Text(''),
                    widget.model.goalPhotoList != null ?
                    SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.model.goalPhotoList!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(8.0),
                              // Add some padding around each image
                              child: Image.network(
                                widget.model.goalPhotoList![index]!,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        )) : SizedBox(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          );
        }
    );
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
                            isTwitterIcon: true,
                            iconColor: AppColor.primary,
                            size: 13,
                            paddingIcon: 3,
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

  const CustomProgressBar({
    Key? key,
    required this.width,
    required this.height,
    required this.progress,
    required this.backgroundColor,
    required this.progressColor, required this.daysLeft,
  }) : super(key: key);

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
          width: progress <= 1 ? width * progress : 0,
          height: height,
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Center(
          child: Text(
            daysLeft.toString() + ' days left',
            style: TextStyle(fontSize: 12),
          )
        ),
      ],
    );
  }
}