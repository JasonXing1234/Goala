import 'package:flutter/material.dart';
import 'package:Goala/helper/constant.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/ui/page/profile/follow/followingListPage.dart';
import 'package:Goala/GoalaFrontEnd/ProfilePage.dart';
import 'package:Goala/ui/page/profile/qrCode/scanner.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

import '../../../GoalaFrontEnd/TaskDetailPage.dart';
import '../../../model/feedModel.dart';
import '../../../state/feedState.dart';

class groupSidebarMenu extends StatefulWidget {
  const groupSidebarMenu({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<groupSidebarMenu> {
  Widget _menuHeader() {
    final state = context.watch<AuthState>();
    if (state.userModel == null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, minHeight: 100),
        child: Center(
          child: Text(
            'Login to continue',
            style: TextStyles.onPrimaryTitleText,
          ),
        ),
      ).ripple(() {
        _logOut();
      });
    } else {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 56,
              width: 56,
              margin: const EdgeInsets.only(left: 17, top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    state.userModel!.profilePic ?? Constants.dummyProfilePic,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    ProfilePage.getRoute(profileId: state.userModel!.userId!));
              },
              title: Row(
                children: <Widget>[
                  UrlText(
                    text: state.userModel!.displayName ?? "",
                    style: TextStyles.onPrimaryTitleText
                        .copyWith(color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  state.userModel!.isVerified ?? false
                      ? customIcon(
                          context,
                          icon: AppIcon.blueTick,
                          iconColor: AppColor.primary,
                          size: 18,
                        )
                      : const SizedBox(
                          width: 0,
                        ),
                ],
              ),
              subtitle: customText(
                state.userModel!.userName,
                style: TextStyles.onPrimarySubTitleText
                    .copyWith(color: Colors.black54, fontSize: 15),
              ),
              trailing: customIcon(
                context,
                icon: AppIcon.arrowDown,
                iconColor: AppColor.primary,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 17,
                  ),
                  _textButton(context, state.userModel!.getFollower,
                      ' Followers', 'FollowerListPage'),
                  const SizedBox(width: 10),
                  _textButton(context, state.userModel!.getFollowing,
                      ' Following', 'FollowingListPage'),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _textButton(
      BuildContext context, String count, String text, String navigateTo) {
    return InkWell(
      onTap: () {
        var authState = context.read<AuthState>();
        late List<String> usersList;
        authState.getProfileUser();
        Navigator.pop(context);
        switch (navigateTo) {
          case "FollowerListPage":
            usersList = authState.userModel!.followersList!;
            Navigator.push(
              context,
              FollowerListPage.getRoute(
                profile: authState.userModel!,
                userList: usersList,
              ),
            );
            break;
          case "FollowingListPage":
            usersList = authState.userModel!.followingList!;
            Navigator.push(
              context,
              FollowingListPage.getRoute(
                profile: authState.userModel!,
                userList: usersList,
              ),
            );
            break;
        }
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          customText(
            text,
            style: const TextStyle(color: AppColor.darkGrey, fontSize: 17),
          ),
        ],
      ),
    );
  }

  ListTile _menuListRowButton(String title,
      {Function? onPressed, IconData? icon, bool isEnable = false}) {
    return ListTile(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      leading: icon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 5),
              child: customIcon(
                context,
                icon: icon,
                size: 25,
                iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
              ),
            ),
      title: customText(
        title,
        style: TextStyle(
          fontSize: 20,
          color: isEnable ? AppColor.secondary : AppColor.lightGrey,
        ),
      ),
    );
  }

  Positioned _footer() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Column(
        children: <Widget>[
          const Divider(height: 0),
          Row(
            children: <Widget>[
              const SizedBox(
                width: 10,
                height: 45,
              ),
              customIcon(
                context,
                icon: AppIcon.bulbOn,
                size: 25,
                iconColor: TwitterColor.dodgeBlue,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      ScanScreen.getRoute(
                          context.read<AuthState>().profileUserModel!));
                },
                child: Image.asset(
                  "assets/images/qr.png",
                  height: 25,
                ),
              ),
              const SizedBox(
                width: 0,
                height: 45,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _logOut() {
    final state = Provider.of<AuthState>(context, listen: false);
    Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context, listen: false);
    List<FeedModel>? GroupList = [];
    String id = authState.userId;
    if (state.feedList != null && state.feedList!.isNotEmpty) {
      GroupList = state.feedList!
          .where((x) => x.memberList!.contains(id) && x.isGroupGoal == true)
          .toList();
    }
    return SizedBox(
        width: 200,
        child: Center(
            child: Drawer(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(bottom: 45),
                    child: Column(children: [
                      Text(
                        'Groups',
                        style: TextStyles.titleStyle,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListView(
                        // This next line does the trick.
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: GroupList.asMap().entries.map(
                          (model) {
                            return Row(children: [
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    state.getPostDetailFromDatabase(null,
                                        model: model.value);
                                  });
                                  Navigator.push(context,
                                      TaskDetailPage.getRoute(model.value));
                                },
                                child: Text(model.value.title!,
                                    style: TextStyles.onGreenButtonText),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xFF29AB87)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      // Change your radius here
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ]);
                          },
                        ).toList(),
                      ),
                    ])),
                _footer()
              ],
            ),
          ),
        )));
  }
}
