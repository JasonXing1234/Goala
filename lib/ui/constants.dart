import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Color.fromARGB(0xFF, 0xEC, 0xEC, 0xEC),
  hintText: 'you should not see this',
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 0.2),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Colors.grey, width: 1),
  ),
  // Border when TextField is focused
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Colors.grey, width: 2),
  ),
);

const kUniventGold = Color.fromARGB(0xFF, 0xDB, 0xBC, 0x5A);

const kDateTextStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 18.0,
  color: Colors.white,
);

const kRoundedBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(
    top: Radius.circular(20.0),
    bottom: Radius.circular(20.0),
  ),
);
