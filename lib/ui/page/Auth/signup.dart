import 'dart:math';

import 'package:Goala/helper/uiUtility.dart';
import 'package:Goala/ui/page/Auth/widget/authTextEntry.dart';
import 'package:Goala/ui/page/Auth/widget/loginOptions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/constant.dart';
import 'package:Goala/helper/enum.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/model/user.dart';
import 'package:Goala/state/authState.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:Goala/widgets/customFlatButton.dart';
import 'package:Goala/widgets/customWidgets.dart';
import 'package:Goala/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback? loginCallback;

  const Signup({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  late CustomLoader loader;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    loader = CustomLoader();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            authTextInput(
              controller: _nameController,
              inputType: TextInputType.name,
              hintText: "Name",
            ),
            authTextInput(
              hintText: "Email",
              controller: _emailController,
            ),
            authTextInput(
              controller: _passwordController,
              obscureText: true,
              hintText: "Password",
            ),
            authTextInput(
              controller: _confirmController,
              obscureText: true,
              hintText: "Confirm Password",
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              width: double.infinity,
              child: CustomFlatButton(
                label: "SIGN UP",
                onPressed: () => _submitForm(context),
                borderRadius: 30,
                color: AppColor.PROGRESS_COLOR,
              ),
            ),
            // const Divider(height: 30),
            // otherLoginOptions(context),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      Utility.customSnackBar(
        context,
        "Please enter name",
        backgroundColor: Colors.blue,
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      Utility.customSnackBar(
        context,
        "Please enter email",
        backgroundColor: Colors.blue,
      );
      return;
    }

    if (_passwordController.text.isEmpty || _confirmController.text.isEmpty) {
      Utility.customSnackBar(
        context,
        "Please enter password",
        backgroundColor: Colors.blue,
      );
      return;
    }

    if (_nameController.text.length > 27) {
      Utility.customSnackBar(
        context,
        "Name length cannot exceed 27 character",
        backgroundColor: Colors.blue,
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      Utility.customSnackBar(
        context,
        "Passwords did not match",
        backgroundColor: Colors.blue,
      );
      return;
    }

    bool isValid = Utility.validateCredentials(
      context,
      _emailController.text,
      _passwordController.text,
    );
    if (!isValid) {
      return;
    }

    loader.showLoader(context);
    var state = Provider.of<AuthState>(context, listen: false);
    Random random = Random();
    int randomNumber = random.nextInt(Constants.dummyProfilePicList.length);
    String? token = await FirebaseMessaging.instance.getToken();
    UserModel user = UserModel(
        email: _emailController.text.toLowerCase(),
        bio: "Edit profile to update bio",
        // contact:  _mobileController.text,
        displayName: _nameController.text,
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: "Somewhere in universe",
        profilePic: Constants.dummyProfilePicList[randomNumber],
        isVerified: false,
        deviceToken: token,
      equipmentList: ["haha"]
    );
    state
        .signUp(
      user,
      password: _passwordController.text,
      context: context,
    )
        .then((status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          if (widget.loginCallback != null) widget.loginCallback!();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: customText(
            "Sign Up",
            context: context,
            style: const TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: _body(context),
        ),
      ),
    );
  }
}
