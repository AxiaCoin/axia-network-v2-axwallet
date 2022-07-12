import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  initAXCSDK();
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
  if (pubKey == null) {
    return services.initAXSDK();
  }
  HDWalletInfo walletInfo =
      await StorageService.instance.readMnemonicSeed(pubKey: pubKey);
  services.initAXSDK(mnemonic: walletInfo.mnemonic);
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
