import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/customRoute.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/RoundedButton.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../widgets/newWidget/title_text.dart';

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
        ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50).then((
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
    return Scaffold(
        key: scaffoldKey,
        floatingActionButton: _floatingActionButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: customTitleText(
                'Goal Detail',
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
              child:
                    Column(
                        children: [
                          TitleText('Photo Album',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = !isEditing;
                                });
                              },
                              child: isEditing == true ? Text('Finish') : Text('Edit')
                          ),

                          tempFeed.goalPhotoList == null ? SizedBox() :
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
                          ),
                        ],
                    )
            )
          ],
        ),
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
