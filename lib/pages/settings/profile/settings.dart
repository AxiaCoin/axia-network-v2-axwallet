import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/device_auth.dart';
import 'package:wallet/pages/new_user/pin_biometric.dart';
import 'package:wallet/pages/settings/profile/change_password.dart';
import 'package:wallet/widgets/common.dart';

class NewSettingsPage extends StatefulWidget {
  const NewSettingsPage({Key? key}) : super(key: key);

  @override
  State<NewSettingsPage> createState() => _NewSettingsPageState();
}

class _NewSettingsPageState extends State<NewSettingsPage> {
  var localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;

  initAuthentication() async {
    canCheckBiometrics = await Services().canCheckBiometrics();
    setState(() {});
  }

  void toggleBiometrics(bool value) async {
    bool success = await localAuth.authenticate(
        localizedReason: "Please authenticate to toggle");
    if (success) StorageService.instance.updateBiometricPreference(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Settings"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );
    return Scaffold(
      appBar: appBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(children: [
          canCheckBiometrics
              ? SizedBox(
                  // width: Get.width * 0.9,
                  child: SwitchListTile.adaptive(
                    value: StorageService.instance.useBiometric!,
                    onChanged: toggleBiometrics,
                    title: Text("Enable FaceID/Fingerprint"),
                  ),
                )
              : Container(),
          SizedBox(
            width: Get.width,
            child: TextButton(
              onPressed: () async {
                var data =
                    await Get.to(() => DeviceAuthPage(isChangingPin: true));
                if (data != null && data == true) {
                  var isChanged =
                      await Get.to(() => PinBiometricPage()) ?? false;
                  if (isChanged) {
                    CommonWidgets.snackBar("PIN successfully Changed");
                  }
                }
                // Get.to(() => ChangePassword(resetPassword: false));
              },
              child: Text("Change PIN"),
              style: MyButtonStyles.onboardStyle,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            width: Get.width,
            child: TextButton(
              onPressed: () {
                Get.to(() => ChangePassword(resetPassword: false));
              },
              child: Text("Change Account Password"),
              style: MyButtonStyles.onboardStyle,
            ),
          ),
        ]),
      ),
    );
  }
}
