import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/widgets/common.dart';

class PinBiometricPage extends StatefulWidget {
  final String mnemonic;
  final String name;
  const PinBiometricPage({
    Key? key,
    required this.mnemonic,
    required this.name,
  }) : super(key: key);

  @override
  _PinBiometricPageState createState() => _PinBiometricPageState();
}

class _PinBiometricPageState extends State<PinBiometricPage> {
  final TextEditingController controller = TextEditingController();
  var localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool useBiometric = true;
  bool isValid = false;

  initAuthentication() async {
    canCheckBiometrics = await Services().canCheckBiometrics();
    setState(() {});
  }

  onSubmit() async {
    if (isValid) {
      if (useBiometric && canCheckBiometrics) {
        try {
          bool success = await localAuth.authenticate(
            localizedReason: "Please authenticate to continue to wallet",
          );
          if (success) {
            finishInitialization();
          } else {
            CommonWidgets.snackBar("Authentication failed. Please try again");
          }
          return;
        } on PlatformException catch (e) {
          if (e.code == auth_error.notAvailable) {
            print("Fingerprint Not Available");
            StorageService.instance.updateBiometricPreference(false);
          }
        }
      }
      finishInitialization();
    }
  }

  finishInitialization() async {
    StorageService.instance.updateBiometricPreference(useBiometric);
    StorageService.instance.updatePIN(controller.text);
    CommonWidgets.waitDialog();
    await services.createMCWallet(widget.mnemonic, widget.name);
    Get.offAll(() => HomePage());
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
      appBar: AppBar(
        title: Text("Security"),
        centerTitle: true,
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
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create a PIN for secure and easy access",
                    style: context.textTheme.headline5,
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
                            onChanged: (val) =>
                                setState(() => useBiometric = val),
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
                    child: TextButton(
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
          ],
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
