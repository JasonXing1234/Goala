import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
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
<<<<<<< Updated upstream
=======
import '../../../widgets/newWidget/rippleButton.dart';
import '../feed/feedPostDetail.dart';
import '../profile/profileImageView.dart';
import '../taskDetail/TaskDetailPage.dart';
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
    var authState = Provider.of<AuthState>(context, listen:false);
    String id = authState.userId!;
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      list = feedstate.feedList!.where((x) => x.userId == id && x.isGroupGoal == false).toList();
      GroupGoalList = feedstate.feedList!.where((x) => x.memberList!.contains(id) && x.isGroupGoal == true).toList();
=======
    var authState = Provider.of<AuthState>(context);
    //final ulist = state.userlist!.where((x) => authState.userModel!.followingList!.contains(x.userId) && x.followingList!.contains(authState.userModel!.userId));
    //Map<String, int>? friendMap = Map.fromIterable(ulist, key: (item) => item, value: (item) => 1);
    String id = authState.userId!;
    if (feedstate.feedList != null && feedstate.feedList!.isNotEmpty) {
      list = feedstate.feedList!.where((x) => x.userId == id &&
          x.isGroupGoal == false && x.parentkey == null).toList();
      GroupGoalList =
          feedstate.feedList!.where((x) => x.memberList!.contains(id) &&
              x.isGroupGoal == true && x.parentkey == null).toList();
    }
    if(authState.isbusy){
      //authState.userModel!.closenessMap.add("eM3NppwKJkNoQsgI1sO7uUktsvy1");
      if(authState.userModel!.closenessMap != null) {
        authState.userModel!.closenessMap!.sort((a, b) =>
            a.split(' ')[1].compareTo(b.split(' ')[1]));
      }
>>>>>>> Stashed changes
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
              expandedHeight: MediaQuery.of(context).size.height * .22,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
<<<<<<< Updated upstream
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
=======
                background:
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                    child:
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Add an image widget to display an image
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 5),
                                        shape: BoxShape.circle),
                                    child: RippleButton(
                                      child: CircularImage(
                                        path: authState.userModel?.profilePic,
                                        height: 80,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            ProfileImageView.getRoute(
                                                authState.profileUserModel!.profilePic!));
                                      },
                                    ),
                                  ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment(10.0, 1),
                                      margin: const EdgeInsets.only(top: 30, right: 30),
                                      child: Text(
                                        authState.userModel == null ? '' :
                                          authState.userModel!.displayName!,
                                          style: GoogleFonts.openSans(fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                          ),

                                          ),

                                  )
                                ],
                            ),

                            authState.isbusy ? SizedBox(
                              width:20,
                            ): state.isbusy ? SizedBox(
                              width:20,
                            ):authState.userModel?.closenessMap == null ? SizedBox(
                              width:20,
                            ):Expanded(
                                child:
                                    ListView(
                                      scrollDirection: Axis.horizontal,
                                      children:
                                      authState.userModel!.closenessMap!.map((model) {

                                        return Row(children:[
                                          state.getUserList() == null ? SizedBox(
                                            width:20,
                                          ):
                                          CircularImage(path: state.getSingleUserDetail(model.split(' ')[0]).profilePic, height: 37),
                                          SizedBox(
                                            width:20,
                                          )
                                        ]);
                                      },

                                      ).toList(),
                                    )
                            )
                          ]
                        )

                )),),
>>>>>>> Stashed changes
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
                          width:330,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                          ),
                          child: TabBar(
<<<<<<< Updated upstream
                            controller: _tabController,
                            // give the indicator a decoration (color and border radius)
                            indicator: BoxDecoration(
=======
                            labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
                            controller: _tabController,
                            // give the indicator a decoration (color and border radius)
                            indicator: BoxDecoration(
                              color: Color(0xFF292A29),
>>>>>>> Stashed changes
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
<<<<<<< Updated upstream
                              color: Colors.green,
=======
>>>>>>> Stashed changes
                            ),
                            labelColor: Colors.white,
                            //91F291
                            unselectedLabelColor: Colors.black,
                            tabs: [
<<<<<<< Updated upstream
                              // first tab [you can add an icon using the icon property]
                              Tab(
                                text: 'Personal Goals',
                              ),

                              // second tab [you can add an icon using the icon property]
                              Tab(
                                text: 'Group Goals',
=======
                              Container(
                                width: 400,
                                color: Color(0x69DC9E),
                                child: Center(
                                  child:Text("Personal Goals"),
                                ),
                              ),
                              Container(
                                width: 300,
                                  color: Color(0x69DC9E),
                                child: Center(child:
                                Text("Group Goals"),
                                ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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


=======
                              Stack(
                                  children: <Widget>[
                                  Center(
                                    child: Column(
                                      children: <Widget>[
                                        SingleChildScrollView(child:
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
                                        ),),
                                      ],
                                    )
                                  ),
                                ]
                              ),
>>>>>>> Stashed changes
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
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key? key, required this.tweet}) : super(key: key);
  //final UserModel user;
  final FeedModel tweet;
  @override
  Widget build(BuildContext context) {


    return ListTile(
      onTap: () {
        /*if (kReleaseMode) {
          kAnalytics.logViewSearchResults(searchTerm: user.userName!);
        }*/
        Navigator.push(context, TaskDetailPage.getRoute(tweet));
      },
      //leading: CircularImage(path: user.profilePic, height: 40),

      title:
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 90,
            child: TitleText(tweet.title!,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
<<<<<<< Updated upstream
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
=======
          SizedBox (width: 5),
    SizedBox(
      height: 20,
          width:120,
          child: ListView.builder(
            itemCount: tweet.checkInList?.length ?? 0,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if(tweet.checkInList![index] == true) {
                return Container(
                  width: 15.0,
                  height: 15.0,
                  decoration: new BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                );
              }
              else {
                return Container(
                  width: 15.0,
                  height: 15.0,
                  decoration: new BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                );
              }

            },
          ),
    )
>>>>>>> Stashed changes
        ],
      ),
      subtitle: Text(tweet.description!),
      trailing: tweet.isCheckedIn ? Icon(AppIcon.bulbOn) :
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0)),
          fixedSize: Size(98, 20), //////// HERE
        ),
        onPressed: () async {
          var state = Provider.of<FeedState>(context, listen: false);
          var tempTweet = await state.fetchTweet(tweet.key!);
          tempTweet!.checkInList![tempTweet!.checkInList!.length! - 1] = true;
          FirebaseDatabase.instance.reference().child("tweet").child(tweet.key!).update({
            "checkInList": tempTweet.checkInList,
            "isCheckedIn": true,
          }).then((_) {

          }).catchError((onError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(onError)));
          });
        },
        child: Text(
            'Check In',
          style: TextStyle(
            fontSize: 12,
          ),
        ),

      )
    );
  }
}
<<<<<<< Updated upstream
=======
@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
    i < count;
    i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            backgroundColor: Color(0xFF29AB87),
            foregroundColor: Colors.white,
            onPressed: _toggle,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}
//29AB87
@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Color(0xFF29AB87),
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey.shade300,
      ),
    );
  }
}
>>>>>>> Stashed changes
