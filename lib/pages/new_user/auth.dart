import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController controller = TextEditingController();
  var localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool useBiometric = true;
  bool isValid = false;

  initAuthentication() async {
    canCheckBiometrics = await localAuth.canCheckBiometrics;
    setState(() {});
  }

  onSubmit() async {
    if (isValid) {
      if (useBiometric) {
        try {
          bool success = await localAuth.authenticate(
              localizedReason: "Please authenticate to continue to wallet",
              biometricOnly: true);
          if (success)
            Get.offAll(OnboardPage());
          else
            return;
        } on PlatformException catch (e) {
          if (e.code == auth_error.notAvailable) {
            print("Fingerprint Not Available");
          }
        }
      }
      Get.offAll(OnboardPage());
    }
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: appColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void initState() {
    super.initState();
    initAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    isValid = controller.text.length == 6;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Create a PIN for easy access",
                style: context.textTheme.headline3,
              ),
              SizedBox(
                height: 8,
              ),
              PinPut(
                fieldsCount: 6,
                autofocus: true,
                controller: controller,
                pinAnimationType: PinAnimationType.slide,
                obscureText: "*",
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
                  setState(() {});
                },
              ),
              SizedBox(
                height: 16,
              ),
              canCheckBiometrics
                  ? SizedBox(
                      width: Get.width * 0.9,
                      child: SwitchListTile.adaptive(
                        value: useBiometric,
                        onChanged: (val) => setState(() => useBiometric = val),
                        title: Text(
                            "Enable FaceID/Fingerprint for even easier access"),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 32,
              ),
              SizedBox(
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    onSubmit();
                  },
                  child: Text("CONTINUE"),
                  style: MyButtonStyles.statefulStyle(isValid),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
