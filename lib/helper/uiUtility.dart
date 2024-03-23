import 'package:flutter/material.dart';

class UiUtility {
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}

/// This is a widget that will dismiss the keyboard whenever you click on
/// the screen.
/// Use this by wrapping the main Scaffold with this widget
Widget KeyboardDismisser({
  required BuildContext context,
  required Widget child,
}) {
  return GestureDetector(
    onTap: () => UiUtility.dismissKeyboard(context),
    child: child,
  );
}
