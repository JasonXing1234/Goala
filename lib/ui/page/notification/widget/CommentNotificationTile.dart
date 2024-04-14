import 'package:flutter/material.dart';
import 'package:Goala/model/notificationModel.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/GoalaFrontEnd/ProfilePage.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/url_text/customUrlText.dart';

class CommentNotificationTile extends StatelessWidget {
  final NotificationModel model;
  const CommentNotificationTile({Key? key, required this.model})
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
                  customIcon(context, icon: AppIcon.messageFill),
                  const SizedBox(width: 10),
                  Text(
                    model.user.displayName!,
                    style: TextStyles.subtitleStyle,
                  ),
                  Text(" Commented on your post", style: TextStyles.subtitleStyle),
                ],
              ),
              const SizedBox(width: 10),
              Text("\"${model.message!}\"", style: TextStyles.bigSubtitleStyle),
            ],
          ),
        ),
        const Divider(height: 0, thickness: .6)
      ],
    );
  }
}