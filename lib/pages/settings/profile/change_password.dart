import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/widgets/common.dart';

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
  bool obscurity1 = true;
  bool obscurity2 = true;
  bool obscurity3 = true;
  bool submitting = false;

  _changePassword() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        submitting = true;
      });
      if (!widget.resetPassword) {
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
      } else {
        print(StorageService.instance.authToken);
        var response = await APIServices().resetPassword(
          newPassword: passwordController.text,
          authToken: StorageService.instance.authToken!,
        );
        setState(() {
          submitting = false;
        });
        print(response);
        if (response["success"]) {
          await Get.dialog(
            AlertDialog(
              title: Text("Success"),
              content: Text("Password Successfully Changed!, Please Login to continue."),
              actions: [
                TextButton(
                  onPressed: () => Get.offAll(() => LoginPage()),
                  child: Text("Okay"),
                ),
              ],
            ),
          );
        }
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
        height: widget.resetPassword ? 0 : 0,
      ),
      widget.resetPassword ? Container() : Align(alignment: Alignment.centerLeft, child: Text("Current Password")),
      widget.resetPassword
          ? Container()
          : SizedBox(
              height: 8,
            ),
      widget.resetPassword
          ? Container()
          : TextFormField(
              controller: currentPassController,
              obscureText: obscurity1,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Current Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                suffixIcon: IconButton(
                  icon: Icon(obscurity1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscurity1 = !obscurity1),
                ),
              ),
              // validator: (val) => val == passwordController.text
              //     ? null
              //     : "The passwords do not match",
            ),
      SizedBox(
        height: 16,
      ),
      Align(alignment: Alignment.centerLeft, child: Text("New Password")),
      SizedBox(
        height: 8,
      ),
      TextFormField(
        controller: passwordController,
        focusNode: passwordFocus,
        obscureText: obscurity2,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: "New Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          suffixIcon: IconButton(
            icon: Icon(obscurity2 ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => obscurity2 = !obscurity2),
          ),
        ),
        validator: (val) => passwordController.text.length < 8
            ? "The password should be 8 characters long"
            : passwordController.text == currentPassController.text
                ? "New password cannot be same as old password"
                : null,
        onFieldSubmitted: (val) {
          confirmPasswordFocus.requestFocus();
        },
      ),
      SizedBox(
        height: 16,
      ),
      Align(alignment: Alignment.centerLeft, child: Text("Confirm New Password")),
      SizedBox(
        height: 8,
      ),
      TextFormField(
        focusNode: confirmPasswordFocus,
        obscureText: obscurity3,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "Confirm New Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          suffixIcon: IconButton(
            icon: Icon(obscurity3 ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => obscurity3 = !obscurity3),
          ),
        ),
        validator: (val) => val == passwordController.text ? null : "The passwords do not match",
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        centerTitle: true,
        leading: widget.resetPassword ? Container() : CommonWidgets.backButton(context),
      ),
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
                // SizedBox(
                //   height: 16,
                // ),
                // Text(
                //   "Change Password",
                //   style: context.textTheme.headline4,
                // ),
                // SizedBox(
                //   height: 32,
                // ),
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
                          child: Text("Save Changes"),
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
