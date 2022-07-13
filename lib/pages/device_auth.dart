import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/widgets/common.dart';

class DeviceAuthPage extends StatefulWidget {
  final String? mnemonic;
  final String? name;
  final bool isChangingPin;
  const DeviceAuthPage({
    Key? key,
    this.mnemonic,
    this.name,
    this.isChangingPin = false,
  }) : super(key: key);

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
    print(StorageService.instance.useBiometric!);
    bool isBiometricAllowed = canCheckBiometrics &&
        StorageService.instance.useBiometric! &&
        !widget.isChangingPin;
    if (isBiometricAllowed) {
      bool success = await localAuth
          .authenticate(
        localizedReason: isSettingUp
            ? "Please authenticate to continue to wallet"
            : "Please authenticate this Transaction",
      )
          .catchError((onError) {
        return false;
      });
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
    if (widget.mnemonic != null) {
      createNewWallet();
    } else if (isSettingUp) {
      String pubKey = StorageService.instance.readCurrentPubKey()!;
      CommonWidgets.waitDialog();
      await services.initMCWallet(pubKey);
      Get.offAll(() => HomePage());
    } else {
      Get.back(result: true);
      return;
    }
  }

  createNewWallet() async {
    CommonWidgets.waitDialog();
    await services.createMCWallet(widget.mnemonic!, widget.name!);
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
    onSubmit();
    return WillPopScope(
      onWillPop: () async => !isSettingUp,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Security Check"),
          centerTitle: true,
          leading: isSettingUp ? null : CommonWidgets.backButton(context),
        ),
        floatingActionButton: kDebugMode
            ? FloatingActionButton(
                child: Icon(Icons.developer_board),
                onPressed: () {
                  var api = services.axSDK.api!;
                  api.basic.tests();
                },
              )
            : null,
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
                          : "Enter your PIN to authenticate",
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
                    canCheckBiometrics && !widget.isChangingPin
                        ? SizedBox(
                            height: 32,
                          )
                        : Container(),
                    canCheckBiometrics && !widget.isChangingPin
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
      ),
    );
  }
}
