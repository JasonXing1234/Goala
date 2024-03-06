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
    return IconButton(
      onPressed: widget.onPressed,
      icon: Text("👉", style: TextStyle(fontSize: 20)),
    );
  }
}
