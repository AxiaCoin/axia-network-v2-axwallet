import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:wallet/pages/wallet/index.dart';
import 'package:wallet/widgets/common.dart';

class DeviceAuthPage extends StatefulWidget {
  const DeviceAuthPage({Key? key}) : super(key: key);

  @override
  State<DeviceAuthPage> createState() => _DeviceAuthPageState();
}

class _DeviceAuthPageState extends State<DeviceAuthPage> {
  late String? mnemonic;
  final TextEditingController controller = TextEditingController();
  var localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool isValid = false;
  bool isSettingUp = Get.currentRoute == "/";

  initAuthentication() async {
    canCheckBiometrics = await Services().canCheckBiometrics();
    setState(() {});
    if (canCheckBiometrics && StorageService.instance.useBiometric!) {
      bool success = await localAuth.authenticate(
          localizedReason: isSettingUp
              ? "Please authenticate to continue to wallet"
              : "Please authenticate this Transaction",
          biometricOnly: false);
      if (success) {
        successful();
      } else {
        StorageService.instance.updateBiometricPreference(false);
      }
      return;
    }
    setState(() {});
  }

  onSubmit() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (isValid) {
      if (controller.text == StorageService.instance.pin) {
        successful();
      } else {
        CommonWidgets.snackBar("Incorrect PIN, try again");
        setState(() {
          controller.clear();
        });
      }
    }
  }

  successful() async {
    if (isSettingUp) {
      String mnemonic = StorageService.instance.readMnemonic()!;
      CommonWidgets.waitDialog();
      await services.initWallet(mnemonic);
      Get.offAll(() => HomePage());
    } else {
      Get.back(result: true);
      return;
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
    mnemonic = StorageService.instance.readMnemonic();
    initAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    isValid = controller.text.length == 6;
    onSubmit();
    return Scaffold(
      appBar: AppBar(
        title: Text("Security Check"),
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
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSettingUp
                        ? "Enter your PIN to access your Wallet"
                        : "Enter your PIN to authenticate to authenticate this Transaction",
                    style: context.textTheme.headline5,
                  ),
                  SizedBox(
                    height: 32,
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
                  canCheckBiometrics
                      ? SizedBox(
                          height: 32,
                        )
                      : Container(),
                  canCheckBiometrics
                      ? GestureDetector(
                          onTap: (() {
                            StorageService.instance
                                .updateBiometricPreference(true);
                            initAuthentication();
                          }),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Use Biometrics"),
                              Icon(Icons.fingerprint)
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
