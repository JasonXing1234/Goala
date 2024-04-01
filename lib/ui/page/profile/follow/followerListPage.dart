import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/common/usersListPage.dart';
import 'package:Goala/ui/page/profile/follow/followListState.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  const FollowerListPage({Key? key, this.userList, this.profile})
      : super(key: key);
  final List<String>? userList;
  final UserModel? profile;

  static MaterialPageRoute getRoute(
      {required List<String> userList, required UserModel profile}) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => FollowListState(StateType.follower),
          child: FollowerListPage(userList: userList, profile: profile),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String>? tempList = [];
    if (profile!.pendingRequestList != null &&
        !profile!.pendingRequestList!.isEmpty) {
      tempList = profile!.pendingRequestList;
    }
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
      pageTitle: 'Your Friends',
      userIdsList: userList,
      pendingList: tempList,
      emptyScreenText: 'You don\'t have friends yet',
      emptyScreenSubTileText: 'Invite your friends to use the app!',
      isFollowing: (user) {
        return context.watch<FollowListState>().isFollowing(user);
      },
      onFollowPressed: (user) {
        context.read<FollowListState>().followUser(user);
      },
    );
  }
}
