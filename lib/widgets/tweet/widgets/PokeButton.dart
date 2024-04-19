import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class PokeButton extends StatefulWidget {
  final void Function() onPressed;

  const PokeButton({super.key, required this.onPressed});

  @override
  State<StatefulWidget> createState() => PokeButtonState();
}

class PokeButtonState extends State<PokeButton> {
  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(
          Icons.touch_app,
          size: 32,
          color: AppColor.DARK_GREY_COLOR,
        ),
      ),
    );
  }
}
