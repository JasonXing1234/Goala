import 'package:Goala/helper/uiUtility.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/ui/page/Auth/widget/authTextEntry.dart';
import 'package:Goala/ui/page/Auth/widget/loginOptions.dart';
import 'package:flutter/material.dart';
import 'package:Goala/ui/page/Auth/signup.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customFlatButton.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  void _onLogInPress() {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isbusy) {
      return;
    }
    bool isValid = Utility.validateCredentials(
      context,
      _emailController.text,
      _passwordController.text,
    );
    if (isValid) {
      cprint("credentials are valid");
      state
          .signIn(_emailController.text, _passwordController.text,
              context: context)
          .then((status) {
        if (state.user != null) {
          state.getCurrentUser();
        } else {
          cprint('Unable to login', errorIn: '_onLogInPress');
        }
      });
    } else {
      cprint("credentials are NOT valid");
    }
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

  Widget _emailInput() {
    return authTextInput(
      controller: _emailController,
      hintText: "Email",
      onSubmit: (_) => {_onLogInPress()},
    );
  }

  Widget _passwordInput() {
    return authTextInput(
      controller: _passwordController,
      obscureText: true,
      hintText: "Password",
      onSubmit: (_) => {_onLogInPress()},
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Widget _body() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              "assets/images/img.png",
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
            const SizedBox(height: 32),
            _emailInput(),
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
            // otherLoginOptions(context),
            // const SizedBox(height: 20),
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
    return KeyboardDismisser(
      context: context,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _body(),
      ),
    );
  }
}
