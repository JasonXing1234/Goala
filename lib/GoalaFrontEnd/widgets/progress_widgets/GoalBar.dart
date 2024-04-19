import 'package:Goala/GoalaFrontEnd/widgets/CustomProgressBar.dart';
import 'package:flutter/material.dart';

class GoalBar extends StatelessWidget {
  final double width;
  final double progress;
  final Color progressColor;
  final bool isCreate;
  GoalBar({
    required this.width,
    required this.progress,
    required this.progressColor, required this.isCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * progress,
      height: isCreate ? 40 : CustomProgressBar.PROGRESS_BAR_HEIGHT,
      decoration: BoxDecoration(
        color: progressColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
