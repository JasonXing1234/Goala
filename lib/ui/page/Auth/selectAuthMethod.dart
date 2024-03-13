import 'package:Goala/GoalaFrontEnd/homePage.dart';
import 'package:Goala/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/ui/page/Auth/signup.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customFlatButton.dart';
import 'package:Goala/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
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

  TextEditingController userController = TextEditingController();
  Widget _usernameInput() {
    return TextField(
      controller: userController,
      decoration: InputDecoration(
        hintText: "Email",
        hintStyle: TextStyle(fontStyle: FontStyle.italic),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(99),
          ),
        ),
      ),
    );
  }

  TextEditingController passwordController = TextEditingController();
  Widget _passwordInput() {
    return TextField(
      controller: passwordController,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(fontStyle: FontStyle.italic),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(99),
          ),
        ),
        suffixIcon: Icon(Icons.remove_red_eye),
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              "assets/images/icon_512.png",
              height: 175,
            ),
            Text(
              "goala",
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    color: AppColor.lightGrey,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            _usernameInput(),
            const SizedBox(height: 16),
            _passwordInput(),
            const SizedBox(height: 24),
            Text(
              "FORGOT PASSWORD",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: AppColor.extraLightGrey,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              child: CustomFlatButton(
                label: "LOG IN",
                onPressed: _onLogInPress,
                borderRadius: 30,
                color: AppColor.PROGRESS_COLOR,
              ),
            ),
            const Spacer(),
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
                  const SizedBox(width: 24),
                  GoogleLoginButton(
                    loader: CustomLoader(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                InkWell(
                  onTap: _onCreateAccountPress,
                  child: Text(
                    " SIGN UP",
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
