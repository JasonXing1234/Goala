import 'package:flutter/material.dart';

Widget authTextInput({
  required TextEditingController controller,
  TextInputType inputType = TextInputType.emailAddress,
  Function(String)? onSubmit,
  String? hintText,
  bool obscureText = false,
}) {
  return TextField(
    controller: controller,
    onSubmitted: onSubmit,
    keyboardType: inputType,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontStyle: FontStyle.italic),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(99),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(99),
          ),
          borderSide: BorderSide(color: Colors.blue)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    ),
  );
}
