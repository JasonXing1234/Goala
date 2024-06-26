// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:Goala/ui/page/Auth/signinPage.dart';
import 'package:Goala/ui/page/Auth/verifyEmail.dart';
import 'package:Goala/ui/page/common/splash.dart';
import 'package:Goala/GoalaFrontEnd/ComposeGroupGoal.dart';
import 'package:Goala/GoalaFrontEnd/composeTweet.dart';
import 'package:Goala/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:Goala/GoalaFrontEnd/homePage.dart';
import 'package:Goala/ui/page/message/conversationInformation/conversationInformation.dart';
import 'package:Goala/ui/page/message/newMessagePage.dart';
import 'package:Goala/ui/page/profile/follow/followerListPage.dart';
import 'package:Goala/GoalaFrontEnd/CurrentUserProfilePage.dart';
import 'package:Goala/GoalaFrontEnd/SearchUsersPage.dart';
import 'package:Goala/ui/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:Goala/ui/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:Goala/ui/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:Goala/ui/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:Goala/ui/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:Goala/ui/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:Goala/ui/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:Goala/ui/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:Goala/ui/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:Goala/ui/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:Goala/ui/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:Goala/ui/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';

import '../GoalaFrontEnd/EditGoalPage.dart';
import '../helper/customRoute.dart';
import '../ui/page/Auth/forgetPasswordPage.dart';
import '../ui/page/Auth/signup.dart';
import '../ui/page/feed/feedPostDetail.dart';
import '../ui/page/message/chatScreenPage.dart';
import '../GoalaFrontEnd/ProfilePage.dart';
import '../widgets/customWidgets.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => const SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String? path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ComposeTweetPage":
        bool isRetweet = false;
        bool isTweet = false;
        if (pathElements.length == 3 && pathElements[2].contains('retweet')) {
          isRetweet = true;
        } else if (pathElements.length == 3 &&
            pathElements[2].contains('tweet')) {
          isTweet = true;
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      ComposeTweetPage(isRetweet: isRetweet, isTweet: isTweet),
                ));
      case "FeedPostDetail":
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(
                  postId: postId,
                ),
            settings: const RouteSettings(name: 'FeedPostDetail'));
      case "ProfilePage":
        String profileId;
        if (pathElements.length > 2) {
          profileId = pathElements[2];
          return CustomRoute<bool>(
              builder: (BuildContext context) => ProfilePage(
                    profileId: profileId,
                  ));
        }
        return CustomRoute(builder: (BuildContext context) => const HomePage());
      case "CreateGroupGoal":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      const ComposeGroupGoal(isRetweet: false, isTweet: true),
                ));
      case "CreateFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      const ComposeTweetPage(isRetweet: false, isTweet: true),
                ));
      case "CreateEditPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child: const EditGoal(isRetweet: false, isTweet: true),
                ));
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const SignInPage());
      case "SignIn":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SignInPage());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => Signup());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ForgetPasswordPage());
      // TODO: This is not right...
      case "SearchPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => CurrentUserProfilePage());
      case "Search1Page":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchUsersPage());
      /*case "ImageViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ImageViewPge());*/
      case "ChatScreenPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ChatScreenPage());
      case "NewMessagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NewMessagePage(),
        );
      case "SettingsAndPrivacyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const SettingsAndPrivacyPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AccountSettingsPage(),
        );
      case "PrivacyAndSaftyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const PrivacyAndSaftyPage(),
        );
      case "NotificationPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const NotificationPage(),
        );
      case "ContentPrefrencePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const ContentPrefrencePage(),
        );
      case "DisplayAndSoundPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const DisplayAndSoundPage(),
        );
      case "DirectMessagesPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const DirectMessagesPage(),
        );
      case "TrendsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const TrendsPage(),
        );
      case "DataUsagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const DataUsagePage(),
        );
      case "AccessibilityPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AccessibilityPage(),
        );
      case "ProxyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const ProxyPage(),
        );
      case "AboutPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AboutPage(),
        );
      case "ConversationInformation":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const ConversationInformation(),
        );
      case "FollowerListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowerListPage(isMyProfile: false,),
        );
      case "VerifyEmailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => VerifyEmailPage(),
        );
      default:
        return onUnknownRoute(const RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: customTitleText(
            settings.name!.split('/')[1],
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name!.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
