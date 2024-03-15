import 'package:flutter/material.dart';
import 'package:Goala/helper/customRoute.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:Goala/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

import '../../../GoalaFrontEnd/Comments.dart';
import '../../../helper/constant.dart';
import '../../../model/user.dart';

class FeedPostDetail extends StatefulWidget {
  const FeedPostDetail({Key? key, required this.postId}) : super(key: key);
  final String postId;

  static Route<void> getRoute(String postId) {
    return SlideLeftRoute<void>(
      builder: (BuildContext context) => FeedPostDetail(
        postId: postId,
      ),
    );
  }

  @override
  _FeedPostDetailState createState() => _FeedPostDetailState();
}

class _FeedPostDetailState extends State<FeedPostDetail> {
  late final TextEditingController _controller;
  late String postId;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    postId = widget.postId;
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _commentRow(FeedModel model) {
    return Comments(
      model: model,
      type: TweetType.Reply,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: TweetType.Reply),
      scaffoldKey: scaffoldKey,
    );
  }

  Widget _tweetDetail(FeedModel model) {
    return Tweet(
      model: model,
      type: TweetType.Detail,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: TweetType.Detail),
      scaffoldKey: scaffoldKey,
    );
  }

  void addLikeToComment(String commentId) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToTweet(state.tweetDetailModel!.last, authState.userId);
  }

  void openImage() async {
    Navigator.pushNamed(context, '/ImageViewPge');
  }

  void deleteTweet(TweetType type, String tweetId,
      {required String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteTweet(tweetId);
    Navigator.of(context).pop();
    if (type == TweetType.Detail) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<FeedState>(context, listen: false)
            .removeLastTweetDetail(postId);
        return Future.value(true);
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: customTitleText(
                'Comments',
              ),
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              bottom: PreferredSize(
                child: Container(
                  color: Colors.grey.shade200,
                  height: 1.0,
                ),
                preferredSize: const Size.fromHeight(0.0),
              ),
            ),
            /*SliverList(
              delegate: SliverChildListDelegate(
                [
                  state.tweetDetailModel == null ||
                          state.tweetDetailModel!.isEmpty
                      ? Container()
                      : _tweetDetail(state.tweetDetailModel!.last),
                ],
              ),
            ),*/
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(10),
                height: 95,
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
                            state.setTweetToReply = state.tweetDetailModel!.last;
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
              ) ,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                state.tweetReplyMap == null ||
                        state.tweetReplyMap!.isEmpty ||
                        state.tweetReplyMap![postId] == null
                    ? [
                        //!Removed container
                        const Center()
                      ]
                    : state.tweetReplyMap![postId]!
                        .map((x) => _commentRow(x))
                        .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
