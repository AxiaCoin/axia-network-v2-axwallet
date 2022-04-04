import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/new_user/verify.dart';
import 'package:wallet/code/services.dart';

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
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  PhoneNumber phoneNumber = PhoneNumber();
  Mode mode = Mode.phone;
  bool obscurity = true;
  bool submitting = false;

  onSubmit() async {
    setState(() {
      submitting = true;
    });
    if (!widget.resetPassword) {
      var response = await APIServices().signUp(
        firstName: firstNameController.text,
        lastName:
            lastNameController.text == "" ? null : lastNameController.text,
        email: mode == Mode.email ? emailController.text : null,
        phoneNumber: mode == Mode.phone ? phoneNumber.parseNumber() : null,
        phoneCode:
            mode == Mode.phone ? phoneNumber.dialCode!.substring(1) : null,
        password: passwordController.text,
      );
      if (response["success"]) {
        var result = await APIServices().sendVerifyOTP(
          email: mode == Mode.email ? emailController.text : null,
          phoneNumber: mode == Mode.phone ? phoneNumber.parseNumber() : null,
          phoneCode:
              mode == Mode.phone ? phoneNumber.dialCode!.substring(1) : null,
        );
        if (result["success"]) {
          Get.to(() => VerificationPage(
                email: mode == Mode.email ? emailController.text : null,
                phoneNumber: mode == Mode.phone ? phoneNumber : null,
                resetPassword: widget.resetPassword,
              ));
        }
      }
    } else {
      var response = await APIServices().forgotPasswordOtp(
        email: mode == Mode.email ? emailController.text : null,
        phoneNumber: mode == Mode.phone ? phoneNumber.parseNumber() : null,
        phoneCode:
            mode == Mode.phone ? phoneNumber.dialCode!.substring(1) : null,
      );

      if (response["success"]) {
        Get.to(() => VerificationPage(
              email: mode == Mode.email ? emailController.text : null,
              phoneNumber: mode == Mode.phone ? phoneNumber : null,
              resetPassword: widget.resetPassword,
            ));
      }
    }
    setState(() {
      submitting = false;
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget phoneField() => InternationalPhoneNumberInput(
          initialValue: PhoneNumber(
            isoCode: kIsWeb ? null : Platform.localeName.split('_').last,
          ),
          onInputChanged: (PhoneNumber number) {
            phoneNumber = number;
            print(number.parseNumber());
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
          keyboardAction: TextInputAction.next,
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
            SizedBox(
              height: 16,
            ),
          ];
    List<Widget> nameFields = widget.resetPassword
        ? []
        : [
            TextFormField(
              controller: firstNameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val!.isNotEmpty
                  ? null
                  : "Please provide at least the first name",
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: lastNameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 16,
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
                  ...nameFields,
                  ...passwordFields,
                  submitting
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox(
                          width: Get.width,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                onSubmit();
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
