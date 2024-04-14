import 'package:flutter/material.dart';
import 'package:Goala/model/notificationModel.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/GoalaFrontEnd/ProfilePage.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/url_text/customUrlText.dart';

class AcceptRequestNotificationTile extends StatelessWidget {
  final NotificationModel model;
  const AcceptRequestNotificationTile({Key? key, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: TwitterColor.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 26),
          child: Column(
            children: [
              Row(
                children: [
                  customIcon(context, icon: AppIcon.profile),
                  const SizedBox(width: 10),
                  Container(
                      width: 300,
                      child: Text(model.message!, style: TextStyles.subtitleStyle))
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const Divider(height: 0, thickness: .6)
      ],
    );
  }
}
