import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/common/usersListPage.dart';
import 'package:Goala/ui/page/profile/follow/followListState.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  const FollowerListPage({Key? key, this.userList, this.profile, required this.isMyProfile})
      : super(key: key);
  final List<String>? userList;
  final UserModel? profile;
  final bool isMyProfile;

  static MaterialPageRoute getRoute(
      {required List<String> userList, required UserModel profile, required bool isMyProfile}) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => FollowListState(StateType.follower),
          child: FollowerListPage(userList: userList, profile: profile, isMyProfile: isMyProfile),
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
      isMyProfile: isMyProfile,
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
      }, userID: profile!.userId!,
    );
  }
}
