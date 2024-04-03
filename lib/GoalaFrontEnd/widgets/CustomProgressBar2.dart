import 'package:flutter/material.dart';

class CustomProgressBar2 extends StatelessWidget {
  final double width;
  final double height;
  final int GoalAchieved;
  final int GoalSum;
  final double oldProgress;
  final double newProgress;
  final Color backgroundColor;
  final Color progressColor;
  final num percentage;
  final bool isHabit;
  final List<bool> checkInDays;

  const CustomProgressBar2({
    Key? key,
    required this.width,
    required this.height,
    required this.oldProgress,
    required this.backgroundColor,
    required this.progressColor,
    required this.percentage,
    required this.isHabit,
    required this.checkInDays,
    required this.newProgress,
    required this.GoalAchieved,
    required this.GoalSum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Row(children: [
          Container(
            width: oldProgress <= 1 ? width * oldProgress : width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: newProgress <= 1 ? width * newProgress : width,
            height: height,
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: BorderRadius.circular(4),
            ),
          )
        ]),
        Center(
            child: Text((percentage * 100).toInt().toString() + '%',
                style: TextStyle(fontSize: height * 0.6))),
      ],
    );
  }
}
