import 'package:Goala/ui/page/common/widget/pendingRequestListWidget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/page/common/widget/userListWidget.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customAppBar.dart';
import 'package:Goala/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

import '../../../helper/utility.dart';
import '../../../state/authState.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({
    Key? key,
    this.pageTitle = "",

    required this.emptyScreenText,
    required this.emptyScreenSubTileText,
    this.userIdsList,
    this.onFollowPressed,
    this.isFollowing,
    this.pendingList, required this.isMyProfile, required this.userID,
  }) : super(key: key);

  final String userID;
  final bool isMyProfile;
  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final bool Function(UserModel user)? isFollowing;
  final List<String>? userIdsList;
  final List<String>? pendingList;
  final Function(UserModel user)? onFollowPressed;

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  late DatabaseReference _databaseReference;
  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref();
  }

  @override
  Widget build(BuildContext context) {
    List<UserModel>? userList;
    List<UserModel>? pendingUserList;
    var state = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
        backgroundColor: TwitterColor.mystic,
        appBar: CustomAppBar(
          isBackButton: true,
          title: Text(
            widget.pageTitle,
            style: TextStyles.bigSubtitleStyle,
          ),
        ),
        body: StreamBuilder(
            stream: kDatabase
                .child('profile')
                .child(widget.userID)
                .onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                var data = (snapshot.data!.snapshot.value as Map);
                var friendList =
                    (data['friendList'] as List?)?.cast<String>() ?? [];
                var pendingRequestList =
                    (data['pendingRequestList'] as List?)?.cast<String>() ?? [];
                return Column(children: [
                  if (!pendingRequestList.isEmpty && widget.isMyProfile)
                    Text('Friend Requests', style: TextStyles.bigSubtitleStyle),
                  if (!pendingRequestList.isEmpty && widget.isMyProfile)
                    Consumer<SearchState>(
                      builder: (context, state, child) {
                        if (pendingRequestList.isNotEmpty) {
                          pendingUserList =
                              state.getuserDetail(pendingRequestList);
                        }
                        return pendingRequestList.isNotEmpty
                            ? pendingListWidget(
                                list: pendingUserList!,
                                emptyScreenText: widget.emptyScreenText,
                                emptyScreenSubTileText:
                                    widget.emptyScreenSubTileText,
                              )
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    top: 0, left: 30, right: 30),
                                child: NotifyText(
                                  title: widget.emptyScreenText,
                                  subTitle: widget.emptyScreenSubTileText,
                                ),
                              );
                      },
                    ),
                  if (!pendingRequestList.isEmpty) SizedBox(height: 60),
                  Consumer<SearchState>(
                    builder: (context, state, child) {
                      if (friendList.isNotEmpty) {
                        userList = state.getuserDetail(friendList);
                      }
                      return userList != null && userList!.isNotEmpty
                          ? Column(children: [
                              Text('Friends', style: TextStyles.bigSubtitleStyle,),
                              UserListWidget(
                                list: userList!,
                                emptyScreenText: widget.emptyScreenText,
                                emptyScreenSubTileText:
                                    widget.emptyScreenSubTileText,
                                onFollowPressed: widget.onFollowPressed,
                                isFollowing: widget.isFollowing,
                              )
                            ])
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                  top: 0, left: 30, right: 30),
                              child: NotifyText(
                                title: widget.emptyScreenText,
                                subTitle: widget.emptyScreenSubTileText,
                              ),
                            );
                    },
                  ),
                ]);
              } else {
                return CircularProgressIndicator(); // Loading indicator
              }
            }));
  }
}
