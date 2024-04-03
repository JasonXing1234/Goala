import 'package:Goala/GoalaFrontEnd/TaskDetailPage.dart';
import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:Goala/model/feedModel.dart';
import 'package:Goala/state/feedState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GoalTile extends StatefulWidget {
  const GoalTile({Key? key, required this.tweet}) : super(key: key);
  //final UserModel user;
  final FeedModel tweet;

  @override
  State<GoalTile> createState() => GoalTileState();
}

class GoalTileState extends State<GoalTile> {
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
              children: [
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
                    var state = Provider.of<FeedState>(context, listen: false);
                    state.deleteTweet(widget.tweet.key!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    /// Triggered when you press on a goal
    void _onPressGoal() {
      state.getPostDetailFromDatabase(null, model: widget.tweet);
      Navigator.push(context, TaskDetailPage.getRoute(widget.tweet));
    }

    // TODO: Move this to Utils
    int _getDaysLeft(String deadlineDate) {
      return DateTime(
              int.parse(deadlineDate.split('-')[0]),
              int.parse(deadlineDate.split('-')[1]),
              int.parse(deadlineDate.split('-')[2]))
          .difference(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day))
          .inDays;
    }

    // TODO: Paramaterize this function
    double _getGoalProgress() {
      return widget.tweet.GoalAchieved! / widget.tweet.GoalSum!;
    }

    // TODO: Paramaterize this function
    double _getHabitProgress() {
      return widget.tweet.checkInList!.where((item) => item == true).length / 8;
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2.0,
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showBottomMenu(context),
        child: GridTile(
          child: InkWell(
            onTap: _onPressGoal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.tweet.title!,
                  style: GoogleFonts.rubik().copyWith(
                    fontSize: 24,
                    color: widget.tweet.isCheckedIn == true
                        ? AppColor.PROGRESS_COLOR
                        : AppColor.DARK_GREY_COLOR,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // ProgressBar
                CustomProgressBar(
                  progress: widget.tweet.isHabit
                      ? _getHabitProgress()
                      : _getGoalProgress(),
                  backgroundColor: Colors.grey.shade300,
                  progressColor: widget.tweet.isCheckedIn == true
                      ? AppColor.PROGRESS_COLOR
                      : AppColor.DARK_GREY_COLOR,
                  daysLeft: _getDaysLeft(widget.tweet.deadlineDate!),
                  isHabit: widget.tweet.isHabit,
                  checkInDays: widget.tweet.checkInList!,
                ),
                // Cover Photo
                Center(
                  child: _CoverPhoto(widget.tweet.coverPhoto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TODO: If the image is null, return the description
// TODO: Make it take the necessary height instead of hardcoding it?
class _CoverPhoto extends StatelessWidget {
  final String? imageSrc;
  const _CoverPhoto(this.imageSrc);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageSrc == null
          ? Image.asset(
              'assets/images/icon_512.png',
              fit: BoxFit.cover,
              height: 150,
            )
          : Image.network(
              imageSrc!,
              fit: BoxFit.cover,
              height: 150,
            ),
    );
  }
}
