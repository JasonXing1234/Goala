import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/ui/page/Auth/signup.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customFlatButton.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../GoalaFrontEnd/homePage.dart';
import 'signin.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void _onLogInPress() {
    var state = Provider.of<AuthState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignIn(loginCallback: state.getCurrentUser),
      ),
    );
  }

  void _onCreateAccountPress() {
    var state = Provider.of<AuthState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Signup(loginCallback: state.getCurrentUser),
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(
              "assets/images/icon_512_transparent.png",
              height: 100,
            ),
            const Spacer(),
            const TitleText(
              "See what's happening in the world right now.",
              fontSize: 25,
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              child: CustomFlatButton(
                label: "Create Account",
                onPressed: _onCreateAccountPress,
                borderRadius: 30,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Have an account already?"),
                InkWell(
                  onTap: _onLogInPress,
                  child: Text(
                    " Log in",
                    style: TextStyle(color: TwitterColor.dodgeBlue),
                  ),
                ),
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
