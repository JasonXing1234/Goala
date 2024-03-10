part of 'theme.dart';

class TextStyles {
  TextStyles._();

  static TextStyle get onPrimaryTitleText {
    return const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
  }

  static TextStyle get onPrimarySubTitleText {
    return const TextStyle(
      color: Colors.white,
        fontSize: 16, fontWeight: FontWeight.bold
    );
  }
  static TextStyle get onPrimarySubTitleTextBlack {
    return const TextStyle(
      color: Colors.black,
        fontSize: 16, fontWeight: FontWeight.bold
    );
  }

  static TextStyle get titleStyle {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }
  static TextStyle get bigTitleStyle {
    return const TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );
  }
  static TextStyle get barTitleStyle {
    return const TextStyle(
      fontSize: 33,
    );
  }
  static TextStyle get bigSubtitleStyle {
    return const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
  }
  static TextStyle get subtitleStyle {
    return const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold);
  }

  static TextStyle get buttonTextStyle {
    return const TextStyle(
        fontSize: 18);
  }

  static TextStyle get userNameStyle {
    return const TextStyle(
        color: AppColor.darkGrey, fontSize: 14, fontWeight: FontWeight.bold);
  }

  static TextStyle get textStyle14 {
    return const TextStyle(
        color: AppColor.darkGrey, fontSize: 14, fontWeight: FontWeight.bold);
  }
}
