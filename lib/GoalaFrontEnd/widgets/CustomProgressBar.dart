import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final int daysLeft;
  final bool isHabit;
  final List<bool> checkInDays;

  static const double PROGRESS_BAR_HEIGHT = 30;

  const CustomProgressBar({
    Key? key,
    required this.progress,
    required this.backgroundColor,
    this.progressColor = AppColor.PROGRESS_COLOR,
    required this.daysLeft,
    required this.isHabit,
    required this.checkInDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder so that I can get the width and height of the parent.
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double maxWidth = constraints.maxWidth;

      return Stack(
        children: [
          // The background color container
          Container(
            width: maxWidth,
            height: PROGRESS_BAR_HEIGHT,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // The foreground color progress
          Container(
            width: maxWidth * progress,
            height: PROGRESS_BAR_HEIGHT,
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // The Goal or Habit text
          if (isHabit)
            _GoalText(daysLeft: daysLeft)
          else
            _HabitText(checkInDays: checkInDays)
        ],
      );
    });
  }
}

class _HabitText extends StatelessWidget {
  final List<bool> checkInDays;

  _HabitText({
    required this.checkInDays,
  });

  /// Calculate the total streak value.
  /// This is how many days in a row that you have reported on the habit.
  int _calculateStreak(List<bool> days) {
    int streak = 0;
    // Iterate over the list from the end to the beginning
    for (int i = days.length - 1; i >= 0; i--) {
      // If the value is true, increment the streak
      if (days[i]) {
        streak++;
      } else {
        // If a false is encountered, break the loop as we only want consecutive trues from the end
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "${_calculateStreak(checkInDays)} day streak",
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _GoalText extends StatelessWidget {
  final int daysLeft;

  _GoalText({
    required this.daysLeft,
  });

  String _getTextFromDaysLeft(int days) {
    if (days < 0) days = 0;
    if (days == 1) {
      return "1 day left";
    }
    return "$days days left";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _getTextFromDaysLeft(daysLeft),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
