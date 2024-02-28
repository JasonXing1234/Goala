import 'package:Goala/strings.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customFlatButton.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  final VoidCallback? loginCallback;

  const SignIn({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late CustomLoader loader;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    loader = CustomLoader();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 150),
            _entryField(ENTER_EMAIL_TEXT, controller: _emailController),
            _entryField(ENTER_PASSWORD_TEXT,
                controller: _passwordController, isPassword: true),
            _emailLoginButton(context),
            const SizedBox(height: 20),
            _labelButton(FORGOT_PASSWORD_TEXT, onPressed: () {
              Navigator.of(context).pushNamed('/ForgetPasswordPage');
            }),
            const Divider(height: 30),
            const SizedBox(height: 30),
            GoogleLoginButton(
              loginCallback: widget.loginCallback!,
              loader: loader,
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryField(
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.blue)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _labelButton(String title, {Function()? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: TwitterColor.dodgeBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35),
      child: CustomFlatButton(
        label: SUBMIT_BUTTON_TEXT,
        onPressed: _emailLogin,
        borderRadius: 30,
      ),
    );
  }

  void _emailLogin() {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isbusy) {
      return;
    }
    loader.showLoader(context);
    var isValid = Utility.validateCredentials(
        context, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .signIn(_emailController.text, _passwordController.text,
              context: context)
          .then((status) {
        if (state.user != null) {
          loader.hideLoader();
          Navigator.pop(context);
          widget.loginCallback!();
        } else {
          cprint('Unable to login', errorIn: '_emailLoginButton');
          loader.hideLoader();
        }
      });
    } else {
      loader.hideLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText(
          SIGN_IN_TEXT,
          context: context,
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}
