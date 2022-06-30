import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/pages/settings/profile/change_password.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/spinner.dart';

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
        email: widget.email != null ? widget.email : "",
        phoneNumber:
            widget.phoneNumber != null ? widget.phoneNumber!.parseNumber() : "",
        phoneCode: widget.phoneNumber != null
            ? widget.phoneNumber!.dialCode!.substring(1)
            : "",
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
        CommonWidgets.snackBar("Incorrect code entered");
      }
    } else {
      var response = await APIServices().verifyforgotPasswordOtp(
          email: widget.email != null ? widget.email : "",
          phoneNumber: widget.phoneNumber != null
              ? widget.phoneNumber!.parseNumber()
              : "",
          phoneCode: widget.phoneNumber != null
              ? widget.phoneNumber!.dialCode!.substring(1)
              : "",
          otp: code);
      if (response["success"]) {
        String authToken = response["data"]["authToken"];
        Get.off(() => ChangePassword(
              resetPassword: true,
              authToken: authToken,
            ));
        CommonWidgets.snackBar("OTP Verified successfully", duration: 3);
      } else {
        setState(() {
          submitting = false;
        });
        CommonWidgets.snackBar("Incorrect code entered");
      }
    }
    setState(() {
      submitting = false;
      controller.clear();
    });
  }

  _sendCode() async {
    // var response =
    //     APIServices().signUp(firstName: firstName, password: password);
  }

  @override
  void initState() {
    super.initState();
    _sendCode();
    // print(widget.email);
    // print(widget.phoneNumber?.parseNumber());
    // print(widget.phoneNumber?.dialCode!.substring(1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify"),
        centerTitle: true,
        leading: CommonWidgets.backButton(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: Get.height * 0.15,
              color: appColor[600],
            ),
            CommonWidgets.elevatedContainer(
              padding: 16,
              margin: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 16,
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
                    inputFormatters: InputFormatters.amountFilter(),
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
                        if (submitting) return;
                        setState(() {
                          submitting = true;
                        });
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
                      onTap: () async {
                        if (widget.resetPassword) {
                          await APIServices().forgotPasswordOtp(
                            email: widget.email != null ? widget.email : "",
                            phoneNumber: widget.phoneNumber != null
                                ? widget.phoneNumber!.parseNumber()
                                : "",
                            phoneCode: widget.phoneNumber != null
                                ? widget.phoneNumber!.dialCode!.substring(1)
                                : "",
                          );
                        } else {
                          await APIServices().sendVerifyOTP(
                            email: widget.email != null ? widget.email : "",
                            phoneNumber: widget.phoneNumber != null
                                ? widget.phoneNumber!.parseNumber()
                                : "",
                            phoneCode: widget.phoneNumber != null
                                ? widget.phoneNumber!.dialCode!.substring(1)
                                : "",
                          );
                        }

                        CommonWidgets.snackBar("The code has been sent again");
                      },
                      child: Text(
                        "Resend verification code",
                        style: context.textTheme.caption!.copyWith(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  submitting ? Center(child: Spinner()) : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
