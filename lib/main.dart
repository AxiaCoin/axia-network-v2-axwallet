import 'dart:convert';
import 'dart:io';

import 'package:axwallet_sdk/axwallet_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet/code/cache.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/pages/device_auth.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:wallet/pages/new_user/login.dart';

Future<void> main() async {
  await initServices();
  runApp(MyApp());
}

initServices() async {
  // Get.changeTheme(Get.isDarkMode ? darkTheme : lightTheme);
  // Get.changeTheme(Get.isDarkMode ? lightTheme : darkTheme);
  await Future.wait(
    [
      GetStorage.init(),
      GetStorage.init(CustomCacheManager.key),
    ],
  );
  await StorageService.instance.init();
  Get.put(TokenData());
  Get.put(BalanceData());
  Get.put(SettingsState());
  Get.put(WalletData());
  Get.put(AXCWalletData());
  // CustomCacheManager.instance.box.erase();

  // await services.initAXSDK(jsOnly: true);
  await initAXCSDK();
  // var mnemonics = StorageService.instance.readMnemonicSeed();
  // print('mnemonics are $mnemonics');
  // services.initSubstrateSDK();
  // StorageService.instance.clearTokens();
  // earn opinion sketch humble turn unaware keep defy what clay tip tribe
  // bone erase document label member evolve sense absent smoke dumb foster daring
}

initAXCSDK() async {
  String? pubKey = StorageService.instance.readCurrentPubKey();
  var nodes = CustomCacheManager.instance.networkConfigs();
  if (nodes.isEmpty) {
    await services.fetchNetworkConfigs();
  } else {
    services.fetchNetworkConfigs();
  }
  String jsCode = await _getJSCode();
  if (pubKey == null) {
    return services.initAXSDK(jsCode: jsCode);
  }
  HDWalletInfo walletInfo =
      await StorageService.instance.readMnemonicSeed(pubKey: pubKey);
  services.initAXSDK(mnemonic: walletInfo.mnemonic, jsCode: jsCode);
}

_getJSCode() async {
  Map? jsCode = await services.fetchJSCode();
  if (jsCode == null) return null;
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/js_code.json');
  String? localVersion;
  String? localJSCode;
  try {
    var data = jsonDecode(await file.readAsString());
    localVersion = data["version"];
    localJSCode = data["jsCode"];
  } catch (e) {
    print("failed to get local js code");
  }
  double currentLocal = double.parse(localVersion?.replaceAll(".", "") ?? "0");
  double currentPackage = double.parse(jsVersion.replaceAll(".", ""));
  double newCloud = double.parse(jsCode["version"].replaceAll(".", ""));
  if (newCloud > currentLocal && newCloud > currentPackage) {
    var jsFile =
        await APIServices().generalRequest(jsCode["url"], getBody: true);
    if (jsFile == null) return;
    var data = {"version": jsCode["version"], "jsCode": jsFile};
    await file.writeAsString(jsonEncode(data));
    return jsFile;
  }
  return currentLocal > currentPackage ? localJSCode : null;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // initServices();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: lightTheme,
        themeMode: ThemeMode.light,
        home: StorageService.instance.authToken == null
            ? LoginPage()
            : StorageService.instance.readCurrentPubKey() == null
                ? OnboardPage()
                : DeviceAuthPage(),
      ),
    );
  }
}
