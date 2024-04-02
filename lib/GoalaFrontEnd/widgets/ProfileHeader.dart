import 'package:Goala/GoalaFrontEnd/widgets/ProfileImage.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/ui/page/profile/profileImageView.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel? userModel;
  // TODO: Move the CurrentProfileHeader and the Profile Header into one file here
  final bool isCurrentUser;
  ProfileHeader({
    required this.userModel,
    this.isCurrentUser = true,
  });

  @override
  State<StatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
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
      ],
    );
  }
}

/*
AnimatedContainer(
duration: const Duration(milliseconds: 500),
decoration: BoxDecoration(
    border: Border.all(color: Colors.white, width: 5),
    shape: BoxShape.circle),
child: RippleButton(
  child: authState.isbusy
      ? const SizedBox.shrink()
      : CircularImage(
          path: authState.profileUserModel.profilePic!,
          height: 80,
        ),
  borderRadius: BorderRadius.circular(50),
  onPressed: () {
    Navigator.push(
        context,
        ProfileImageView.getRoute(
            authState.profileUserModel.profilePic!));
  },
),
),
const SizedBox(width: 10),
RippleButton(
splashColor: TwitterColor.dodgeBlue_50.withAlpha(100),
borderRadius: const BorderRadius.all(Radius.circular(8)),
onPressed: () {
  setState(() {
    if (isMyProfile) {
      Navigator.push(context, EditProfilePage.getRoute());
    } else {
      if (isFollower() == "Add Friend") {
        authState.addFriend();
      } else if (isFollower() == "Friend Request Sent") {
      } else if (isFollower() == "Accept Friend Request") {
        authState.acceptFriendRequest();
      } else if (isFollower() == "Friend Added") {}
    }
  });
},
child: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  ),
  decoration: BoxDecoration(
    color: isMyProfile
        ? TwitterColor.white
        : authState.isbusy
            ? AppColor.PROGRESS_COLOR
            : isFollower() == "Friend Added"
                ? AppColor.PROGRESS_COLOR
                : TwitterColor.white,
    border: Border.all(
        color: isMyProfile
            ? Colors.black87.withAlpha(180)
            : AppColor.PROGRESS_COLOR,
        width: 1),
    borderRadius: BorderRadius.circular(8),
  ),

  /// If [isMyProfile] is true then Edit profile button will display
  // Otherwise Follow/Following button will be display
  child: Text(
    isMyProfile
        ? 'Edit Profile'
        : isFollower() == "Add Friend"
            ? 'Add Friend'
            : isFollower() == "Friend Request Sent"
                ? 'Friend Request Sent'
                : isFollower() == "Accept Friend Request"
                    ? 'Accept Friend Request'
                    : isFollower() == "Friend Added"
                        ? 'Friend Added'
                        : '',
    style: TextStyle(
      color: isMyProfile
          ? Colors.black87.withAlpha(180)
          : isFollower() == "Friend Added"
              ? TwitterColor.white
              : Colors.black,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
  ),
),
),
],
),
*/