import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/new_user/signup.dart';
import 'package:wallet/pages/new_user/auth.dart';
import 'package:wallet/pages/wallet/index.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  Mode mode = Mode.phone;
  TextEditingController emailController =
      new TextEditingController(text: kDebugMode ? "test@test.com" : "");
  TextEditingController passwordController =
      new TextEditingController(text: kDebugMode ? "test@test.com" : "");
  TextEditingController phoneController =
      new TextEditingController(text: kDebugMode ? "1234567890" : "");
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
  void dispose() {
    super.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPhoneMode = mode == Mode.phone;

    Widget phoneField() => InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            // phoneNumber = number;
            print(number.phoneNumber);
          },
          onInputValidated: (bool value) {
            print(value);
          },
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.DIALOG,
            trailingSpace: false,
            // setSelectorButtonAsPrefixIcon: true,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: TextStyle(color: Colors.black),
          // initialValue: number,
          textFieldController: phoneController,
          formatInput: false,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          inputBorder: OutlineInputBorder(),
          validator: (_) => null,
          onSaved: (PhoneNumber number) {
            print('On Saved: $number');
          },
        );
    Widget emailField() => TextFormField(
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
        );
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
                      "Login",
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
                    isPhoneMode ? phoneField() : emailField(),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: passwordController,
                      focusNode: passwordFocus,
                      obscureText: obscurity,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: isPhoneMode
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscurity
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => obscurity = !obscurity),
                          )),
                      validator: (val) => passwordController.text.length < 8
                          ? "The password should be 8 characters long"
                          : null,
                      onFieldSubmitted: (val) {
                        if (!isPhoneMode) confirmPasswordFocus.requestFocus();
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // isPhoneMode
                    //     ? Container()
                    //     : TextFormField(
                    //         focusNode: confirmPasswordFocus,
                    //         obscureText: obscurity,
                    //         keyboardType: TextInputType.visiblePassword,
                    //         textInputAction: TextInputAction.done,
                    //         decoration: InputDecoration(
                    //           labelText: "Confirm Password",
                    //           border: OutlineInputBorder(),
                    //         ),
                    //         validator: (val) => val == passwordController.text
                    //             ? null
                    //             : "The passwords do not match",
                    //       ),
                    // isPhoneMode
                    //     ? Container()
                    //     : SizedBox(
                    //         height: 16,
                    //       ),
                    SizedBox(
                      height: 32,
                    ),
                    Container(
                      width: Get.width,
                      child: ElevatedButton(
                        onPressed: () {
                          onSubmit();
                        },
                        child: Text("LOGIN"),
                        style: MyButtonStyles.onboardStyle,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() {
                          mode = mode == Mode.phone ? Mode.email : Mode.phone;
                        }),
                        child: Text(
                          mode == Mode.phone
                              ? "Use email insead"
                              : "Use phone number instead",
                          style: context.textTheme.caption!.copyWith(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text.rich(TextSpan(
                        text: "Not yet registered? ",
                        style: context.textTheme.caption!
                            .copyWith(color: Colors.black),
                        children: [
                          WidgetSpan(
                              child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            // onTap: () => setState(() => mode =
                            //     isLoginMode ? Mode.register : Mode.login),
                            onTap: () => Get.to(() => SignupPage()),
                            child: Text(
                              "Create Account",
                              style: context.textTheme.caption!
                                  .copyWith(color: appColor),
                            ),
                          ))
                        ])),
                    SizedBox(
                      height: 16,
                    ),
                    Text.rich(TextSpan(
                        text: "Forgot Password? ",
                        style: context.textTheme.caption!
                            .copyWith(color: Colors.black),
                        children: [
                          WidgetSpan(
                              child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            // onTap: () => setState(() => mode =
                            //     isLoginMode ? Mode.register : Mode.login),
                            onTap: () => Get.to(() => SignupPage(
                                  resetPassword: true,
                                )),
                            child: Text(
                              "Reset it",
                              style: context.textTheme.caption!
                                  .copyWith(color: appColor),
                            ),
                          ))
                        ])),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              )),
        )));
  }
}

enum Mode { phone, email }
