import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:Goala/widgets/newWidget/emptyList.dart';
import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:Goala/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  const FeedPage(
      {Key? key, required this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
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
              return Future.value(true);
            },
            child: Consumer<FeedState>(
              builder: (context, state, child) {
                //only show posts under the main goals, don't show the comments under the posts
                final List<FeedModel>? list = state
                    .getCommentList(authState.userModel)
                    ?.where((x) => x.grandparentKey == null && ((!x.isPrivate && x.visibleUsersList == null) || (!x.isPrivate && x.visibleUsersList != null && x.visibleUsersList!.contains(authState.userModel!.userId))))
                    .toList();
                return CustomScrollView(
                  slivers: <Widget>[
                    child!,
                    state.isBusy && list == null
                        ? SliverToBoxAdapter(
                            child: SizedBox(
                              height: context.height - 135,
                              child: CustomScreenLoader(
                                height: double.infinity,
                                width: double.infinity,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          )
                        : !state.isBusy && list == null
                            ? const SliverToBoxAdapter(
                                child: EmptyList(
                                  'No Posts added yet',
                                  subTitle: '',
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildListDelegate(
                                  list!.map(
                                    (model) {
                                      return Container(
                                        color: Colors.white,
                                        child: Tweet(
                                          model: model,
                                          trailing: TweetBottomSheet()
                                              .tweetOptionIcon(context,
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
                  ],
                );
              },
              child: SliverAppBar(
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
                title: Text('Feed'),
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
                actions: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                          icon: Icon(Icons.notifications_active),
                          onPressed: () {
                            scaffoldKey.currentState!.openEndDrawer();
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
