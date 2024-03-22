// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/newWidget/customLoader.dart';

final kAnalytics = FirebaseAnalytics.instance;
final DatabaseReference kDatabase = FirebaseDatabase.instance.ref();
final kScreenLoader = CustomLoader();

/// Print logs only in development mode
void cprint(
  dynamic data, {
  String? errorIn,
  String? event,
  String label = 'Log',
}) {
  if (kDebugMode) {
    if (errorIn != null) {
      print('**************************** error *****************************');
      developer.log('[Error]',
          time: DateTime.now(), error: data, name: errorIn);
      print('**************************** error *****************************');
    } else if (data != null) {
      developer.log(data, time: DateTime.now(), name: label);
    }
    if (event != null) {
      Utility.logEvent(event, parameter: {});
    }
  }
}

class Utility {
  static String getPostTime2(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    var dt = DateTime.parse(date).toLocal();
    var dat =
        DateFormat.jm().format(dt) + ' - ' + DateFormat("dd MMM yy").format(dt);
    return dat;
  }

  static String getDob(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    var dt = DateTime.parse(date).toLocal();
    var dat = DateFormat.yMMMd().format(dt);
    return dat;
  }

  static String getJoiningDate(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    var dt = DateTime.parse(date).toLocal();
    var dat = DateFormat("MMMM yyyy").format(dt);
    return 'Joined $dat';
  }

  static String getChatTime(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    String msg = '';
    var dt = DateTime.parse(date).toLocal();

    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
    }

    var dur = DateTime.now().toLocal().difference(dt);
    if (dur.inDays > 365) {
      msg = DateFormat.yMMMd().format(dt);
    } else if (dur.inDays > 30) {
      msg = DateFormat.yMMMd().format(dt);
    } else if (dur.inDays > 0) {
      msg = '${dur.inDays} d';
      return dur.inDays == 1 ? '1d' : DateFormat.MMMd().format(dt);
    } else if (dur.inHours > 0) {
      msg = '${dur.inHours} h';
    } else if (dur.inMinutes > 0) {
      msg = '${dur.inMinutes} m';
    } else if (dur.inSeconds > 0) {
      msg = '${dur.inSeconds} s';
    } else {
      msg = 'now';
    }
    return msg;
  }

  static String getPollTime(String date) {
    int hr, mm;
    String msg = 'Poll ended';
    var endDate = DateTime.parse(date);
    if (DateTime.now().isAfter(endDate)) {
      return msg;
    }
    msg = 'Poll ended in';
    var dur = endDate.difference(DateTime.now());
    hr = dur.inHours - dur.inDays * 24;
    mm = dur.inMinutes - (dur.inHours * 60);
    if (dur.inDays > 0) {
      msg = ' ' + dur.inDays.toString() + (dur.inDays > 1 ? ' Days ' : ' Day');
    }
    if (hr > 0) {
      msg += ' ' + hr.toString() + ' hour';
    }
    if (mm > 0) {
      msg += ' ' + mm.toString() + ' min';
    }
    return (dur.inDays).toString() +
        ' Days ' +
        ' ' +
        hr.toString() +
        ' Hours ' +
        mm.toString() +
        ' min';
  }

  static String? getSocialLinks(String? url) {
    if (url != null && url.isNotEmpty) {
      url = url.contains("https://www") || url.contains("http://www")
          ? url
          : url.contains("www") &&
                  (!url.contains('https') && !url.contains('http'))
              ? 'https://' + url
              : 'https://www.' + url;
    } else {
      return null;
    }
    cprint('Launching URL : $url');
    return url;
  }

  static launchURL(String url) async {
    if (url == "") {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      cprint('Could not launch $url');
    }
  }

  static void logEvent(String event, {Map<String, dynamic>? parameter}) {
    kReleaseMode
        ? kAnalytics.logEvent(name: event, parameters: parameter)
        : print("[EVENT]: $event");
  }

  static void debugLog(String log, {dynamic param = ""}) {
    final String time = DateFormat("mm:ss:mmm").format(DateTime.now());
    print("[$time][Log]: $log, $param");
  }

  static void share(String message, {String? subject}) {
    Share.share(message, subject: subject);
  }

  static List<String> getHashTags(String text) {
    RegExp reg = RegExp(
        r"([#])\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text);
    List<String> resultMatches = <String>[];
    for (Match match in _matches) {
      if (match.group(0)!.isNotEmpty) {
        var tag = match.group(0);
        resultMatches.add(tag!);
      }
    }
    return resultMatches;
  }

  static String getUserName({
    required String id,
    required String name,
  }) {
    String userName = '';
    if (name.length > 15) {
      name = name.substring(0, 6);
    }
    name = name.split(' ')[0];
    id = id.substring(0, 4).toLowerCase();
    userName = '@$name$id';
    return userName;
  }

  static bool validateEmail(String email) {
    /// This is the regex from RFC 5322
    /// https://stackoverflow.com/questions/201323/how-can-i-validate-an-email-address-using-a-regular-expression
    /// Also can use this package in the future: https://pub.dev/packages/email_validator
    String p =
        r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""";

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(email);
  }

  static bool validateCredentials(
      BuildContext context, String? email, String? password) {
    if (email == null || email.isEmpty) {
      customSnackBar(context, "Please enter your email");
      return false;
    } else if (password == null || password.isEmpty) {
      customSnackBar(context, "Please enter your password");
      return false;
    } else if (password.length < 8) {
      customSnackBar(context, "Password must be 8 character long");
      return false;
    }

    if (!validateEmail(email)) {
      customSnackBar(context, "Please enter valid email address");
      return false;
    }
    return true;
  }

  static customSnackBar(BuildContext context, String msg,
      {double height = 30, Color backgroundColor = Colors.black}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        msg,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<Uri> createLinkToShare(BuildContext context, String id,
      {required SocialMetaTagParameters socialMetaTagParameters}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fwitter.page.link',
      link: Uri.parse('https://twitter.com/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.Goala_dev',
        minimumVersion: 0,
      ),
      socialMetaTagParameters: socialMetaTagParameters,
    );
    Uri url;
    final ShortDynamicLink shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    url = shortLink.shortUrl;
    return url;
  }

  static createLinkAndShare(BuildContext context, String id,
      {required SocialMetaTagParameters socialMetaTagParameters}) async {
    var url = await createLinkToShare(context, id,
        socialMetaTagParameters: socialMetaTagParameters);

    share(url.toString(), subject: "Tweet");
  }

  static shareFile(List<String> path, {String text = ""}) {
    try {
      final files = path.map((path) => XFile(path)).toList();
      Share.shareXFiles(files, text: text);
    } catch (error) {
      print(error);
    }
  }

  static void copyToClipBoard({
    required BuildContext context,
    required String text,
    required String message,
  }) {
    var data = ClipboardData(text: text);
    Clipboard.setData(data);
    customSnackBar(context, message);
  }

  static Locale getLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }
}
