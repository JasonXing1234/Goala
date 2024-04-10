import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class HabitBar extends StatelessWidget {
  final double width;
  final double progress;
  final Color progressColor;
  final List<bool> checkInDays;
  final bool isTimeline;
  final bool isPost;
  final bool isCreate;
  HabitBar({
    required this.width,
    required this.progress,
    required this.progressColor,
    required this.checkInDays, required this.isTimeline, required this.isPost, required this.isCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 25,
      child:
        ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: checkInDays.length,
          itemBuilder: (BuildContext context, int index) {
            return Align(
              alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: checkInDays[index] == true ? AppColor.PROGRESS_COLOR : AppColor.DARK_GREY_COLOR,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  //height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
                  width: isTimeline ? 38.0 : isPost ? 30.0 : isCreate ? 34.0 : 17.6,
                  //color: checkInDays[index] == true ? progressColor : Colors.amber,
                )
            );
          }
      ));
  }
}
