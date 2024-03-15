import 'package:Goala/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:flutter/material.dart';

Widget otherLoginOptions(BuildContext context) {
  return Column(
    children: [
      Text(
        "OR LOG IN WITH",
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: AppColor.extraLightGrey,
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
            ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoogleLoginButton(
              loader: CustomLoader(),
            ),
          ],
        ),
      )
    ],
  );
}
