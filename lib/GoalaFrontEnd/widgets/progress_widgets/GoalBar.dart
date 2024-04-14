import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:flutter/material.dart';

class GoalBar extends StatelessWidget {
  final double width;
  final double progress;
  final Color progressColor;
  GoalBar({
    required this.width,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
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
