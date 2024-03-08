import 'dart:io';
import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/customRoute.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/RoundedButton.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../widgets/newWidget/title_text.dart';
import '../widgets/tweet/widgets/tweetBottomSheet.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({Key? key, required this.tempFeed}) : super(key: key);
  final FeedModel tempFeed;
  static Route<void> getRoute(FeedModel feed) {
    return SlideLeftRoute<void>(
      builder: (BuildContext context) => TaskDetailPage(
        tempFeed: feed,
      ),
    );
  }

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetailPage> {
  File? imagePicked;
  late FeedModel tempFeed;
  bool isEditing = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    tempFeed = widget.tempFeed;
    super.initState();
  }

  Widget _floatingActionButton() {
    var state = Provider.of<FeedState>(context, listen: false);
    return FloatingActionButton(
      onPressed: () {
        ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 50)
            .then((
          XFile? file,
        ) async {
          imagePicked = File(file!.path);
          state.addPhoto(tempFeed, await state.uploadFile(imagePicked!));
        });
      },
      child: const Icon(Icons.add),
    );
  }

  void deleteTweet(TweetType type, String tweetId,
      {required String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    Navigator.of(context).pop();
    if (type == TweetType.Detail) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    final scrollController = ScrollController();
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: _floatingActionButton(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: customTitleText(
              'Your Posts',
            ),
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            bottom: PreferredSize(
              child: Container(
                color: Colors.grey.shade200,
                height: 1.0,
              ),
              preferredSize: const Size.fromHeight(0.0),
            ),
          ),
          SliverToBoxAdapter(
              child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    var state = Provider.of<FeedState>(context, listen: false);
                    state.setTweetToReply = tempFeed;
                    Navigator.of(context).pushNamed('/ComposeTweetPage');
                  },
                  child: Text('Add Post')
                  //isEditing == true ? Text('Finish') : Text('Edit')
                  ),
              ListView(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: state.tweetReplyMap == null ||
                        state.tweetReplyMap!.isEmpty ||
                        state.tweetReplyMap![widget.tempFeed.key!] == null
                    ? [
                        Column(children: [
                          SizedBox(height: 140),
                          Center(
                              child: Text(
                            'Explore Your Groups',
                            style: TextStyle(fontSize: 34),
                          ))
                        ])
                      ]
                    : state.tweetReplyMap![widget.tempFeed.key!]!
                        .map((x) => _commentRow(x))
                        .toList(),
              )

              /*tempFeed.goalPhotoList == null ? SizedBox() :
                          GridView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Adjust the number of columns here
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: tempFeed.goalPhotoList!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenPhoto(photoUrl: tempFeed.goalPhotoList![index]),
                                    ),
                                  );
                                },
                                child: Hero(
                                    tag: 'photo$index',
                                    child:
                                    Stack(children: [
                                      Image.network(tempFeed.goalPhotoList![index], fit: BoxFit.cover),
                                      isEditing == false ? SizedBox() :
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                                        child: TextButton(
                                          onPressed: (){

                                          },
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              fixedSize: MaterialStateProperty.all<Size>(Size(1, 1)),
                                          ),
                                          child: Text('-'),
                                        ),
                                      )
                                    ],)

                                ),
                              );
                            },
                          ),*/
            ],
          ))
        ],
      ),
    );
  }

  Widget _commentRow(FeedModel model) {
    return Tweet(
      model: model,
      type: TweetType.Reply,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: TweetType.Reply),
      scaffoldKey: scaffoldKey,
    );
  }
}

class FullScreenPhoto extends StatelessWidget {
  final String photoUrl;

  FullScreenPhoto({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'photo$photoUrl',
            child: Image.network(photoUrl),
          ),
        ),
      ),
    );
  }
}
