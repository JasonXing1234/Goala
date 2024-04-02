import 'package:Goala/GoalaFrontEnd/widgets/ProfileImage.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/ui/page/profile/profileImageView.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late List<String> usersList;

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            // Profile picture
            RippleButton(
              child: ProfileImage(
                path: authState.userModel?.profilePic,
              ),
              borderRadius: BorderRadius.circular(ProfileImage.BORDER_RADIUS),
              onPressed: () {
                Navigator.push(
                  context,
                  ProfileImageView.getRoute(
                    authState.profileUserModel!.profilePic!,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // Name
            Expanded(
              child: Text(
                authState.userModel?.displayName ?? "",
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
                if (authState.userModel!.friendList != null) {
                  usersList = authState.userModel!.friendList!;
                } else {
                  usersList = [];
                }
                Navigator.push(
                  context,
                  FollowerListPage.getRoute(
                    profile: authState.userModel!,
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
                  authState.isbusy == true ||
                          authState.userModel?.friendList == null
                      ? '${0} Friend'
                      : authState.userModel?.friendList!.length == 1
                          ? '1 Friend'
                          : '${authState.userModel?.friendList!.length} Friends',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  //Text('${authState.isbusy == true || authState.userModel?.friendList == null ? 0 : authState.userModel?.friendList!.length} Friends',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/*

SliverAppBar(
  expandedHeight: MediaQuery.of(context).size.height * .20,
  floating: false,
  pinned: true,
  flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      background: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add an image widget to display an image
                    // The user profile image
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                          shape: BoxShape.circle),
                      child: RippleButton(
                        child: CircularImage(
                          path: authState.userModel?.profilePic,
                          height: 80,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        onPressed: () {
                          Navigator.push(
                              context,
                              ProfileImageView.getRoute(authState
                                  .profileUserModel!
                                  .profilePic!));
                        },
                      ),
                    ),
                    Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0),
                        alignment: Alignment(10.0, 1),
                        margin: authState.userModel == null
                            ? const EdgeInsets.only(
                                top: 30, right: 20)
                            : authState.userModel!.displayName!
                                        .length <
                                    6
                                ? const EdgeInsets.only(
                                    top: 30, right: 20)
                                : const EdgeInsets.only(
                                    top: 30, right: 0),
                        child: Text(
                          authState.userModel == null
                              ? ''
                              : authState.userModel!.displayName!,
                          style: GoogleFonts.roboto(
                            fontSize: 37,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(
                              right: 5, top: 10),
                          child: RippleButton(
                            splashColor: TwitterColor.dodgeBlue_50
                                .withAlpha(100),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(8)),
                            onPressed: () {
                              if (authState
                                      .userModel!.friendList !=
                                  null) {
                                usersList = authState
                                    .userModel!.friendList!;
                              } else {
                                usersList = [];
                              }
                              Navigator.push(
                                context,
                                FollowerListPage.getRoute(
                                  profile: authState.userModel!,
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
                                    color: Colors.black87
                                        .withAlpha(180),
                                    width: 1),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),

                              /// If [isMyProfile] is true then Edit profile button will display
                              // Otherwise Follow/Following button will be display
                              child: Text(
                                authState.isbusy == true ||
                                        authState.userModel
                                                ?.friendList ==
                                            null
                                    ? '${0} Friend'
                                    : authState
                                                .userModel
                                                ?.friendList!
                                                .length ==
                                            1
                                        ? '1 Friend'
                                        : '${authState.userModel?.friendList!.length} Friends',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                //Text('${authState.isbusy == true || authState.userModel?.friendList == null ? 0 : authState.userModel?.friendList!.length} Friends',
                              ),
                            ),
                          ),
                        ),
                        if (authState.userModel
                                    ?.pendingRequestList !=
                                null &&
                            !authState
                                .userModel!
                                .pendingRequestList!
                                .isEmpty) // Show the red circle if there are new messages
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColor.PROGRESS_COLOR,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                authState.userModel!
                                    .pendingRequestList!.length
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ])
                    ])
                  ],
                ),
              ]))),
),

*/
