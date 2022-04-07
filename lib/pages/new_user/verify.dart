import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pin_put/pin_put.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';

class VerificationPage extends StatefulWidget {
  final String? email;
  final PhoneNumber? phoneNumber;
  final bool resetPassword;
  const VerificationPage({
    Key? key,
    this.email,
    this.phoneNumber,
    required this.resetPassword,
  }) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  TextEditingController controller = TextEditingController();
  bool submitting = false;
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: appColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  _verifyCode({required String code}) async {
    if (!widget.resetPassword) {
      var response = await APIServices().userVerify(
        phoneNumber: widget.phoneNumber != null
            ? widget.phoneNumber!.parseNumber()
            : null,
        phoneCode: widget.phoneNumber != null
            ? widget.phoneNumber!.dialCode!.substring(1)
            : null,
        otp: code,
      );
      if (response["success"]) {
        CommonWidgets.snackBar(
            "Account created successfully. Please login to continue.",
            duration: 3);
        Get.offAll(() => LoginPage());
      } else {
        setState(() {
          submitting = false;
        });
        // CommonWidgets.snackBar("Incorrect code entered");
      }
    } else {
      // var response = await APIServices().resetPassword();

      setState(() {
        submitting = false;
      });
    }
  }

  _sendCode() async {
    // var response =
    //     APIServices().signUp(firstName: firstName, password: password);
  }

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.back(),
                child: Text(
                  "← Back to Signup",
                  style: context.textTheme.caption!.copyWith(color: appColor),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Verify Code",
                style: context.textTheme.headline4,
              ),
              SizedBox(
                height: 32,
              ),
              Text(
                "Please enter the verification code sent to ${widget.email ?? widget.phoneNumber?.phoneNumber ?? "your device"}",
              ),
              SizedBox(
                height: 16,
              ),
              PinPut(
                fieldsCount: 6,
                autofocus: true,
                controller: controller,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                submittedFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                selectedFieldDecoration: _pinPutDecoration,
                followingFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: appColor.withOpacity(.5),
                  ),
                ),
                onChanged: (val) {
                  if (controller.text.length == 6) {
                    submitting = true;
                    _verifyCode(code: controller.text);
                  } else {
                    submitting = false;
                  }
                  setState(() {});
                },
              ),
              SizedBox(
                height: 16,
              ),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() {
                    CommonWidgets.snackBar("The code has been resent");
                  }),
                  child: Text(
                    "Resend verification code",
                    style: context.textTheme.caption!.copyWith(),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              submitting
                  ? Center(child: CircularProgressIndicator())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
