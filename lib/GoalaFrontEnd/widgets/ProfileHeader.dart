import 'package:Goala/GoalaFrontEnd/widgets/FriendButton.dart';
import 'package:Goala/GoalaFrontEnd/widgets/ProfileImage.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/profile/profileImageView.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel? userModel;
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
        FriendButton(
          friendsList: widget.userModel?.friendList ?? [],
          user: widget.userModel,
          isCurrentUser: widget.isCurrentUser,
        ),
      ],
    );
  }
}
