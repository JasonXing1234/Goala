import 'package:Goala/helper/utility.dart';
import 'package:Goala/strings.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/ui/page/Auth/signup.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customFlatButton.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import '../../../GoalaFrontEnd/homePage.dart';
import 'SignInPage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Widget _createAccountButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      child: CustomFlatButton(
        label: CREATE_ACCOUNT_TEXT,
        onPressed: () {
          var state = Provider.of<AuthState>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SignupPage(loginCallback: state.getCurrentUser),
            ),
          );
        },
        borderRadius: 30,
      ),
    );
  }

  void _onLoginPressed() {
    cprint("Login button pressed");
    var state = Provider.of<AuthState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignIn(loginCallback: state.getCurrentUser),
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/icon-48.png',
            ),
            const Spacer(),
            const TitleText(
              SEE_WHAT_HAPPENING_TEXT,
              fontSize: 25,
            ),
            const SizedBox(height: 20),
            _createAccountButton(),
            const Spacer(),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const TitleText(
                  ALREADY_HAVE_AN_ACCOUNT_TEXT,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                InkWell(
                  onTap: _onLoginPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: TitleText(
                      LOG_IN_TEXT,
                      fontSize: 14,
                      color: TwitterColor.dodgeBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      body: state.authStatus == AuthStatus.NOT_LOGGED_IN ||
              state.authStatus == AuthStatus.NOT_DETERMINED
          ? _body()
          : const HomePage(),
    );
  }
}
