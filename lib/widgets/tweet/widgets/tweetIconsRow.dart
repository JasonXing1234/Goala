import 'package:flutter/material.dart';
import 'package:Goala/helper/customRoute.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/page/common/usersListPage.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

import '../../../helper/constant.dart';
import '../../../model/user.dart';

class TweetIconsRow extends StatefulWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double? size;
  final bool isTweetDetail;
  final TweetType? type;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TweetIconsRow(
      {Key? key,
      required this.model,
      required this.iconColor,
      required this.iconEnableColor,
      this.size,
      this.isTweetDetail = false,
      this.type,
      required this.scaffoldKey})
      : super(key: key);

  @override
  State<TweetIconsRow> createState() => _TweetIconsRowState();
}

class _TweetIconsRowState extends State<TweetIconsRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed from the
    // widget tree. This also removes the listener.
    _controller.dispose();
    super.dispose();
  }
  void _showBottomPopup(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return
          Padding(
            padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: EdgeInsets.all(10),
          height: 150,
          child: Column(
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Comment',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      var state = Provider.of<FeedState>(context, listen: false);
                      var authState = Provider.of<AuthState>(context, listen: false);
                      state.setTweetToReply = widget.model;
                      var myUser = authState.userModel;
                      var profilePic = myUser!.profilePic ?? Constants.dummyProfilePic;
                      var commentedUser = UserModel(
                          displayName: myUser.displayName ?? myUser.email!.split('@')[0],
                          profilePic: profilePic,
                          userId: myUser.userId,
                          isVerified: authState.userModel!.isVerified,
                          userName: authState.userModel!.userName);
                      FeedModel reply = FeedModel(
                        isComment: false,
                        isGroupGoal: false,
                        description: _controller.text,
                        lanCode: '',
                        user: commentedUser,
                        createdAt: DateTime.now().toUtc().toString(),
                        grandparentKey: state.tweetToReplyModel == null
                            ? null
                            : state.tweetToReplyModel!.parentkey,
                        parentkey: state.tweetToReplyModel!.key,
                        userId: myUser.userId!,
                        isCheckedIn: false,
                        isPrivate: false,
                        isHabit: false,
                      );
                      String? tweetId = await state.addCommentToPost(reply);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              // If you want the button outside the TextField
            ],
          ),
        ) );
      },
    );
  }

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    var authState = Provider.of<AuthState>(context, listen: false);

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _iconWidget(
            context,
            text: widget.isTweetDetail ? '' : model.commentCount.toString(),
            icon: AppIcon.reply,
            iconColor: widget.iconColor,
            size: 25,
            onPressed: () => _showBottomPopup(context),
          ),
          /*_iconWidget(context,
              text: isTweetDetail ? '' : model.retweetCount.toString(),
              icon: AppIcon.retweet,
              iconColor: iconColor,
              size: size ?? 20, onPressed: () {
            TweetBottomSheet().openRetweetBottomSheet(context,
                type: type, model: model, scaffoldKey: scaffoldKey);
          }),*/
          _iconWidget(
            context,
            text: widget.isTweetDetail ? '' : model.likeCount.toString(),
            icon: model.likeList!.any((userId) => userId == authState.userId)
                ? AppIcon.heartFill
                : AppIcon.heartEmpty,
            onPressed: () {
              addLikeToTweet(context);
            },
            iconColor:
                model.likeList!.any((userId) => userId == authState.userId)
                    ? widget.iconEnableColor
                    : widget.iconColor,
            size: 25,
          ),
          _iconWidget(context, text: '', icon: null, sysIcon: Icons.share,
              onPressed: () {
            shareTweet(context);
          }, iconColor: widget.iconColor, size: widget.size ?? 20),
        ],
      ),
    );
  }

  Widget _iconWidget(BuildContext context,
      {required String text,
      IconData? icon,
      Function? onPressed,
      IconData? sysIcon,
      required Color iconColor,
      double size = 20}) {
    if (sysIcon == null) assert(icon != null);
    if (icon == null) assert(sysIcon != null);

    return Expanded(
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              if (onPressed != null) onPressed();
            },
            icon: sysIcon != null
                ? Icon(sysIcon, color: iconColor, size: size)
                : customIcon(
                    context,
                    size: size,
                    icon: icon!,
                    iconColor: iconColor,
                  ),
          ),
          customText(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontSize: size - 5,
            ),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _timeWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            const SizedBox(width: 5),
            customText(Utility.getPostTime2(widget.model.createdAt),
                style: TextStyles.textStyle14),
            const SizedBox(width: 10),
            customText('Fwitter for Android',
                style: TextStyle(color: Theme.of(context).primaryColor))
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _likeCommentWidget(BuildContext context) {
    bool isLikeAvailable =
        widget.model.likeCount != null ? widget.model.likeCount! > 0 : false;
    bool isRetweetAvailable = widget.model.retweetCount! > 0;
    bool isLikeRetweetAvailable = isRetweetAvailable || isLikeAvailable;
    return Column(
      children: <Widget>[
        const Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
          padding:
              EdgeInsets.symmetric(vertical: isLikeRetweetAvailable ? 12 : 0),
          duration: const Duration(milliseconds: 500),
          child: !isLikeRetweetAvailable
              ? const SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    !isRetweetAvailable
                        ? const SizedBox.shrink()
                        : customText(widget.model.retweetCount.toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                    !isRetweetAvailable
                        ? const SizedBox.shrink()
                        : const SizedBox(width: 5),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: customText('Retweets',
                          style: TextStyles.subtitleStyle),
                      crossFadeState: !isRetweetAvailable
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 800),
                    ),
                    !isRetweetAvailable
                        ? const SizedBox.shrink()
                        : const SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        onLikeTextPressed(context);
                      },
                      child: AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Row(
                          children: <Widget>[
                            customSwitcherWidget(
                              duraton: const Duration(milliseconds: 300),
                              child: customText(widget.model.likeCount.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  key: ValueKey(widget.model.likeCount)),
                            ),
                            const SizedBox(width: 5),
                            customText('Likes', style: TextStyles.subtitleStyle)
                          ],
                        ),
                        crossFadeState: !isLikeAvailable
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                    )
                  ],
                ),
        ),
        !isLikeRetweetAvailable
            ? const SizedBox.shrink()
            : const Divider(
                endIndent: 10,
                height: 0,
              ),
      ],
    );
  }

  Widget customSwitcherWidget(
      {required child, Duration duraton = const Duration(milliseconds: 500)}) {
    return AnimatedSwitcher(
      duration: duraton,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: child,
    );
  }

  void addLikeToTweet(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToTweet(widget.model, authState.userId);
  }

  void onLikeTextPressed(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListPage(
          pageTitle: "Liked by",
          userIdsList: widget.model.likeList!.map((userId) => userId).toList(),
          emptyScreenText: "This tweet has no like yet",
          emptyScreenSubTileText:
              "Once a user likes this tweet, user list will be shown here",
        ),
      ),
    );
  }

  void shareTweet(BuildContext context) async {
    TweetBottomSheet().openShareTweetBottomSheet(context, widget.model, widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //isTweetDetail ? _timeWidget(context) : const SizedBox(),
        //isTweetDetail ? _likeCommentWidget(context) : const SizedBox(),
        _likeCommentsIcons(context, widget.model)
      ],
    );
  }
}
