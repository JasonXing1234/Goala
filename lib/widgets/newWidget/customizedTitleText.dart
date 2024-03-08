import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class customizedTitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  const customizedTitleText(
    this.text,
    this.fontSize, {
    Key? key,
    this.color = Colors.black,
    this.fontWeight = FontWeight.w600,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.visible,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.mulish(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
