import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/common/usersListPage.dart';
import 'package:Goala/ui/page/profile/follow/followListState.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class FollowingListPage extends StatelessWidget {
  const FollowingListPage(
      {Key? key, required this.profile, required this.userList})
      : super(key: key);
  final List<String> userList;
  final UserModel profile;

  static MaterialPageRoute getRoute(
      {required List<String> userList, required UserModel profile}) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => FollowListState(StateType.following),
          child: FollowingListPage(profile: profile, userList: userList),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<FollowListState>().isbusy) {
      return SizedBox(
        height: context.height,
        child: const CustomScreenLoader(
          height: double.infinity,
          width: double.infinity,
          backgroundColor: Colors.white,
        ),
      );
    }
    return UsersListPage(
      isMyProfile: false,
      pageTitle: 'Following',
      userIdsList: userList,
      emptyScreenText:
          '${profile.userName ?? profile.userName} isn\'t follow anyone',
      emptyScreenSubTileText: 'When they do they\'ll be listed here.',
      onFollowPressed: (user) {
        context.read<FollowListState>().followUser(user);
      },
      isFollowing: (user) {
        return context.watch<FollowListState>().isFollowing(user);
      }, userID: profile.userId!,
    );
  }
}
