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
    required this.checkInDays,
    required this.isTimeline,
    required this.isPost,
    required this.isCreate,
  });

  @override
  Widget build(BuildContext context) {
    int calculateStreak(List<bool> values) {
      int streak = 0;

      for (int i = values.length - 1; i >= 0; i--) {
        if (values[i]) {
          streak++;
        } else {
          break;
        }
      }
      return streak;
    }

    return Container(
        width: width,
        height: 25,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: checkInDays.length,
            itemBuilder: (BuildContext context, int index) {
              return Align(
                  alignment: Alignment.centerLeft,
                  child: (index != checkInDays.length - 1)
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: checkInDays[index] == true
                                ? AppColor.PROGRESS_COLOR
                                : Color(0xff888888),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
                          width: isTimeline
                              ? 43.43
                              : isPost
                                  ? 29.5
                                  : isCreate
                                      ? 38.9
                                      : 20.1,
                          //color: checkInDays[index] == true ? progressColor : Colors.amber,
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: checkInDays[index] == true
                                    ? AppColor.PROGRESS_COLOR
                                    : Color(0xff888888),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              //height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
                              width: isTimeline
                                  ? 43.43
                                  : isPost
                                      ? 29.5
                                      : isCreate
                                          ? 38.9
                                          : 20.1,
                              //color: checkInDays[index] == true ? progressColor : Colors.amber,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Text(
                                calculateStreak(checkInDays).toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            )
                          ],
                        ));
            }));
  }
}
