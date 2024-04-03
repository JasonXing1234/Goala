import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:flutter/material.dart';

class HabitBar extends StatelessWidget {
  final double width;
  final double progress;
  final Color progressColor;
  final List<bool> checkInDays;
  HabitBar({
    required this.width,
    required this.progress,
    required this.progressColor,
    required this.checkInDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
          width: width / 7,
          color: progressColor,
        ),
        Container(
          height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
          width: width / 7,
          color: progressColor,
        ),
        Container(
          height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
          width: width / 7,
          color: progressColor,
        ),
      ],
    );

    return Container(
      width: width * progress,
      height: CustomProgressBar.PROGRESS_BAR_HEIGHT,
      decoration: BoxDecoration(
        color: progressColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
