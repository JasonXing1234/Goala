import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';

class FriendButton extends StatelessWidget {
  final List<String> friendsList;
  final UserModel? user;
  final bool isCurrentUser;
  final List<String> pendingRequestList;
  FriendButton({
    required this.friendsList,
    required this.user,
    required this.isCurrentUser,
    required this.pendingRequestList,
  });

  // TODO: The right data gets here, but it doesn't show the right page.
  // You can test by putting a breakpoint here and looking at it.
  void _onPressFriendButton(BuildContext context) {
    cprint("Friend button pressed");
    Navigator.push(
      context,
      FollowerListPage.getRoute(profile: user!, userList: friendsList, isMyProfile: isCurrentUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Stack(children: [ Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child:
          RippleButton(
          splashColor: TwitterColor.dodgeBlue_50,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onPressed: () {
            _onPressFriendButton(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: TwitterColor.white,
              border: Border.all(
                color: Colors.black87.withAlpha(180),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              friendsList.length == 1
                  ? '1 Friend'
                  : '${friendsList.length} Friends',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

    ),
        if (!pendingRequestList
            .isEmpty && isCurrentUser) // Show the red circle if there are new messages
          Positioned(
            top: -6,
            right: 9,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColor.PROGRESS_COLOR,
                shape: BoxShape.circle,
              ),
              child: Text(
                pendingRequestList.length
                    .toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ]));
  }
}
