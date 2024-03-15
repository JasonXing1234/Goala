import 'package:flutter/material.dart';

Widget authTextInput({
  required TextEditingController controller,
  TextInputType inputType = TextInputType.emailAddress,
  Function(String)? onSubmit,
  String? hintText,
  bool obscureText = false,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: controller,
      onSubmitted: onSubmit,
      keyboardType: inputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontStyle: FontStyle.italic),
        border: InputBorder.none,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
  );
}
