import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/ui/page/profile/profilePage.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/circular_image.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

import '../../../model/feedModel.dart';
import '../../../state/authState.dart';
import '../../../state/feedState.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  @override
  Widget build(BuildContext context) {
    List<FeedModel>? list;
    List<FeedModel>? GroupGoalList;
    final state = Provider.of<SearchState>(context);
    var feedstate = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context, listen:false);
    String id = authState.userId!;
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      list = feedstate.feedList!.where((x) => x.userId == id && x.isGroupGoal == false).toList();
      GroupGoalList = feedstate.feedList!.where((x) => x.memberList!.contains(id) && x.isGroupGoal == true).toList();
    }


    //final List<FeedModel>? list = state.getTweetList(authState.userModel);
    return Scaffold(
        //floatingActionButton: _floatingActionButton(context),
      body:

      RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          return Future.value();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * .3,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Container(
                  color: Colors.black,
                  child: Text(authState.userModel!.displayName!,
                      style: TextStyle(

                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 19.0,
                      )),
                ),
                background: CachedNetworkImage(
                  imageUrl: 'https://www.foodandwine.com/thmb/h7XBIk5uparmVpDEyQ9oC7brCpA=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/A-Feast-of-Apples-FT-2-MAG1123-980271d42b1a489bab239b1466588ca4.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 800,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // give the tab bar a height [can change hheight to preferred height]
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            // give the indicator a decoration (color and border radius)
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
                              color: Colors.green,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              // first tab [you can add an icon using the icon property]
                              Tab(
                                text: 'Personal Goals',
                              ),

                              // second tab [you can add an icon using the icon property]
                              Tab(
                                text: 'Group Goals',
                              ),
                            ],
                          ),
                        ),
                        // tab bar view here
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // first tab bar view widget
                              Center(
                                child: Column(
                          children: <Widget>[
                          ElevatedButton(
                          //style: style,
                          onPressed: (){Navigator.of(context).pushNamed('/CreateFeedPage/tweet');},
                          child: const Text('New Personal Goal'),
                        ),
                        Center(
                          child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            addAutomaticKeepAlives: false,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) => _UserTile(tweet: list![index]),
                            separatorBuilder: (_, index) => const Divider(
                              height: 0,
                            ),
                            itemCount: list?.length ?? 0,
                          ),
                        ),
                      ],
                    )
                                ),


                              // second tab bar view widget
                              Center(
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      //style: style,
                                      onPressed: (){Navigator.of(context).pushNamed('/CreateGroupGoal/tweet');},
                                      child: const Text('New Group Goal'),
                                    ),
                                    Center(
                                        child: ListView.separated(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          addAutomaticKeepAlives: false,
                                          physics: const BouncingScrollPhysics(),
                                          itemBuilder: (context, index) => _UserTile(tweet: GroupGoalList![index]),
                                          separatorBuilder: (_, index) => const Divider(
                                            height: 0,
                                          ),
                                          itemCount: GroupGoalList?.length ?? 0,
                                        ),
                                    ),
                                  ],
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        /*ListView.separated(
          addAutomaticKeepAlives: false,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => _UserTile(user: list![index]),
          separatorBuilder: (_, index) => const Divider(
            height: 0,


          ),
          itemCount: list?.length ?? 0,
        ),*/
      ),
    );
  }
  /*Widget _floatingActionButton(BuildContext context) {
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
  }*/
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key? key, required this.tweet}) : super(key: key);
  //final UserModel user;
  final FeedModel tweet;
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    var authState = Provider.of<AuthState>(context, listen: false);

    return ListTile(
      onTap: () {
        /*if (kReleaseMode) {
          kAnalytics.logViewSearchResults(searchTerm: user.userName!);
        }
        Navigator.push(context, ProfilePage.getRoute(profileId: user.userId!));*/
      },
      //leading: CircularImage(path: user.profilePic, height: 40),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: TitleText(tweet.title!,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 3),
          /*user.isVerified!
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  isTwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
              : const SizedBox(width: 0),*/
        ],
      ),
      subtitle: Text(tweet.description!),
    );
  }
}
