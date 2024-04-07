import 'dart:io';
import 'package:Goala/GoalaFrontEnd/timelinePosts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/customRoute.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/authState.dart';
import '../ui/theme/theme.dart';
import '../widgets/tweet/widgets/tweetBottomSheet.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({Key? key, required this.tempFeed}) : super(key: key);
  final FeedModel tempFeed;
  static Route<void> getRoute(FeedModel feed) {
    return SlideLeftRoute<void>(
      builder: (BuildContext context) => TaskDetailPage(
        tempFeed: feed,
      ),
    );
  }

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetailPage> {
  File? imagePicked;
  late FeedModel tempFeed;
  bool isEditing = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    tempFeed = widget.tempFeed;
    super.initState();
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
    var authState = Provider.of<AuthState>(context);
    final scrollController = ScrollController();
    return Scaffold(
      key: scaffoldKey,
      //floatingActionButton: _floatingActionButton(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(tempFeed.title!, style: TextStyles.barTitleStyle),
                ),
              ],
            ),
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            bottom: PreferredSize(
              child: Container(
                color: Colors.grey.shade200,
                height: 1.0,
              ),
              preferredSize: const Size.fromHeight(0.0),
            ),
          ),
          SliverToBoxAdapter(
              child: Column(
            children: [
              if (authState.userModel!.userId! == tempFeed.userId)
                ElevatedButton(
                    onPressed: () {
                      var state =
                          Provider.of<FeedState>(context, listen: false);
                      state.setTweetToReply = tempFeed;
                      Navigator.of(context).pushNamed('/ComposeTweetPage');
                    },
                    child: Text('Add Post')
                    //isEditing == true ? Text('Finish') : Text('Edit')
                    ),
              ListView(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: state.tweetReplyMap == null ||
                        state.tweetReplyMap!.isEmpty ||
                        state.tweetReplyMap![widget.tempFeed.key!] == null
                    ? [
                        Column(children: [
                          SizedBox(height: 140),
                          Center(
                              child: Text(
                            'Explore Your Groups',
                            style: TextStyle(fontSize: 34),
                          ))
                        ])
                      ]
                    : state.tweetReplyMap![widget.tempFeed.key!]!
                        .map((x) => _commentRow(x, state.tweetReplyMap![widget.tempFeed.key!]!.indexOf(x) == state.tweetReplyMap![widget.tempFeed.key!]!.length - 1, state.tweetReplyMap![widget.tempFeed.key!]!.indexOf(x) == 0))
                        .toList(),
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget _commentRow(FeedModel model, bool isLastOne, bool tempFirstOne) {
    return TimelinePosts(
      isLast: isLastOne,
      model: model,
      type: TweetType.Reply,
      isFirst: tempFirstOne,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: TweetType.Reply),
      scaffoldKey: scaffoldKey,
    );
  }
}

class FullScreenPhoto extends StatelessWidget {
  final String photoUrl;

  FullScreenPhoto({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'photo$photoUrl',
            child: Image.network(photoUrl),
          ),
        ),
      ),
    );
  }
}
