import 'package:Goala/model/feedModel.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'UserTile.dart';

class GoalGrid extends StatefulWidget {
  final TabController tabController;
  final List<FeedModel> personalGoals;
  final List<FeedModel> groupGoals;

  /// Creates a grid of personal and group goals with a TabController
  const GoalGrid({
    Key? key,
    this.scaffoldKey,
    required this.tabController,
    required this.personalGoals,
    required this.groupGoals,
  }) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<StatefulWidget> createState() => _GoalGridState();
}

class _GoalGridState extends State<GoalGrid> {
  /// Function to build the goal grids with two columns of goals.
  Widget _goalGridBuilder(List<FeedModel> goals) {
    if (goals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "No goals...\nGo make some now!",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      addAutomaticKeepAlives: false,
      physics: const BouncingScrollPhysics(),
      itemCount: goals.length,
      itemBuilder: (context, index) => UserTile2(tweet: goals[index]),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 0.8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.center,
            child: TabBar(
              controller: widget.tabController,
              // The indicator color/decoration
              indicator: BoxDecoration(
                color: AppColor.PROGRESS_COLOR,
                borderRadius: BorderRadius.circular(8.0),
              ),
              // Text colors
              labelColor: Colors.white,
              unselectedLabelColor: AppColor.DARK_GREY_COLOR,
              tabs: [
                Container(
                  child: Center(
                    child: Text("Personal"),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text("Group"),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: widget.tabController,
            children: [
              // The Grid with the personal goals
              _goalGridBuilder(widget.personalGoals),
              // The Grid with the group goals
              _goalGridBuilder(widget.groupGoals),
            ],
          ),
        ),
      ],
    );
  }
}
