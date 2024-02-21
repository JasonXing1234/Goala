import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/goalaicon/flutter-icons-bd835920/my_flutter_app_icons.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

import '../../../widgets/CustomAppBar2.dart';
import '../../../widgets/customAppBar.dart';

class FeedPage extends StatelessWidget {
  const FeedPage(
      {Key? key, required this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: TwitterColor.white,
      body: SafeArea(
        child: SizedBox(
          height: context.height,
          width: context.width,
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              /// refresh home page feed
              var feedState = Provider.of<FeedState>(context, listen: false);
              feedState.getDataFromDatabase();
              feedState.getPeopleFromDatabase();
              return Future.value(true);
            },
            child: _FeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedPageBody extends StatefulWidget {
  const _FeedPageBody({Key? key, required this.scaffoldKey, required this.refreshIndicatorKey}) : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  State<_FeedPageBody> createState() => _FeedPageBodyState();
}
class _FeedPageBodyState extends State<_FeedPageBody> with TickerProviderStateMixin{

  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 500);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context, listen: false);
    String id = authState.userId!;
    List<FeedModel>? GroupList = [];
    String currentTweetId = '';
    bool ShowPage = false;
    if (state.feedList != null && state.feedList!.isNotEmpty) {
      GroupList = state.feedList!.where((x) => x.memberList!.contains(id) && x.isGroupGoal == true).toList();
    }
    return Consumer<FeedState>(
      builder: (context, state, child) {
        final List<FeedModel>? list = state.getTweetList(authState.userModel);
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            // SliverAppBar and/or other sliver widgets go here
            return <Widget>[
              child!,
              SliverAppBar(
                  actions: <Widget>[
                    Expanded(
                        child:
                        ListView(
                          // This next line does the trick.
                          scrollDirection: Axis.horizontal,
                          children:
                          GroupList!.asMap().entries.map((model) {
                            return Row(children:[
                              SizedBox(
                                width:20,
                              ),
                              ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    //currentTweetId = model!.key!;
                                    //ShowPage = !ShowPage;
                                    state.getPostDetailFromDatabase(null, model: model.value);
                                    _tabController.animateTo(model!.key);

                                  });
                                },
                                child: Text(model!.value.title!),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      // Change your radius here
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:10,
                              )
                            ]);
                          },
                          ).toList(),
                        )
                    ),

                  ]
              ),
            ];
          },
          body:
          TabBarView(controller: _tabController,
            children: GroupList!.asMap().entries.map((model) {
              return Column(
                  children:[
                    ElevatedButton(
                        onPressed: () {
                          var state = Provider.of<FeedState>(context, listen: false);
                          state.setTweetToReply = model.value;
                          Navigator.of(context).pushNamed('/ComposeTweetPage');
                        },
                        child: Text('Post In Group')),
                    Flexible(// wrap in Expanded
                        child:
                        ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children:
                          state.tweetReplyMap == null ||
                              state.tweetReplyMap!.isEmpty ||
                              state.tweetReplyMap![model!.value.key!] == null
                              ? [
                            Column(
                                children: [
                                  SizedBox(height:140),
                                  Center(
                                      child: Text(
                                        'Explore Your Groups',
                                        style: TextStyle(fontSize: 34),

                                      )
                                  )
                                ]
                            )

                          ]
                              :state.tweetReplyMap![model!.value.key!]!
                              .map((x) => _commentRow(x))
                              .toList(),
                        )
                    )]
              );
            },
            ).toList(),),

        );

      },
      child: CustomAppBar2(
        scaffoldKey: widget.scaffoldKey,
        icon: AppIcon.goalalogo,
        //onActionPressed: onSettingIconPressed,
        onSearchChanged: (text) {

          state.filterByUsername(text);
        },
      ),
    );
  }
  Widget _commentRow(FeedModel model) {
    return Tweet(
      model: model,
      type: TweetType.Reply,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: widget.scaffoldKey, model: model, type: TweetType.Reply),
      scaffoldKey: widget.scaffoldKey,
    );
  }
}
