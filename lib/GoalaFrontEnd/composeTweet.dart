import 'dart:io';
import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:Goala/helper/uiUtility.dart';
import 'package:Goala/ui/styleConstants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Goala/helper/constant.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/model/GoalNotificationModel.dart';
import 'package:Goala/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/state/searchState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customAppBar.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:uuid/uuid.dart';

class ComposeTweetPage extends StatefulWidget {
  const ComposeTweetPage(
      {Key? key, required this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  @override
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeTweetPage>
    with TickerProviderStateMixin {
  bool isScrollingDown = false;
  late FeedModel? model;
  late ScrollController scrollController;
  List<String?> selectedImages = [];
  String imageUrl = '';
  File? _image;
  String imageUid = const Uuid().v4();
  DateTime selectedDate = DateTime.now();
  bool dateSelected = false;
  late TextEditingController _descriptionController;
  late TextEditingController _goalAchievedController;
  late TextEditingController _titleController;
  late TabController _tabController;
  List<bool> isSelected = [true, false];
  TimeOfDay? pickedTime;
  final List<String> days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
  List<bool> daySelected = List.filled(7, false);
  List<bool> _selections = [false, false];
  List<bool> tempCheckInList = [false];
  String tempString = '';
  @override
  void dispose() {
    scrollController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _goalAchievedController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    scrollController = ScrollController();
    _descriptionController = TextEditingController();
    _goalAchievedController = TextEditingController();
    _titleController = TextEditingController();
    scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this);
    tempCheckInList = model!.checkInList!;
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

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    /*TODO: Set word limit for posts */
    /*if (_descriptionController.text.isEmpty ||
        _descriptionController.text.length > 50 || _titleController.text.isEmpty ||
        _titleController.text.length > 10) {
      return;
    }*/
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenLoader.showLoader(context);
    if(_selections[0] == true){
      if(model!.currentDays! < 7){
        tempCheckInList[model!.currentDays!] = true;
      }
      else{
        tempCheckInList[tempCheckInList.length - 1] = true;
      }
    }
    else{
      tempCheckInList[tempCheckInList.length - 1] = false;
    }
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
        if (model!.isHabit == true && _selections[0] == true) {
          var state = Provider.of<FeedState>(context, listen: false);
          var tempTweet = await state.fetchTweet(model!.key!);
          tempTweet!.checkInList![tempTweet.checkInList!.length - 1] = true;
          tweetModel.checkInList = tempTweet.checkInList!;
          tweetModel.isCheckedIn = true;
          FirebaseDatabase.instance
              .reference()
              .child("tweet")
              .child(model!.key!)
              .update({
            "checkInList": tempCheckInList,
            "isCheckedIn": true,
          }).catchError((onError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(onError)));
          });
        } else if (model!.isHabit == false) {
          var state = Provider.of<FeedState>(context, listen: false);
          var tempTweet = await state.fetchTweet(model!.key!);
          tempTweet!.checkInList![tempTweet.checkInList!.length - 1] = true;
          tweetModel.checkInList = tempTweet.checkInList!;
          tweetModel.isCheckedIn = true;
          FirebaseDatabase.instance
              .reference()
              .child("tweet")
              .child(model!.key!)
              .update({
            "checkInList": tempCheckInList,
            "isCheckedIn": true,
            "GoalAchievedToday": double.parse(_goalAchievedController.text)
          }).catchError((onError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(onError)));
          });
          state.addNumberToGoal(
              model!, double.parse(_goalAchievedController.text));
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
    String? token = await FirebaseMessaging.instance.getToken();

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
      isGroupGoal: false,
      title: _titleController.text,
      description: _descriptionController.text,
      lanCode: '',
      user: commentedUser,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      grandparentKey: state.tweetToReplyModel == null
          ? null
          : state.tweetToReplyModel!.parentkey,
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
      isCheckedIn: _selections[0] == true ? true : false,
      isPrivate: state.tweetToReplyModel!.isPrivate,
      visibleUsersList: state.tweetToReplyModel!.visibleUsersList,
      checkInListPost: tempCheckInList,
      checkInList: [false], //this is dummy list for posts so feedpage doesn't return null pointer
      goalPhotoList: selectedImages,
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
      GoalAchievedToday: _goalAchievedController.text == ''
          ? 0
          : int.parse(_goalAchievedController.text) + 0,
      GoalAchieved: _goalAchievedController.text == ''
          ? 0
          : model?.GoalAchieved == null
              ? int.parse(_goalAchievedController.text)
              : model!.GoalAchieved! + int.parse(_goalAchievedController.text),
      GoalSum: state.tweetToReplyModel!.isHabit ||
              state.tweetToReplyModel!.GoalSum == null
          ? 0
          : state.tweetToReplyModel!.GoalSum,
      deadlineDate:
          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
      deviceToken: token,
    );
    return reply;
  }

  Future<void> setImage(ImageSource source) async {
    XFile? image;
    try {
      image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 20);
    } catch (e) {
      SnackBar snackBar = const SnackBar(
        content: Text('Invalid image was selected.'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // print(e.toString());
    }
    if (image == null) {
      return;
    }
    final ref =
        FirebaseStorage.instance.ref().child('Goals').child('$imageUid.jpg');
    await ref.putFile(File(image.path));
    imageUrl = await ref.getDownloadURL();
    setState(() {
      imageUrl = imageUrl;
      selectedImages.add(imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      context: context,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
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
            isBottomLine:
                Provider.of<ComposeTweetState>(context).isScrollingDown,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ProgressHUD(child: Builder(builder: (context) {
            return Stack(
              //!Removed container
              children: <Widget>[
                SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(model!.title!,
                            style: TextStyles.bigTitleStyle),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(model!.description!,
                            style: TextStyles.bigSubtitleStyle),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Container(
                          width: 330,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, // Color of the border
                              width: 0.2, // Width of the border
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 41,
                                width: 300,
                                child: CustomProgressBar(
                                  progress: model!.isHabit == false
                                      ? tempString != ''
                                          ? (model!.GoalAchieved! +
                                                  int.parse(
                                                      _goalAchievedController
                                                          .text)) /
                                              model!.GoalSum!
                                          : model!.GoalAchieved! /
                                              model!.GoalSum!
                                      : _selections[0] == true
                                          ? model!.checkInList!
                                                  .where((item) => item == true)
                                                  .length +
                                              1 / 8
                                          : model!.checkInList!
                                                  .where((item) => item == true)
                                                  .length /
                                              8,
                                  backgroundColor: Colors.grey[300]!,
                                  progressColor: model!.isCheckedIn ||
                                          _goalAchievedController.text != '' ||
                                          _selections[0] == true
                                      ? AppColor.PROGRESS_COLOR
                                      : Colors.black,
                                  percentage: model!.GoalAchieved! / model!.GoalSum!,
                                  isHabit: model!.isHabit,
                                  checkInDays: model!.checkInList!, isPost: false, isCreate: true, isTimeline: false,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              if (model!.isHabit == true &&
                                  model!.isCheckedIn == false)
                                Text('Did you?',
                                    style: TextStyles.subtitleStyle),
                              SizedBox(
                                height: 10,
                              ),
                              if (model!.isHabit == true &&
                                  model!.isCheckedIn == false)
                                Center(
                                  child: Row(
                                    children: [
                                      ToggleButtons(
                                          color: Colors.black,
                                          //selectedColor: Colors.white,
                                          fillColor: Colors.white,
                                          renderBorder: false,
                                          onPressed: (int index) {
                                            setState(() {
                                              // This logic sets true for the tapped button and false for the other
                                              for (int buttonIndex = 0;
                                                  buttonIndex <
                                                      _selections.length;
                                                  buttonIndex++) {
                                                if (buttonIndex == index) {
                                                  _selections[buttonIndex] =
                                                      true;
                                                } else {
                                                  _selections[buttonIndex] =
                                                      false;
                                                }
                                              }
                                            });
                                          },
                                          isSelected: _selections,
                                          children: List<Widget>.generate(
                                              2,
                                              (index) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: index == 0
                                                            ? AppColor
                                                                .PROGRESS_COLOR
                                                            : _selections[1] ==
                                                                    false
                                                                ? Colors.grey
                                                                : Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      width: 140,
                                                      height: 50,
                                                      alignment:
                                                          Alignment.center,
                                                      child: index == 0
                                                          ? Text('Yes!',
                                                              style: TextStyles
                                                                  .onPrimarySubTitleTextBlack)
                                                          : Text('Nope.',
                                                              style: _selections[
                                                                          1] ==
                                                                      false
                                                                  ? TextStyles
                                                                      .onPrimarySubTitleTextBlack
                                                                  : TextStyles
                                                                      .onPrimarySubTitleText),
                                                    ),
                                                  ))),
                                    ],
                                  ),
                                ),
                              if (model!.isHabit == false &&
                                  model!.isCheckedIn == false)
                                Row(
                                  children: [
                                    SizedBox(width: 80),
                                    SizedBox(
                                      width: 100,
                                      child: TextFormField(
                                        onChanged: (val) {
                                          setState(() {
                                            tempString =
                                                _goalAchievedController.text;
                                          });
                                        },
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        controller: _goalAchievedController,
                                        textAlign: TextAlign.center,
                                        decoration: kTextFieldDecoration
                                            .copyWith(hintText: "#"),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(model!.goalUnit!,
                                        style: TextStyles.titleStyle),
                                  ],
                                ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    maxLength: 1000, // Maximum characters
                                    maxLines: null,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    cursorColor:
                                        Theme.of(context).colorScheme.secondary,
                                    controller: _descriptionController,
                                    textAlign: TextAlign.center,
                                    decoration: kTextFieldDecoration.copyWith(
                                        hintText: "description"),
                                  ),
                                ),
                              ),
                              widget.isTweet
                                  ? const SizedBox.shrink()
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 0.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  imageUrl.isEmpty ? 89.0 : 0.0,
                                              horizontal: imageUrl.isEmpty
                                                  ? 89.0
                                                  : 0.0),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                0xFF, 0xEC, 0xEC, 0xEC),
                                            border: Border.all(
                                                color: Colors.grey, width: 1.0),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(8.0)),
                                          ),
                                          child: imageUrl.isEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                  iconSize: imageUrl.isEmpty
                                                      ? 100
                                                      : null,
                                                  onPressed: () async {
                                                    final progress =
                                                        ProgressHUD.of(context);
                                                    progress!.showWithText(
                                                        'Loading');
                                                    await setImage(
                                                        ImageSource.gallery);
                                                    progress.dismiss();
                                                  },
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(8.0)),
                                                  child: Stack(
                                                    children: [
                                                      CachedNetworkImage(
                                                        imageUrl: imageUrl,
                                                        placeholder: (context,
                                                                url) =>
                                                            Center(
                                                                child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(100.0),
                                                          child: Image.asset(
                                                            'assets/images/icon_512_transparent.png',
                                                            width: 100,
                                                            height: 100,
                                                          ),
                                                        )),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Center(
                                                          child: Text(
                                                              'Unable to load image...'),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 0.0,
                                                        top: 0.0,
                                                        child:
                                                            FloatingActionButton(
                                                          mini: true,
                                                          backgroundColor:
                                                              Colors.red,
                                                          foregroundColor:
                                                              Colors.white,
                                                          onPressed: () {
                                                            setState(() {
                                                              imageUrl = '';
                                                              selectedImages
                                                                  .clear();
                                                            });
                                                          },
                                                          child: const Icon(
                                                              Icons.remove),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }))),
    );
  }
}
