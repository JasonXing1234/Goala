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

import '../../../ui/page/feed/feedPostDetail.dart';

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
            onPressed: () {
              Navigator.push(context, FeedPostDetail.getRoute(model.key!));
            },
          ),
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
          _widgetBottomSheetRow(
            context,
            AppIcon.bookmark,
            isEnable: true,
            text: '',
            onPressed: () async {
              var state = Provider.of<FeedState>(context, listen: false);
              await state.addBookmark(model.key!);
              ScaffoldMessenger.maybeOf(context)!.showSnackBar(
                const SnackBar(content: Text("Bookmark saved!")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
      {required String text, Function? onPressed, bool isEnable = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            customIcon(
              context,
              icon: icon,
              size: 25,
              iconColor:
              onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
            ),
            const SizedBox(
              width: 15,
            ),
            customText(
              text,
              context: context,
              style: TextStyle(
                color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ).ripple(() {
        if (onPressed != null) {
          onPressed();
        } else {
          Navigator.pop(context);
        }
      }),
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

  void shareTweet(BuildContext context) async {
    TweetBottomSheet()
        .openShareTweetBottomSheet(context, widget.model, widget.type);
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
