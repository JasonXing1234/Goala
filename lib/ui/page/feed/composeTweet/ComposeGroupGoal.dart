import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/widget/composeBottomIconWidget.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:flutter_twitter_clone/ui/page/feed/composeTweet/widget/widgetView.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/state/searchState.dart';
import 'package:flutter_twitter_clone/ui/page/profile/widgets/circular_image.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customAppBar.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/url_text/customUrlText.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../../RoundedButton.dart';
import '../../../constants.dart';

class ComposeGroupGoal extends StatefulWidget {
  const ComposeGroupGoal(
      {Key? key, required this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  @override
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeGroupGoal> with TickerProviderStateMixin{
  bool isScrollingDown = false;
  late FeedModel? model;
  late ScrollController scrollController;

  File? _image;
  late TextEditingController _descriptionController;
  late TextEditingController _titleController;
  late TextEditingController _addUserController;
  late TabController _tabController;
  late final List<String> memberListTemp = [];

  @override
  void dispose() {
    scrollController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _addUserController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    _tabController = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    _descriptionController = TextEditingController();
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

  void _onImageIconSelected(File file) {
    setState(() {
      _image = file;
    });
  }

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    if (_descriptionController.text.isEmpty ||
        _descriptionController.text.length > 50 || _titleController.text.isEmpty ||
        _titleController.text.length > 10) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenLoader.showLoader(context);

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
    memberListTemp.add(_addUserController.text);
    /// User who are creating reply tweet
    var commentedUser = UserModel(
        displayName: myUser.displayName ?? myUser.email!.split('@')[0],
        profilePic: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel!.isVerified,
        userName: authState.userModel!.userName);
    var tags = Utility.getHashTags(_descriptionController.text);
    FeedModel reply = FeedModel(
        isGroupGoal: true,
        title: _titleController.text,
        description: _descriptionController.text,
        lanCode:
        (await GoogleTranslator().translate(_descriptionController.text))
            .sourceLanguage
            .code,
        user: commentedUser,
        memberList: memberListTemp,
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
        userId: myUser.userId!, isCheckedIn: false, isPrivate: false, checkInList: [false]);
    return reply;
  }

  @override
  Widget build(BuildContext context) {
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
            widget.isRetweet ? _ComposeRetweet(this) : _ComposeTweet(this),
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

class _ComposeRetweet
    extends WidgetView<ComposeGroupGoal, _ComposeTweetReplyPageState> {
  const _ComposeRetweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;
  Widget _tweet(BuildContext context, FeedModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // SizedBox(width: 10),

        const SizedBox(width: 20),
        SizedBox(
          width: context.width - 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularImage(path: model.user!.profilePic),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 0, maxWidth: context.width * .5),
                    child: TitleText(model.user!.displayName!,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 3),
                  model.user!.isVerified!
                      ? customIcon(
                    context,
                    icon: AppIcon.blueTick,
                    isTwitterIcon: true,
                    iconColor: AppColor.primary,
                    size: 13,
                    paddingIcon: 3,
                  )
                      : const SizedBox(width: 0),
                  SizedBox(width: model.user!.isVerified! ? 5 : 0),
                  Flexible(
                    child: customText(
                      '${model.user!.userName}',
                      style: TextStyles.userNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  customText('· ${Utility.getChatTime(model.createdAt)}',
                      style: TextStyles.userNameStyle),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
        if (model.description != null)
          UrlText(
            text: model.description!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            urlStyle: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.w400),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return SizedBox(
      height: context.height,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child:
                CircularImage(path: authState.user?.photoURL, height: 40),
              ),
              Expanded(
                child: _TextField(
                  isTweet: false,
                  isRetweet: true,
                  textEditingController: viewState._descriptionController,
                ),
              ),
              const SizedBox(
                width: 16,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 80, bottom: 8),
            child: ComposeTweetImage(
              image: viewState._image,
              onCrossIconPressed: viewState._onCrossIconPressed,
            ),
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          left: 75, right: 16, bottom: 16),
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColor.extraLightGrey, width: .5),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                      child: _tweet(context, viewState.model!),
                    ),
                  ],
                ),
                _UserList(
                  list: Provider.of<SearchState>(context).userlist,
                  textEditingController: viewState._descriptionController,
                )
              ],
            ),
          ),
          const SizedBox(height: 50)
        ],
      ),
    );
  }
}

class _ComposeTweet
    extends WidgetView<ComposeGroupGoal, _ComposeTweetReplyPageState> {
  const _ComposeTweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;

  Widget _tweetCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 30),
              margin: const EdgeInsets.only(left: 20, top: 20, bottom: 3),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: context.width - 72,
                    child: UrlText(
                      text: viewState.model!.description ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      urlStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  UrlText(
                    text:
                    'Replying to ${viewState.model!.user!.userName ?? viewState.model!.user!.displayName}',
                    style: TextStyle(
                      color: TwitterColor.paleSky,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircularImage(
                    path: viewState.model!.user!.profilePic, height: 40),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints:
                  BoxConstraints(minWidth: 0, maxWidth: context.width * .5),
                  child: TitleText(viewState.model!.user!.displayName!,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 3),
                viewState.model!.user!.isVerified!
                    ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  isTwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
                    : const SizedBox(width: 0),
                SizedBox(width: viewState.model!.user!.isVerified! ? 5 : 0),
                customText('${viewState.model!.user!.userName}',
                    style: TextStyles.userNameStyle.copyWith(fontSize: 15)),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: customText(
                      '- ${Utility.getChatTime(viewState.model!.createdAt)}',
                      style: TextStyles.userNameStyle.copyWith(fontSize: 12)),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _multiSelectKey = GlobalKey<FormFieldState>();
    var authState = Provider.of<AuthState>(context, listen: false);
    var searchstate = Provider.of<SearchState>(context);
    List<UserModel?> selectedUsers = [];

    List<UserModel?> FriendList = [];
    if (authState.userModel!.followingList != null && authState.userModel!.followingList!.isNotEmpty) {
      for(int i = 0; i < authState.userModel!.followingList!.length; i++) {
        FriendList = searchstate.getuserDetail(authState.userModel!.followingList!);
      }
    }

    return Container(
      height: context.height,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          viewState.widget.isTweet
              ? const SizedBox.shrink()
              : _tweetCard(context),
          /*Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //CircularImage(path: authState.user?.photoURL, height: 40),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isTweet: widget.isTweet,
                  textEditingController: viewState._textEditingController,
                ),
              )
            ],
          ),*/

          Center(
            child: Text('New Goal'),
          ),
          ExpansionTile(
              collapsedIconColor: Colors.black,
              iconColor: Colors.black,
              tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
              leading: Icon(Icons.edit),
              title:Center(child: Text('Title'),),
              children: [
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  controller: viewState._titleController,
                  textAlign: TextAlign.center,
                  decoration: kTextFieldDecoration.copyWith(hintText: "title"),
                ),
                SizedBox(
                  height: 20,
                )
              ]
          ),
          ExpansionTile(
              collapsedIconColor: Colors.black,
              iconColor: Colors.black,
              tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
              leading: Icon(Icons.edit),
              title:Center(child: Text('Description'),),
              children: [
                TextFormField(
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  controller: viewState._descriptionController,
                  textAlign: TextAlign.center,
                  decoration: kTextFieldDecoration.copyWith(hintText: "description"),
                ),
                SizedBox(
                  height: 20,
                )
              ]
          ),
          ExpansionTile(
              collapsedIconColor: Colors.black,
              iconColor: Colors.black,
              tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
              leading: Icon(Icons.edit),
              title:Center(child: Text('Add User'),),
              children:[

                /*MultiSelectBottomSheetField<UserModel?>(
                key: _multiSelectKey,
                initialChildSize: 0.7,
                maxChildSize: 0.95,
                title: Text("Friends"),
                buttonText: Text("Your Friends"),
                items: FriendList.map((friend) => MultiSelectItem<UserModel>(friend!, friend.userName!)).toList(),
                searchable: true,
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return "Required";
                  }
                  List<String> names = values.map((e) => e!.userName!).toList();
                  if (names.contains("Frog")) {
                    return "Frogs are weird!";
                  }
                  return null;
                },
                onConfirm: (values) {
                  List<String> temp = [];
                  for(int i = 0; i < values.length; i++) {
                     temp.add(values[i]!.userId!);
                  }
                    viewState.memberListTemp.addAll(temp);
                  _multiSelectKey.currentState?.validate();
                },
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (item) {
                    viewState.memberListTemp.remove(item!.userId);
                    _multiSelectKey.currentState?.validate();
                  },
                ),
              ),*/
                SizedBox(height: 40),
                MultiSelectChipField<UserModel?>(
                  items: FriendList.map((friend) => MultiSelectItem<UserModel>(friend!, friend.userName!)).toList(),
                  //initialValue: [_animals[4], _animals[7], _animals[9]],
                  title: Text("Friends"),
                  headerColor: Colors.black.withOpacity(0.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1.8),
                  ),
                  selectedChipColor: Colors.blue.withOpacity(0.5),
                  selectedTextStyle: TextStyle(color: Colors.blue[800]),
                  onTap: (values) {
                    List<String> temp = [];
                    for(int i = 0; i < values.length; i++) {
                      temp.add(values[i]!.userId!);
                    }
                    viewState.memberListTemp.addAll(temp);
                    _multiSelectKey.currentState?.validate();
                  },
                ),
                SizedBox(height: 40),

              ]),
          ExpansionTile(
              collapsedIconColor: Colors.black,
              iconColor: Colors.black,
              tilePadding: EdgeInsets.only(left: 5, right: 20, top: 5, bottom: 5),
              leading: Icon(Icons.edit),
              title:
              Center(child: Text('Time'),),
              children: [
                SizedBox(
                    height:20
                ),
                TabBar(
                  labelPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  controller: viewState._tabController,
                  // give the indicator a decoration (color and border radius)
                  indicator: BoxDecoration(

                    borderRadius: BorderRadius.circular(
                      9.0,
                    ),
                    color: Colors.black,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Container(
                      width: 300,
                      child: Center(
                        child:Text("Daily"),
                      ),
                    ),
                    Container(
                      width: 300,
                      child: Center(child:
                      Text("Weekly"),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height:20
                ),
                SizedBox(
                  height: 100,
                  child:
                  TabBarView(
                    controller: viewState._tabController,
                    children: <Widget>[
                      RoundedButton(
                        color: Colors.black,
                        title: Text(DateTime.now().toString(), style: TextStyle(color: Colors.white)),
                        action: () async {
                          TimeOfDay? newDate = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),

                          );
                          if (newDate == null) return;

                        },
                      ),
                      RoundedButton(
                        color: Colors.black,
                        title: Text(DateTime.now().toString(), style: TextStyle(color: Colors.white)),
                        action: () async {
                          TimeOfDay? newDate = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),

                          );
                          if (newDate == null) return;

                        },
                      ),
                    ],
                  ),),
                SizedBox(
                  height: 20,
                )
              ]
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                ComposeTweetImage(
                  image: viewState._image,
                  onCrossIconPressed: viewState._onCrossIconPressed,
                ),
                _UserList(
                  list: Provider.of<SearchState>(context).userlist,
                  textEditingController: viewState._descriptionController,
                )
              ],
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
