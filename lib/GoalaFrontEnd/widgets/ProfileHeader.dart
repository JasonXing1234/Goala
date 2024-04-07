import 'package:Goala/GoalaFrontEnd/widgets/FriendButton.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileImage.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/profile/profileImageView.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../state/profile_state.dart';
import '../../ui/page/profile/EditProfilePage.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel? userModel;
  final bool isCurrentUser;
  final bool isMyProfile;
  ProfileHeader({
    required this.userModel,
    this.isCurrentUser = true, required this.isMyProfile,
  });

  @override
  State<StatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? isFollower() {
    var authState = Provider.of<ProfileState>(context, listen: false);
    if (authState.isbusy == false) {
      if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId) == false ||
          authState.profileUserModel.followingList?.any((x) => x == authState.userId) ==
              null) &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId) == false ||
              authState.userModel.followingList?.any((x) => x == authState.profileId) ==
                  null)) {
        return "Add Friend";
      } else if (authState.profileUserModel.followingList?.any((x) => x == authState.userId) == true &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId) == false ||
              authState.userModel.followingList?.any((x) => x == authState.profileId) ==
                  null)) {
        return "Accept Friend Request";
      } else if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId) == false ||
          authState.profileUserModel.followingList
              ?.any((x) => x == authState.userId) ==
              null) &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId)) ==
              true) {
        return "Friend Request Sent";
      } else if ((authState.profileUserModel.followingList?.any((x) => x == authState.userId)) == true &&
          (authState.userModel.followingList?.any((x) => x == authState.profileId)) == true) {
        return "Friend Added";
      }
    }
    return "";
  }

  bool isFriendRequestSent() {
    var authState = Provider.of<ProfileState>(context, listen: false);
    if (authState.profileUserModel.followingList != null &&
        authState.profileUserModel.followingList!.isNotEmpty &&
        authState.userModel.followingList != null &&
        authState.userModel.followingList!.isNotEmpty) {
      return (authState.profileUserModel.followingList!
          .any((x) => x == authState.userId)) &&
          (authState.userModel.followingList!
              .any((x) => x == authState.profileId));
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<ProfileState>(context, listen: false);
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
                style: GoogleFonts.rubik().copyWith(
                  fontSize: 30,
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
        SizedBox(
          height: 20,
        ),
        Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children:[
            widget.isMyProfile == true ? SizedBox.shrink() : RippleButton(
              splashColor: TwitterColor.dodgeBlue_50.withAlpha(100),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: () {
                setState(() {
                  if (widget.isMyProfile) {
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
                  color: widget.isMyProfile
                      ? TwitterColor.white
                      : authState.isbusy
                      ? AppColor.PROGRESS_COLOR
                      : isFollower() == "Friend Added"
                      ? AppColor.PROGRESS_COLOR
                      : TwitterColor.white,
                  border: Border.all(
                      color: widget.isMyProfile
                          ? Colors.black87.withAlpha(180)
                          : AppColor.PROGRESS_COLOR,
                      width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),

                /// If [isMyProfile] is true then Edit profile button will display
                // Otherwise Follow/Following button will be display
                child: Text(
                  widget.isMyProfile
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
                    color: widget.isMyProfile
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
              FriendButton(
                friendsList: widget.userModel?.friendList ?? [],
                user: widget.userModel,
                isCurrentUser: widget.isCurrentUser,
              ),
          ])),
      ],
    );
  }
}
