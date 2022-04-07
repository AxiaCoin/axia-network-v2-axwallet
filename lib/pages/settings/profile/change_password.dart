import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/services.dart';

class ChangePassword extends StatefulWidget {
  final bool resetPassword;
  const ChangePassword({
    Key? key,
    required this.resetPassword,
  }) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final formKey = GlobalKey<FormState>();
  TextEditingController currentPassController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  bool obscurity = true;
  bool submitting = false;

  _changePassword() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        submitting = true;
      });
      var response = await APIServices().userPasswordUpdate(
        newPassword: passwordController.text,
        currentPassword: currentPassController.text,
      );
      setState(() {
        submitting = false;
      });
      print(response);
      if (response["success"]) {
        await Get.dialog(
          AlertDialog(
            title: Text("Success"),
            content: Text("Password Successfully Changed!"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("Okay"),
              ),
            ],
          ),
        );
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    currentPassController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> passwordFields = [
      SizedBox(
        height: widget.resetPassword ? 0 : 16,
      ),
      widget.resetPassword
          ? Container()
          : TextFormField(
              controller: currentPassController,
              obscureText: obscurity,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon:
                      Icon(obscurity ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscurity = !obscurity),
                ),
              ),
              // validator: (val) => val == passwordController.text
              //     ? null
              //     : "The passwords do not match",
            ),
      SizedBox(
        height: 16,
      ),
      TextFormField(
        controller: passwordController,
        focusNode: passwordFocus,
        obscureText: obscurity,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: "New Password",
          border: OutlineInputBorder(),
          suffixIcon: widget.resetPassword
              ? IconButton(
                  icon:
                      Icon(obscurity ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscurity = !obscurity),
                )
              : null,
        ),
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
          labelText: "Confirm New Password",
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GestureDetector(
                //   behavior: HitTestBehavior.opaque,
                //   onTap: () => Get.back(),
                //   child: Text(
                //     "← Back to Login",
                //     style: context.textTheme.caption!.copyWith(color: appColor),
                //   ),
                // ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Change Password",
                  style: context.textTheme.headline4,
                ),
                SizedBox(
                  height: 32,
                ),
                // Text(
                //   "Please enter your ${mode == Mode.phone ? "phone number" : "email address"}",
                //   style: context.textTheme.caption!.copyWith(fontSize: 24),
                // ),
                // SizedBox(
                //   height: 16,
                // ),
                // mode == Mode.phone ? phoneField() : emailField(),
                // SizedBox(
                //   height: 16,
                // ),
                ...passwordFields,
                SizedBox(
                  height: 16,
                ),
                submitting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        width: Get.width,
                        child: TextButton(
                          onPressed: () {
                            _changePassword();
                          },
                          child: Text("Change Password"),
                          style: MyButtonStyles.onboardStyle,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
