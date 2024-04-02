import 'package:Goala/helper/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  // The border raduis used for rounding these edges
  static const double BORDER_RADIUS = 8;
  const ProfileImage({
    this.size = 90,
    this.path,
  });

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BORDER_RADIUS),
      child: Image(
        image: customAdvanceNetworkImage(path ?? Constants.dummyProfilePic),
        height: size,
        width: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

CachedNetworkImageProvider customAdvanceNetworkImage(String? path) {
  // TODO: This path does not work
  if (path ==
      'http://www.azembelani.co.za/wp-content/uploads/2016/07/20161014_58006bf6e7079-3.png') {
    path = Constants.dummyProfilePic;
  } else {
    path ??= Constants.dummyProfilePic;
  }
  return CachedNetworkImageProvider(
    path,
    cacheKey: path,
  );
}
