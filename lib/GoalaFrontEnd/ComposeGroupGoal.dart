import 'dart:io';
import 'package:Goala/helper/uiUtility.dart';
import 'package:Goala/ui/styleConstants.dart';
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
import 'package:translator/translator.dart';
import '../model/GoalNotificationModel.dart';
import '../widgets/newWidget/customMultiSelectChips.dart';
import '../widgets/newWidget/customizedTitleText.dart';

class ComposeGroupGoal extends StatefulWidget {
  const ComposeGroupGoal(
      {Key? key, required this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  @override
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeGroupGoal>
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
  late TextEditingController _addUserController;
  late TabController _tabController;
  late final List<String> memberListTemp = [];
  late final List<String> visibleListTemp = [];
  bool _showDropdown = false;
  bool isPrivate = false;
  int _selectedButtonIndex = 0;
  List<bool> isSelected = [true, false];
  List<bool> visibility = [true, false, false];
  TimeOfDay? pickedTime;
  final List<String> days = [' M ', ' T ', ' W ', 'Th', ' F ', ' S ', 'Su'];
  List<bool> daySelected = List.filled(7, true);

  @override
  void dispose() {
    scrollController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _addUserController.dispose();
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
    _descriptionController = TextEditingController();
    _goalSumController = TextEditingController();
    _goalUnitController = TextEditingController();
    _titleController = TextEditingController();
    _addUserController = TextEditingController();
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

  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Submit tweet to save in firebase database
  /// TODO: We need to make a snackbar to show the user why they can't submit their goal if they don't fill everything out right.
  void _submitButton() async {
    if (
        _descriptionController.text.length > 200) {
      _showErrorMessage(context, 'Please keep description shorter than 200 characters');
      return;
    }
    if (_titleController.text.isEmpty || _titleController.text.length > 15) {
      _showErrorMessage(context, 'Please fill out title');
      return;
    }
    if (pickedTime == null) {
      _showErrorMessage(context, 'Please pick notification time');
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenLoader.showLoader(context);

    List<GoalNotiModel> NotiModelList = [];
    FeedModel tweetModel = await createTweetModel();

    String? tweetId;

    /// If tweet contain image
    /// First image is uploaded on firebase storage
    /// After successful image upload to firebase storage it returns image path
    /// Add this image path to tweet model and save to firebase database
    if (_image != null) {
      await state.uploadFile(_image!).then((imagePath) async {
        if (imagePath != null) {
          tweetModel.imagePath = imagePath;

          /// If type of tweet is new tweet
          if (widget.isTweet) {
            tweetId = await state.createTweet(tweetModel);
          }

          /// If type of tweet is  retweet
          else if (widget.isRetweet) {
            tweetId = await state.createReTweet(tweetModel);
          }

          /// If type of tweet is new comment tweet
          else {
            tweetId = await state.addCommentToPost(tweetModel);
          }
        }
      });
    }

    /// If tweet did not contain image
    else {
      /// If type of tweet is new tweet
      if (widget.isTweet) {
        tweetId = await state.createTweet(tweetModel);
        for (int i = 0; i < daySelected.length; i++) {
          if (daySelected[i]) {
            // Send each selected day with the time to the database
            GoalNotiModel NotiModel = await createNotiModel(i + 1, tweetId!);
            NotiModelList.add(NotiModel);
          }
        }
        if (tweetModel.parentkey == null && daySelected.contains(true)) {
          state.sendToDatabase(NotiModelList);
        }
      }

      /// If type of tweet is  retweet
      else if (widget.isRetweet) {
        tweetId = await state.createReTweet(tweetModel);
      }

      /// If type of tweet is new comment tweet
      else {
        tweetId = await state.addCommentToPost(tweetModel);
        if (tweetModel.goalPhotoList!.length != 0) {
          state.uploadCoverPhoto(tweetModel.goalPhotoList?[0]);
        }
      }
    }
    tweetModel.key = tweetId;

    /// Checks for username in tweet description
    /// If username found, sends notification to all tagged user
    /// If no user found, compose tweet screen is closed and redirect back to home page.
    await Provider.of<ComposeTweetState>(context, listen: false)
        .sendNotification(
            tweetModel, Provider.of<SearchState>(context, listen: false))
        .then((_) {
      /// Hide running loader on screen
      kScreenLoader.hideLoader();

      /// Navigate back to home page
      Navigator.pop(context);
    });
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
  Future<FeedModel> createTweetModel() async {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    var profilePic = myUser!.profilePic ?? Constants.dummyProfilePic;
    memberListTemp.add(myUser.userId!);
    visibleListTemp.add(myUser.userId!);
    //memberListTemp.add(_addUserController.text);
    /// User who are creating reply tweet
    var commentedUser = UserModel(
        displayName: myUser.displayName ?? myUser.email!.split('@')[0],
        profilePic: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel!.isVerified,
        userName: authState.userModel!.userName);
    var tags = Utility.getHashTags(_descriptionController.text);
    FeedModel reply = FeedModel(
      isComment: false,
      isGroupGoal: memberListTemp.length == 1 ? false : true,
      title: _titleController.text,
      description: _descriptionController.text,
      lanCode: (await GoogleTranslator().translate(_descriptionController.text))
          .sourceLanguage
          .code,
      user: commentedUser,
      memberList: memberListTemp.length == 1 ? null : memberListTemp,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      parentkey: widget.isTweet
          ? null
          : widget.isRetweet
              ? null
              : state.tweetToReplyModel!.key,
      childRetwetkey: widget.isTweet
          ? null
          : widget.isRetweet
              ? model!.key
              : null,
      userId: myUser.userId!,
      isCheckedIn: false,
      isPrivate: isPrivate,
      visibleUsersList: visibleListTemp,
      checkInList: [false, false, false, false, false, false, false],
      parentName: widget.isTweet
          ? null
          : widget.isRetweet
              ? null
              : state.tweetToReplyModel!.title,
      isHabit: widget.isTweet
          ? isSelected[0] == false
              ? false
              : true
          : state.tweetToReplyModel!.isHabit,
      GoalSum: isSelected[0] == true
          ? 0
          : widget.isTweet
              ? isSelected[0]
                  ? 0
                  : int.parse(_goalSumController.text)
              : 0,
      GoalAchieved: 0,
      GoalAchievedToday: 0,
      currentDays: 0,
      goalUnit: _goalUnitController.text,
      deadlineDate:
          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
    );
    return reply;
  }

  void _toggleDropdownVisibility(int index) {
    setState(() {
      _selectedButtonIndex = index;
      visibility = [false, false, false];
      visibility[index] = true;
      if (index == 0) {
        isPrivate = true;
      } else {
        isPrivate = false;
      }
      if (index == 2) {
        _showDropdown = true;
      } else {
        _showDropdown = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _multiSelectKey = GlobalKey<FormFieldState>();
    var authState = Provider.of<AuthState>(context, listen: false);
    var searchstate = Provider.of<SearchState>(context);
    List<UserModel?> selectedUsers = [];
    List<UserModel?> FriendList = [];
    if (authState.userModel!.friendList != null &&
        authState.userModel!.friendList!.isNotEmpty) {
      for (int i = 0; i < authState.userModel!.friendList!.length; i++) {
        FriendList =
            searchstate.getuserDetail(authState.userModel!.friendList!);
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ToggleButtons(
                          borderColor: Colors.grey,
                          fillColor: AppColor.PROGRESS_COLOR,
                          borderWidth: 2,
                          selectedBorderColor: AppColor.PROGRESS_COLOR,
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 60),
                              child: customizedTitleText(
                                  'Habit',
                                  18,
                                  isSelected[0] == true
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 60),
                              child: customizedTitleText(
                                  'Goal',
                                  18,
                                  isSelected[1] == true
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < isSelected.length; i++) {
                                isSelected[i] = i == index;
                              }
                            });
                          },
                          isSelected: isSelected,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
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
                            maxLength: 15,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "Title"),
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
                            maxLength: 200,
                            maxLines: null,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "Description"),
                          ),
                        ),
                      ),
                    if (widget.isTweet && isSelected[0] == false)
                      SizedBox(
                        height: 10,
                      ),
                    if (widget.isTweet && isSelected[0] == false)
                      SizedBox(
                        height: 15,
                      ),
                    if (widget.isTweet && isSelected[0] == false)
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
                    if (widget.isTweet && isSelected[0] == false)
                      SizedBox(height: 10),
                    if (widget.isTweet && isSelected[0] == false)
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
                    if (widget.isTweet && isSelected[0] == false)
                      SizedBox(
                        height: 30,
                      ),
                    if (widget.isTweet && isSelected[0] == false)
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
                          });
                        },
                        buttonText: '+ Add Group Members',
                      ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(days.length, (index) {
                              return ChoiceChip(
                                selectedColor: AppColor.PROGRESS_COLOR,
                                showCheckmark: false,
                                label: Text(
                                  days[index],
                                ),
                                selected: daySelected[index],
                                onSelected: (bool selected) {
                                  setState(() {
                                    daySelected[index] = selected;
                                  });
                                },
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
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ToggleButtons(
                            borderColor: Colors.grey,
                            fillColor: AppColor.PROGRESS_COLOR,
                            borderWidth: 2,
                            selectedBorderColor: AppColor.PROGRESS_COLOR,
                            selectedColor: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Personal',
                                  style: TextStyle(
                                    color: visibility[0] == true
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Public',
                                  style: TextStyle(
                                    color: visibility[1] == true
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Customize',
                                  style: TextStyle(
                                    color: visibility[2] == true
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            isSelected: List.generate(
                                3, (index) => index == _selectedButtonIndex),
                            onPressed: (int index) {
                              setState(() {
                                _toggleDropdownVisibility(index);
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_showDropdown)
                          Center(
                            child: ChildWidget(
                              friends: FriendList,
                              onSelectionChanged: (updatedFriends) {
                                setState(() {
                                  visibleListTemp.clear();
                                  List<String> temp = [];
                                  for (int i = 0;
                                      i < updatedFriends.length;
                                      i++) {
                                    temp.add(updatedFriends[i]!.userId!);
                                  }
                                  visibleListTemp.addAll(temp);
                                });
                              },
                              buttonText: '+ Add Friends',
                            ),
                          ),
                        SizedBox(height: 10),
                      ],
                    )
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
