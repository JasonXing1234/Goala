import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';

class FriendButton extends StatelessWidget {
  final UserModel? userModel;
  FriendButton({
    required this.userModel,
  });

  void _onPressFriendButton(BuildContext context) {
    cprint("Friend button pressed");
    List<String> usersList = [];

    if (userModel?.friendList != null) {
      usersList = userModel!.friendList!;
    }
    Navigator.push(
      context,
      FollowerListPage.getRoute(profile: userModel!, userList: usersList),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RippleButton(
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
              border:
                  Border.all(color: Colors.black87.withAlpha(180), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),

            /// If [isMyProfile] is true then Edit profile button will display
            // Otherwise Follow/Following button will be display
            child: Text(
              userModel?.friendList == null
                  ? '0 Friends'
                  : userModel?.friendList!.length == 1
                      ? '1 Friend'
                      : '${userModel?.friendList!.length} Friends',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
