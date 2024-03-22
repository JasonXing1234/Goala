import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class customizedTitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color customizedColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  const customizedTitleText(
    this.text,
    this.fontSize, this.customizedColor, {
    Key? key,
    this.fontWeight = FontWeight.w600,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.visible
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.mulish(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: customizedColor,
      ),
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
