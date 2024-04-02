import 'package:Goala/GoalaFrontEnd/widgets/ProfileImage.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/ui/page/profile/profileImageView.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel? userModel;

  ProfileHeader({required this.userModel});

  @override
  State<StatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late List<String> usersList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            // Profile picture
            RippleButton(
              child: ProfileImage(
                path: widget.userModel?.profilePic,
              ),
              borderRadius: BorderRadius.circular(ProfileImage.BORDER_RADIUS),
              onPressed: () {
                Navigator.push(
                  context,
                  ProfileImageView.getRoute(
                    widget.userModel!.profilePic!,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // Name
            Expanded(
              child: Text(
                widget.userModel?.displayName ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                // TODO: Make it Rubik
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColor.PROGRESS_COLOR,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Emoji
            const SizedBox(width: 16),
            Text(
              "🌋",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(width: 16),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RippleButton(
              splashColor: TwitterColor.dodgeBlue_50,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: () {
                if (widget.userModel?.friendList != null) {
                  usersList = widget.userModel!.friendList!;
                } else {
                  usersList = [];
                }
                Navigator.push(
                  context,
                  FollowerListPage.getRoute(
                    profile: widget.userModel!,
                    userList: usersList,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: TwitterColor.white,
                  border: Border.all(
                      color: Colors.black87.withAlpha(180), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),

                /// If [isMyProfile] is true then Edit profile button will display
                // Otherwise Follow/Following button will be display
                child: Text(
                  widget.userModel?.friendList == null
                      ? '${0} Friend'
                      : widget.userModel?.friendList!.length == 1
                          ? '1 Friend'
                          : '${widget.userModel?.friendList!.length} Friends',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
