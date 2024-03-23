import 'package:flutter/material.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/GoalaFrontEnd/profilePage.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/newWidget/rippleButton.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import '../../../../state/profile_state.dart';

class pendingListWidget extends StatefulWidget {
  final List<UserModel> list;

  final String? emptyScreenText;
  final String? emptyScreenSubTileText;
  const pendingListWidget({
    Key? key,
    required this.list,
    this.emptyScreenText,
    this.emptyScreenSubTileText,
  }) : super(key: key);

  @override
  State<pendingListWidget> createState() => _pendingListWidgetState();
}

class _pendingListWidgetState extends State<pendingListWidget> {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    final currentUser = state.userModel!;
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return UserTile(
          user: widget.list[index],
          currentUser: currentUser,
          onTrailingPressed: () {
            setState(() {
              state.acceptFriendRequest2(widget.list[index]);
            });
          },
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 0,
        );
      },
      itemCount: widget.list.length,
    );
  }
}

class UserTile extends StatefulWidget {
  const UserTile({
    Key? key,
    required this.user,
    required this.currentUser,
    required this.onTrailingPressed,
    this.trailing,
    this.isFollowing,
  }) : super(key: key);
  final UserModel user;

  /// User profile of logged-in user
  final UserModel currentUser;
  final VoidCallback onTrailingPressed;
  final Widget? trailing;
  final bool Function(UserModel user)? isFollowing;

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: TwitterColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.push(
                  context, ProfilePage.getRoute(profileId: widget.user.userId!));
            },
            leading: RippleButton(
              onPressed: () {
                Navigator.push(
                    context, ProfilePage.getRoute(profileId: widget.user.userId!));
              },
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child: CircularImage(path: widget.user.profilePic, height: 55),
            ),
            title: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints:
                  BoxConstraints(minWidth: 0, maxWidth: context.width * .4),
                  child: Text(widget.user.displayName!,
                      style: TextStyles.subtitleStyle,),
                ),
                const SizedBox(width: 3),
                widget.user.isVerified!
                    ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  iconColor: AppColor.primary,
                  size: 13,
                )
                    : const SizedBox(width: 0),
              ],
            ),
            //subtitle: Text(widget.user.userName!),
            trailing: RippleButton(
              onPressed: widget.onTrailingPressed,
              splashColor: TwitterColor.dodgeBlue_50.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
              child: widget.trailing ??
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: TwitterColor.white,
                      border:
                      Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Accept Request',
                      style: TextStyles.subtitleStyle14
                    ),
                  ),
            ),
          ),

        ],
      ),
    );
  }
}
