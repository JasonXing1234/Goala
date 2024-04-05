import 'package:Goala/GoalaFrontEnd/widgets/progress_widgets/GoalBar.dart';
import 'package:Goala/GoalaFrontEnd/widgets/progress_widgets/HabitBar.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final num percentage;
  final bool isHabit;
  final List<bool> checkInDays;

  static const double PROGRESS_BAR_HEIGHT = 25;

  const CustomProgressBar({
    Key? key,
    required this.progress,
    required this.backgroundColor,
    this.progressColor = AppColor.PROGRESS_COLOR,
    required this.percentage,
    required this.isHabit,
    required this.checkInDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder so that I can get the width and height of the parent.
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double maxWidth = constraints.maxWidth;

      // TODO: Make two different stacks?
      return Stack(
        children: [
          // The background color container
          if (isHabit)
            Container(
              width:20,
              height: PROGRESS_BAR_HEIGHT,
            )
          else
            Container(
              width: maxWidth,
              height: PROGRESS_BAR_HEIGHT,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          // The foreground color progress
          // Can be either HabitBar or GoalBar
          if (isHabit)
            HabitBar(
              width: maxWidth,
              progress: progress,
              checkInDays: checkInDays,
              progressColor: progressColor,
            )
          else
            GoalBar(
              width: maxWidth,
              progress: progress,
              progressColor: progressColor,
            ),
          // The Goal or Habit text
          if (isHabit)
            Container()
          // _HabitText(checkInDays: checkInDays)
          else
            _GoalText(percentage: percentage),
        ],
      );
    });
  }
}

// class _HabitText extends StatelessWidget {
//   final List<bool> checkInDays;

//   _HabitText({
//     required this.checkInDays,
//   });

//   /// Calculate the total streak value.
//   /// This is how many days in a row that you have reported on the habit.
//   int _calculateStreak(List<bool> days) {
//     int streak = 0;
//     // Iterate over the list from the end to the beginning
//     for (int i = days.length - 1; i >= 0; i--) {
//       // If the value is true, increment the streak
//       if (days[i]) {
//         streak++;
//       } else {
//         // If a false is encountered, break the loop as we only want consecutive trues from the end
//         break;
//       }
//     }
//     return streak;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         "${_calculateStreak(checkInDays)} day streak",
//         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//       ),
//     );
//   }
// }

class _GoalText extends StatelessWidget {
  final num percentage;

  _GoalText({
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        (percentage * 100).toInt().toString() + '%',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
