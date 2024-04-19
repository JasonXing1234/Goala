import 'dart:io';
import 'package:Goala/helper/uiUtility.dart';
import 'package:Goala/ui/styleConstants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Goala/helper/constant.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:Goala/ui/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customAppBar.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import '../model/GoalNotificationModel.dart';
import '../widgets/newWidget/customMultiSelectChips.dart';

class EditGoal extends StatefulWidget {
  const EditGoal({Key? key, required this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  @override
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<EditGoal>
    with TickerProviderStateMixin {
  bool isScrollingDown = false;
  late FeedModel? model;
  late ScrollController scrollController;

  File? _image;
  DateTime selectedDate = DateTime.now();
  bool dateSelected = false;
  late TextEditingController _descriptionController;
  late TextEditingController _titleController;
  late TextEditingController _goalSumController;
  late TextEditingController _goalUnitController;
  late TabController _tabController;
  late final List<String> memberListTemp = [];
  List<bool> isSelected = [true, false];
  List<bool> _selections = [false, false];
  TimeOfDay? pickedTime;
  final List<String> days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
  List<bool> daySelected = List.filled(7, true);
  List<String?> friendTemp = [];

  @override
  void dispose() {
    scrollController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _goalUnitController.dispose();
    _goalSumController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    _tabController = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    _descriptionController =
        TextEditingController(text: model == null ? '' : model!.description);
    _goalSumController = TextEditingController(
        text: model == null || model?.GoalSum == null
            ? ''
            : model!.GoalSum.toString());
    _goalUnitController = TextEditingController(
        text: model == null || model?.goalUnit == null
            ? ''
            : model!.goalUnit.toString());
    _titleController =
        TextEditingController(text: model == null ? '' : model!.title);
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        Provider.of<ComposeTweetState>(context, listen: false)
            .setIsScrollingDown = true;
      }
    }
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<ComposeTweetState>(context, listen: false)
          .setIsScrollingDown = false;
    }
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
    });
  }

  void _onImageIconSelected(File file) {
    setState(() {
      _image = file;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // The earliest allowable date
      lastDate: DateTime(2025), // The latest allowable date
      // You can also add more arguments to customize the DatePicker, like `initialDatePickerMode` and `helpText`.
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        dateSelected = true;
        selectedDate = picked;
      });
    }
  }

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    if (_descriptionController.text.isEmpty ||
        _descriptionController.text.length > 1000 ||
        _titleController.text.isEmpty ||
        _titleController.text.length > 10 ||
        pickedTime == null) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenLoader.showLoader(context);

    List<GoalNotiModel> NotiModelList = [];
    await changeTweetModel();
    for (int i = 0; i < daySelected.length; i++) {
      if (daySelected[i]) {
        // Send each selected day with the time to the database
        GoalNotiModel NotiModel = await createNotiModel(i + 1, model!.key!);
        NotiModelList.add(NotiModel);
      }
    }
    if (model!.parentkey == null && daySelected.contains(true)) {
      state.sendToDatabase(NotiModelList);
    }
    kScreenLoader.hideLoader();
    Navigator.pop(context);
  }

  Future<GoalNotiModel> createNotiModel(int day, String feedID) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    final _messaging = FirebaseMessaging.instance;
    String? tempToken = await _messaging.getToken();
    GoalNotiModel temp = GoalNotiModel(
        tempToken!, day, feedID, '${pickedTime!.hour}:${pickedTime!.minute}');
    return temp;
  }

  /// Return Tweet model which is either a new Tweet , retweet model or comment model
  /// If tweet is new tweet then `parentkey` and `childRetwetkey` should be null
  /// IF tweet is a comment then it should have `parentkey`
  /// IF tweet is a retweet then it should have `childRetwetkey`
  Future changeTweetModel() async {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    var profilePic = myUser!.profilePic ?? Constants.dummyProfilePic;
    memberListTemp.add(myUser.userId!);
    //memberListTemp.add(_addUserController.text);
    /// User who are creating reply tweet

    var tags = Utility.getHashTags(_descriptionController.text);
    final databaseReference = FirebaseDatabase.instance.ref();

    // The specific post you want to update
    DatabaseReference postRef = databaseReference.child('tweet/${model!.key}');
    // Fields you want to update
    postRef.update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'createdAt': DateTime.now().toUtc().toString(),
      'memberList': friendTemp,
      'GoalSum': state.tweetToReplyModel!.isHabit == true
          ? null
          : widget.isTweet
              ? state.tweetToReplyModel!.isHabit == true
                  ? 0
                  : int.parse(_goalSumController.text)
              : 0,
      'goalUnit': _goalUnitController.text,
      'deadlineDate':
          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
    }).then((_) {
      print('Post updated successfully');
    }).catchError((error) {
      print('Failed to update post: $error');
    });

    final query = await databaseReference
        .child('GoalNotifications')
        .orderByChild('GoalID')
        .equalTo(model!.key);
    final snapshot = await query.once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> data =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        kDatabase.child('GoalNotifications').child(key).remove().then((_) {
          print('Post with parentkey $key removed successfully');
        }).catchError((error) {
          print('Error removing post with key $key: $error');
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _multiSelectKey = GlobalKey<FormFieldState>();
    var authState = Provider.of<AuthState>(context, listen: false);
    var searchstate = Provider.of<SearchState>(context);
    var feedstate = Provider.of<FeedState>(context);
    List<UserModel?> selectedUsers = [];
    List<UserModel?> FriendList = [];
    List<String> tempString = authState.userModel!.followingList!;
    tempString.removeWhere(
        (item) => feedstate.tweetToReplyModel!.memberList!.contains(item));
    if (tempString.isNotEmpty) {
      for (int i = 0; i < tempString.length; i++) {
        FriendList = searchstate.getuserDetail(tempString);
      }
    }
    return KeyboardDismisser(
      context: context,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: customTitleText(''),
          onActionPressed: _submitButton,
          isCrossButton: true,
          submitButtonText: widget.isTweet
              ? 'Commit'
              : widget.isRetweet
                  ? 'Retweet'
                  : 'Comment',
          isSubmitDisable:
              !Provider.of<ComposeTweetState>(context).enableSubmitButton ||
                  Provider.of<FeedState>(context).isBusy,
          isBottomLine: Provider.of<ComposeTweetState>(context).isScrollingDown,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          //!Removed container
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollController,
              child: Container(
                height: context.height,
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.isTweet)
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: TextFormField(
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            controller: _titleController,
                            textAlign: TextAlign.center,
                            maxLength: 50,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "title"),
                          ),
                        ),
                      ),
                    if (widget.isTweet)
                      Center(
                        child: SizedBox(
                          width: 340,
                          child: TextFormField(
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            controller: _descriptionController,
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "description"),
                          ),
                        ),
                      ),
                    if (widget.isTweet && model!.isHabit == false)
                      SizedBox(
                        height: 10,
                      ),
                    if (widget.isTweet && model!.isHabit == false)
                      SizedBox(
                        height: 15,
                      ),
                    if (widget.isTweet && model!.isHabit == false)
                      Center(
                          child: Row(
                        children: [
                          SizedBox(width: 80),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              controller: _goalSumController,
                              textAlign: TextAlign.center,
                              decoration:
                                  kTextFieldDecoration.copyWith(hintText: "#"),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              controller: _goalUnitController,
                              textAlign: TextAlign.center,
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: "Units"),
                            ),
                          ),
                        ],
                      )),
                    if (widget.isTweet && model!.isHabit == false)
                      SizedBox(height: 10),
                    if (widget.isTweet && model!.isHabit == false)
                      Row(
                        children: [
                          SizedBox(width: 58),
                          customTitleText('Complete By:'),
                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () => _selectDate(
                                context), // Call the _selectDate function when the button is pressed
                            child: dateSelected == true
                                ? Text(
                                    "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}")
                                : Text('Select Date'),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 20,
                    ),
                    if (widget.isTweet && model!.isGroupGoal == true)
                      ChildWidget(
                        friends: FriendList,
                        onSelectionChanged: (updatedFriends) {
                          setState(() {
                            memberListTemp.clear();
                            List<String> temp = [];
                            for (int i = 0; i < updatedFriends.length; i++) {
                              temp.add(updatedFriends[i]!.userId!);
                            }
                            memberListTemp.addAll(temp);
                            friendTemp =
                                feedstate.tweetToReplyModel!.memberList!;
                            friendTemp.addAll(memberListTemp);
                          });
                        }, buttonText: '+ Add Group Members',
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Center(
                          child: Wrap(
                            children: List.generate(days.length, (index) {
                              return Padding(
                                padding: EdgeInsets.all(1.0),
                                child: ChoiceChip(
                                  selectedColor: AppColor.PROGRESS_COLOR,
                                  showCheckmark: false,
                                  label: Text(days[index]),
                                  selected: daySelected[index],
                                  onSelected: (bool selected) {
                                    setState(() {
                                      daySelected[index] = selected;
                                    });
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                pickedTime = time;
                              });
                            }
                          },
                          child: pickedTime == null
                              ? Text('Pick a Time')
                              : Text(pickedTime.toString().substring(10, 15)),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Stack(
                        children: <Widget>[
                          ComposeTweetImage(
                            image: _image,
                            onCrossIconPressed: _onCrossIconPressed,
                          ),
                          _UserList(
                            list: Provider.of<SearchState>(context).userlist,
                            textEditingController: _descriptionController,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({Key? key, this.list, required this.textEditingController})
      : super(key: key);
  final List<UserModel>? list;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return !Provider.of<ComposeTweetState>(context).displayUserList ||
            list == null ||
            list!.length < 0 ||
            list!.isEmpty
        ? const SizedBox.shrink()
        : Container(
            padding: const EdgeInsetsDirectional.only(bottom: 50),
            color: TwitterColor.white,
            constraints:
                const BoxConstraints(minHeight: 30, maxHeight: double.infinity),
            child: ListView.builder(
              itemCount: list!.length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return _UserTile(
                  user: list![index],
                  onUserSelected: (user) {
                    textEditingController.text =
                        Provider.of<ComposeTweetState>(context, listen: false)
                                .getDescription(user.userName!) +
                            " ";
                    textEditingController.selection = TextSelection.collapsed(
                        offset: textEditingController.text.length);
                    Provider.of<ComposeTweetState>(context, listen: false)
                        .onUserSelected();
                  },
                );
              },
            ),
          );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key? key, required this.user, required this.onUserSelected})
      : super(key: key);
  final UserModel user;
  final ValueChanged<UserModel> onUserSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onUserSelected(user);
      },
      leading: CircularImage(path: user.profilePic, height: 35),
      title: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 0, maxWidth: context.width * .5),
            child: TitleText(user.displayName!,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 3),
          user.isVerified!
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  iconColor: AppColor.primary,
                  size: 13,
                )
              : const SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName!),
    );
  }
}
