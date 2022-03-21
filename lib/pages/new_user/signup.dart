import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/new_user/verify.dart';

class SignupPage extends StatefulWidget {
  final bool resetPassword;
  const SignupPage({
    Key? key,
    this.resetPassword = false,
  }) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  PhoneNumber phoneNumber = PhoneNumber();
  Mode mode = Mode.phone;
  bool obscurity = true;

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget phoneField() => InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            phoneNumber = number;
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
          onSaved: (PhoneNumber number) {
            print('On Saved: $number');
          },
        );
    Widget emailField() => TextFormField(
          controller: emailController,
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
        );
    List<Widget> passwordFields = widget.resetPassword
        ? []
        : [
            TextFormField(
              controller: passwordController,
              focusNode: passwordFocus,
              obscureText: obscurity,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscurity ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscurity = !obscurity),
                  )),
              validator: (val) => passwordController.text.length < 8
                  ? "The password should be 8 characters long"
                  : null,
              onFieldSubmitted: (val) {
                confirmPasswordFocus.requestFocus();
              },
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
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
          ];
    return Scaffold(
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.back(),
                    child: Text(
                      "← Back to Login",
                      style:
                          context.textTheme.caption!.copyWith(color: appColor),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.resetPassword ? "Reset Password" : "Sign up",
                    style: context.textTheme.headline4,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    "Please enter your ${mode == Mode.phone ? "phone number" : "email address"}",
                    style: context.textTheme.caption!.copyWith(fontSize: 24),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  mode == Mode.phone ? phoneField() : emailField(),
                  SizedBox(
                    height: 16,
                  ),
                  ...passwordFields,
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: Get.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Get.to(
                            () => VerificationPage(
                              device: mode == Mode.email
                                  ? emailController.text
                                  : phoneController.text,
                              resetPassword: widget.resetPassword,
                            ),
                          );
                        }
                      },
                      child: Text("Send Verification Code"),
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Mode { phone, email }
