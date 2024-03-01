import 'package:flutter/material.dart';
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

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage/tweet');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabTweet,
        isTwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //floatingActionButton: _floatingActionButton(context),
      backgroundColor: TwitterColor.mystic,
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
  const _FeedPageBody(
      {Key? key, required this.scaffoldKey, required this.refreshIndicatorKey})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  State<_FeedPageBody> createState() => _FeedPageBodyState();
}

class _FeedPageBodyState extends State<_FeedPageBody> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context, listen: false);
    String id = authState.userId!;
    List<FeedModel>? GroupList = [];
    String currentTweetId = '';
    bool ShowPage = false;
    if (state.feedList != null && state.feedList!.isNotEmpty) {
      GroupList = state.feedList!
          .where((x) => x.memberList!.contains(id) && x.isGroupGoal == true)
          .toList();
    }
    return Consumer<FeedState>(
      builder: (context, state, child) {
        final List<FeedModel>? list = state.getTweetList(authState.userModel);
        return CustomScrollView(
          slivers: <Widget>[
            child!,
            SliverAppBar(
                //expandedHeight: 150.0,

                actions: <Widget>[
                  Expanded(
                      //height: 100.0,
                      //width:300.0,
                      child: ListView(
                    // This next line does the trick.
                    scrollDirection: Axis.horizontal,
                    children: GroupList!.map(
                      (model) {
                        return ElevatedButton(
                          onPressed: () {},
                          child: Text(model!.title!),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                // Change your radius here
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ))
                ]),
            SliverToBoxAdapter(
                child: SizedBox(
              height: 100.0,
              child: ListView(
                // This next line does the trick.
                scrollDirection: Axis.horizontal,
                children: GroupList!.map(
                  (model) {
                    return Column(children: [
                      ElevatedButton(
                        onPressed: () {
                          ShowPage = !ShowPage;
                          currentTweetId = model!.key!;
                        },
                        child: Text(model!.title!),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              // Change your radius here
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      model!.key! == currentTweetId
                          ? Container(child: Text('hahahaha'))
                          : Container(child: Text(''))
                    ]);
                  },
                ).toList(),
              ),
            )),
            /*SliverPadding(
                        padding: EdgeInsets.all(16.0),
        sliver:SliverList(
                        delegate: SliverChildListDelegate(

                          //TODO: Add groups here

                          list!.map(
                            (model) {
                              return Container(
                                color: Colors.white,
                                child: Tweet(
                                  model: model,
                                  trailing: TweetBottomSheet().tweetOptionIcon(
                                      context,
                                      model: model,
                                      type: TweetType.Tweet,
                                      scaffoldKey: scaffoldKey),
                                  scaffoldKey: scaffoldKey,
                                ),
                              );
                            },
                          ).toList(),

                        ),
                      )
            )*/
          ],
        );
      },
      /*child:
      RefreshIndicator(
        onRefresh: () async {
        state.getDataFromDatabase();
        return Future.value();
      },*/
      child: CustomAppBar2(
        scaffoldKey: widget.scaffoldKey,
        icon: AppIcon.settings,
        //onActionPressed: onSettingIconPressed,
        onSearchChanged: (text) {
          state.filterByUsername(text);
        },
      ),
      // )
      /*SliverAppBar(
        floating: true,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            );
          },
        ),
        title: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextField(
              onChanged: onSearchChanged,
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
                hintText: 'Search..',
                fillColor: AppColor.extraLightGrey,
                filled: true,
                focusColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              ),
            )),
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
          preferredSize: const Size.fromHeight(0.0),
        ),
      ),*/
    );
  }
}

class SampleWidget extends StatefulWidget {
  @override
  _SampleWidgetState createState() => _SampleWidgetState();
}

class _SampleWidgetState extends State<SampleWidget> {
  Widget _body() {
    final state = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context, listen: false);
    String id = authState.userId!;
    List<FeedModel>? GroupList = [];
    if (state.feedList != null && state.feedList!.isNotEmpty) {
      GroupList = state.feedList!
          .where((x) => x.memberList!.contains(id) && x.isGroupGoal == true)
          .toList();
    }
    int _activeWidget = GroupList.length;
    switch (_activeWidget) {
      case 1:
        return GestureDetector(
            onTap: () {
              setState(() {
                _activeWidget = 2;
              });
            },
            child: Container(
              color: Colors.blue,
              child: Text("I'm one"),
            ));
      case 2:
        return GestureDetector(
            onTap: () {
              setState(() {
                _activeWidget = 0;
              });
            },
            child: Container(
              color: Colors.green,
              child: Text("I'm two"),
            ));
      default:
        return GestureDetector(
            onTap: () {
              setState(() {
                _activeWidget = 1;
              });
            },
            child: Container(
              color: Colors.red,
              child: Text("I'm zero"),
            ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _body(),
    );
  }
}
