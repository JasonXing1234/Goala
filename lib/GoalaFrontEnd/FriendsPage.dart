import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/common/usersListPage.dart';
import 'package:Goala/ui/page/profile/follow/followListState.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

import '../state/authState.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({Key? key, required this.profile, required this.userList})
      : super(key: key);
  final List<String> userList;
  final UserModel profile;

  static MaterialPageRoute getRoute(
      {required List<String> userList, required UserModel profile}) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => FollowListState(StateType.following),
          child: FriendsPage(profile: profile, userList: userList),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
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
      pageTitle: 'Following',
      userIdsList: userList,
      isMyProfile: profile.userId == state.userModel!.userId,
      emptyScreenText:
          '${profile.userName ?? profile.userName} isn\'t follow anyone',
      emptyScreenSubTileText: 'When they do they\'ll be listed here.',
      onFollowPressed: (user) {
        context.read<FollowListState>().followUser(user);
      },
      isFollowing: (user) {
        return context.watch<FollowListState>().isFollowing(user);
      },
      pendingList: state.userModel!.pendingRequestList!,
      userID: profile.userId!,
    );
  }
}
