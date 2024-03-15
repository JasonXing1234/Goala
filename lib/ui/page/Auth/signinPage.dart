import 'package:Goala/GoalaFrontEnd/homePage.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/enum.dart';
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
      cprint("Logged in");
      state
          .signIn(_emailController.text, _passwordController.text,
              context: context)
          .then((status) {
        if (state.user != null) {
          Navigator.pop(context);
          state.getCurrentUser();
        } else {
          cprint('Unable to login', errorIn: '_emailLoginButton');
        }
      });
    } else {
      cprint("Not logged in");
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

  TextEditingController _emailController = TextEditingController();
  Widget _emailInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _emailController,
        onSubmitted: (_) {
          _onLogInPress();
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: "Email",
          hintStyle: TextStyle(fontStyle: FontStyle.italic),
          border: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(99),
            ),
            borderSide: BorderSide(color: AppColor.PROGRESS_COLOR),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  TextEditingController _passwordController = TextEditingController();
  Widget _passwordInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _passwordController,
        onSubmitted: (_) {
          _onLogInPress();
        },
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Email",
          hintStyle: TextStyle(fontStyle: FontStyle.italic),
          border: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(99),
            ),
            borderSide: BorderSide(color: AppColor.PROGRESS_COLOR),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
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
      resizeToAvoidBottomInset: false,
      body: state.authStatus == AuthStatus.NOT_LOGGED_IN ||
              state.authStatus == AuthStatus.NOT_DETERMINED
          ? _body()
          : const HomePage(),
    );
  }
}
