import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Goala/helper/constant.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/model/GoalNotificationModel.dart';
import 'package:Goala/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:Goala/ui/page/feed/composeTweet/widget/composeBottomIconWidget.dart';
import 'package:Goala/ui/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customAppBar.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../ui/RoundedButton.dart';
import '../ui/constants.dart';

class ComposeTweetPage extends StatefulWidget {
  const ComposeTweetPage(
      {Key? key, required this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  @override
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeTweetPage> with TickerProviderStateMixin {
  bool isScrollingDown = false;
  late FeedModel? model;
  late ScrollController scrollController;
  List<String?> selectedImages = [];
  File? _image;
  late TextEditingController _descriptionController;
  late TextEditingController _goalSumController;
  late TextEditingController _titleController;
  late TabController _tabController;
  List<bool> isSelected = [true, false];
  TimeOfDay? pickedTime;
  final List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  List<bool> daySelected = List.filled(7, false);

  @override
  void dispose() {
    scrollController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    scrollController = ScrollController();
    _descriptionController = TextEditingController();
    _goalSumController = TextEditingController();
    _titleController = TextEditingController();
    scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this);
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

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    /*if (_descriptionController.text.isEmpty ||
        _descriptionController.text.length > 50 || _titleController.text.isEmpty ||
        _titleController.text.length > 10) {
      return;
    }*/
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
        if(tweetModel.parentkey == null && daySelected.contains(true)){
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

  Future<GoalNotiModel> createNotiModel(int day, String feedID) async{
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    final _messaging = FirebaseMessaging.instance;
    String? tempToken = await _messaging.getToken();
    GoalNotiModel temp = GoalNotiModel(tempToken!, day, feedID, '${pickedTime!.hour}:${pickedTime!.minute}');
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
    /// User who are creating reply tweet
    var commentedUser = UserModel(
        displayName: myUser.displayName ?? myUser.email!.split('@')[0],
        profilePic: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel!.isVerified,
        userName: authState.userModel!.userName);
    var tags = Utility.getHashTags(_descriptionController.text);
    FeedModel reply = FeedModel(
        isGroupGoal: false,
        title: _titleController.text,
        description: _descriptionController.text,
        lanCode:'',
        user: commentedUser,
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
      isPrivate: false,
      checkInList: widget.isTweet
          ? [false]
          : widget.isRetweet
          ? null : state.tweetToReplyModel!.checkInList,
      goalPhotoList: selectedImages,
      parentName: widget.isTweet
          ? null
          : widget.isRetweet
          ? null : state.tweetToReplyModel!.title,
      isHabit: widget.isTweet
          ? isSelected[0] == false ? false : true : state.tweetToReplyModel!.isHabit,
      GoalSum: widget.isTweet ? isSelected[0] ? 0 : int.parse(_goalSumController.text) : 0
    );
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    final _multiSelectKey = GlobalKey<FormFieldState>();
    var authState = Provider.of<AuthState>(context, listen: false);
    var searchstate = Provider.of<SearchState>(context);
    var feedState = Provider.of<FeedState>(context, listen: false);
    List<UserModel?> selectedUsers = [];
    List<UserModel?> FriendList = [];
    if (authState.userModel!.followingList != null && authState.userModel!.followingList!.isNotEmpty) {
      for(int i = 0; i < authState.userModel!.followingList!.length; i++) {
        FriendList = searchstate.getuserDetail(authState.userModel!.followingList!);
      }
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: widget.isTweet
            ? 'Tweet'
            : widget.isRetweet
                ? 'Retweet'
                : 'Reply',
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
            child:
                Container(
                  height: context.height,
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: widget.isTweet ? Text('New Goal') : Text('New Post'),
                      ),
                      if(widget.isTweet) Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ToggleButtons(
                          borderColor: Colors.grey,
                          fillColor: Colors.blue,
                          borderWidth: 2,
                          selectedBorderColor: Colors.blue,
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Habit'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Goal'),
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
                      if(widget.isTweet) ExpansionTile(
                          collapsedIconColor: Colors.black,
                          iconColor: Colors.black,
                          tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
                          leading: Icon(Icons.edit),
                          title:Center(child: Text('Title'),),
                          children: [
                            TextFormField(
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              controller: _titleController,
                              textAlign: TextAlign.center,
                              decoration: kTextFieldDecoration.copyWith(hintText: "title"),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ]
                      ),
                      if(widget.isTweet) ExpansionTile(
                          collapsedIconColor: Colors.black,
                          iconColor: Colors.black,
                          tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
                          leading: Icon(Icons.edit),
                          title:Center(child: Text('Description'),),
                          children: [
                            TextFormField(
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              controller: _descriptionController,
                              textAlign: TextAlign.center,
                              decoration: kTextFieldDecoration.copyWith(hintText: "description"),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ]
                      ),
                      if(widget.isTweet && isSelected[0] == false) ExpansionTile(
                          collapsedIconColor: Colors.black,
                          iconColor: Colors.black,
                          tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
                          leading: Icon(Icons.edit),
                          title:Center(child: Text('Goal Number'),),
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              controller: _goalSumController,
                              textAlign: TextAlign.center,
                              decoration: kTextFieldDecoration.copyWith(hintText: "goal number"),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ]
                      ),
                      widget.isTweet
                          ? const SizedBox.shrink() :
                      ExpansionTile(
                          collapsedIconColor: Colors.black,
                          iconColor: Colors.black,
                          tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
                          leading: Icon(Icons.edit),
                          title:Center(child: Text('Description'),),
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.green)),
                              // TO change button color
                              child: const Text('Select Image from Gallery and Camera'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                await picker.pickMultiImage(imageQuality: 50).then((
                                    List<XFile> files,
                                    ) async {
                                  List<File>? tempfiles = files.map((xFile) => File(xFile.path)).toList();
                                  if (tempfiles.isNotEmpty) {
                                    for (var i = 0; i < tempfiles.length; i++) {
                                      selectedImages.add(await feedState.uploadFile(tempfiles[i]));
                                    }
                                  }
                                });
                                // if atleast 1 images is selected it will add
                                // all images in selectedImages
                                // variable so that we can easily show them in UI
                              },
                            ),
                            SizedBox(
                              width: 300.0,
                              height: 100,// To show images in particular area only
                              child: selectedImages.isEmpty  // If no images is selected
                                  ? const Center(child: Text('Sorry nothing selected!!'))
                              // If atleast 1 images is selected
                                  : GridView.builder(
                                itemCount: selectedImages.length,
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3
                                  // Horizontally only 3 images will show
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  // TO show selected file
                                  return Center(
                                      child: Image.network(
                                          selectedImages[index]!));
                                },
                              ),
                            ),
                          ]
                      ),
                      if(widget.isTweet) ExpansionTile(
                          collapsedIconColor: Colors.black,
                          iconColor: Colors.black,
                          tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
                          leading: Icon(Icons.edit),
                          title:
                          Center(child: Text('Reminder Time'),),
                          children: [
                            Column(
                              children: [
                                Wrap(
                                  children: List.generate(days.length, (index) {
                                    return ChoiceChip(
                                      label: Text(days[index]),
                                      selected: daySelected[index],
                                      onSelected: (bool selected) {
                                        setState(() {
                                          daySelected[index] = selected;
                                        });
                                      },
                                    );
                                  }),
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
                                  child: Text('Pick a Time'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ]
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
          Align(
            alignment: Alignment.bottomCenter,
            child: ComposeBottomIconWidget(
              textEditingController: _descriptionController,
              onImageIconSelected: _onImageIconSelected,
            ),
          ),
        ],
      ),
    );
  }
}
class _TextField extends StatelessWidget {
  const _TextField(
      {Key? key,
      required this.textEditingController,
      this.isTweet = false,
      this.isRetweet = false})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isTweet;
  final bool isRetweet;

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) {
            //Provider.of<ComposeTweetState>(context, listen: false)
             //   .onDescriptionChanged(text, searchState);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet
                  ? 'What\'s happening?'
                  : isRetweet
                      ? 'Add a comment'
                      : 'Tweet your reply',
              hintStyle: const TextStyle(fontSize: 18)),
        ),
      ],
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
                  isTwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
              : const SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName!),
    );
  }
}
