import 'package:Goala/GoalaFrontEnd/TaskDetailPage.dart';
import 'package:Goala/GoalaFrontEnd/tweet.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: Rename this ASAP
class UserTile2 extends StatefulWidget {
  const UserTile2({Key? key, required this.tweet}) : super(key: key);
  //final UserModel user;
  final FeedModel tweet;

  @override
  State<UserTile2> createState() => UserTile2State();
}

class UserTile2State extends State<UserTile2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FeedState>(context);

    void _showBottomMenu(BuildContext context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    onTap: () {
                      state.setTweetToReply = widget.tweet;
                      Navigator.of(context).pushNamed('/CreateEditPage');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      var state =
                          Provider.of<FeedState>(context, listen: false);
                      state.deleteTweet(widget.tweet.key!);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          });
    }

    return GestureDetector(
        onLongPress: () => _showBottomMenu(context),
        child: GridTile(
          child: InkWell(
              onTap: () {
                state.getPostDetailFromDatabase(null, model: widget.tweet);
                Navigator.push(context, TaskDetailPage.getRoute(widget.tweet));
              },
              child: Row(children: [
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(
                        widget.tweet.title!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    SizedBox(
                      height: 25,
                      width: 160,
                      child: CustomProgressBar(
                        progress: widget.tweet.isHabit == false
                            ? widget.tweet.GoalAchieved! / widget.tweet.GoalSum!
                            : widget.tweet.checkInList!
                                    .where((item) => item == true)
                                    .length /
                                8,
                        height: 25,
                        width: 160,
                        backgroundColor: Colors.grey.shade300,
                        progressColor: widget.tweet.isCheckedIn == true
                            ? AppColor.PROGRESS_COLOR
                            : AppColor.DARK_GREY_COLOR,
                        daysLeft: DateTime(
                                int.parse(
                                    widget.tweet.deadlineDate!.split('-')[0]),
                                int.parse(
                                    widget.tweet.deadlineDate!.split('-')[1]),
                                int.parse(
                                    widget.tweet.deadlineDate!.split('-')[2]))
                            .difference(DateTime(DateTime.now().year,
                                DateTime.now().month, DateTime.now().day))
                            .inDays,
                        isHabit: widget.tweet.isHabit,
                        checkInDays: widget.tweet.checkInList!,
                      ),
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: 160, // Specify the width of the container
                      height: 160, // Specify the height of the container
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                          // Use ClipRRect for borderRadius if needed
                          borderRadius: BorderRadius.circular(12),
                          child: widget.tweet.coverPhoto != null
                              ? Image.network(
                                  widget.tweet.coverPhoto!,
                                  fit: BoxFit
                                      .cover, // This ensures the image covers the container
                                )
                              : Image.asset(
                                  'assets/images/icon_512.png',
                                  fit: BoxFit
                                      .cover, // This ensures the image covers the container
                                )),
                    ),
                  ],
                ),
              ])),
        ));
  }
}
