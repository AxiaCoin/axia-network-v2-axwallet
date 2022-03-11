import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/new_user/auth.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({Key? key}) : super(key: key);

  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final formKey = GlobalKey<FormState>();
  Mode mode = Mode.login;
  TextEditingController emailController =
      new TextEditingController(text: kDebugMode ? "test@test.com" : "");
  TextEditingController passwordController =
      new TextEditingController(text: kDebugMode ? "test@test.com" : "");
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  bool obscurity = true;

  onSubmit() {
    if (formKey.currentState!.validate()) {
      Get.off(() => AuthPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoginMode = mode == Mode.login;

    return Scaffold(
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              child: Icon(Icons.next_plan),
              onPressed: () => Get.offAll(() => HomePage()),
            )
          : Container(),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: Get.width * 0.2,
                      width: Get.width * 0.2,
                      child: FlutterLogo()),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    isLoginMode ? "Login" : "Register",
                    style: context.textTheme.headline4,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    "Welcome to your Wallet",
                    style: context.textTheme.caption!.copyWith(fontSize: 24),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      String pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(val!))
                        return 'Enter Valid Email';
                      else
                        return null;
                    },
                    onFieldSubmitted: (val) {
                      passwordFocus.requestFocus();
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    obscureText: obscurity,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: isLoginMode
                        ? TextInputAction.done
                        : TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurity
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => obscurity = !obscurity),
                      ),
                    ),
                    validator: (val) => passwordController.text.length < 8
                        ? "The password should be 8 characters long"
                        : null,
                    onFieldSubmitted: (val) {
                      if (!isLoginMode) confirmPasswordFocus.requestFocus();
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  isLoginMode
                      ? Container()
                      : TextFormField(
                          focusNode: confirmPasswordFocus,
                          obscureText: obscurity,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == passwordController.text
                              ? null
                              : "The passwords do not match",
                        ),
                  isLoginMode
                      ? Container()
                      : SizedBox(
                          height: 16,
                        ),
                  SizedBox(
                    height: 32,
                  ),
                  Container(
                    width: Get.width,
                    child: ElevatedButton(
                      onPressed: () {
                        onSubmit();
                      },
                      child: Text(isLoginMode ? "LOGIN" : "REGISTER"),
                      style: MyButtonStyles.onboardStyle,
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text.rich(
                    TextSpan(
                      text: isLoginMode
                          ? "Not yet registered? "
                          : "Already registered? ",
                      style: context.textTheme.caption!
                          .copyWith(color: Colors.black),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => mode =
                                isLoginMode ? Mode.register : Mode.login),
                            child: Text(
                              isLoginMode ? "Create Account" : "Log back in",
                              style: context.textTheme.caption!
                                  .copyWith(color: appColor),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }
}

enum Mode { login, register }
