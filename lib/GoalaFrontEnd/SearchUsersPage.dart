import 'package:Goala/GoalaFrontEnd/widgets/SearchAppBar.dart';
import 'package:Goala/helper/uiUtility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/GoalaFrontEnd/ProfilePage.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customAppBar.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

import '../model/feedModel.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    final list = state.userlist;
    final groupList = state.groupList;
    return KeyboardDismisser(
      context: context,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: SearchAppBar(
          scaffoldKey: widget.scaffoldKey,
          //icon: AppIcon.settings,
          //onActionPressed: onSettingIconPressed,
          onSearchChanged: (text) {
            state.filterByUsername(text);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            state.getDataFromDatabase();
            return Future.value();
          },
          child: Column(
            children: [
              Flexible(
                child: ListView.separated(
                  addAutomaticKeepAlives: false,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      _UserTile(user: list![index]),
                  separatorBuilder: (_, index) => const Divider(
                    height: 0,
                  ),
                  itemCount: list?.length ?? 0,
                ),
              ),
              Divider(
                height: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (kReleaseMode) {
          kAnalytics.logViewSearchResults(searchTerm: user.userName!);
        }
        Navigator.push(context, ProfilePage.getRoute(profileId: user.userId!));
      },
      leading: CircularImage(path: user.profilePic, height: 40),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: TitleText(user.displayName!,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 3),
          user.isVerified!
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  iconColor: AppColor.primary,
                  size: 13,
                )
              : const SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName!),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({Key? key, required this.user}) : super(key: key);
  final FeedModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (kReleaseMode) {
          kAnalytics.logViewSearchResults(searchTerm: user.title!);
        }
        Navigator.push(context, ProfilePage.getRoute(profileId: user.userId!));
      },
      //leading: CircularImage(path: user.profilePic, height: 40),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: TitleText(user.title!,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 3),
        ],
      ),
      //subtitle: Text(user.!),
    );
  }
}
