import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
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
  await GetStorage.init();
  StorageService.instance.init();
  var mnemonics = StorageService.instance.readMnemonicSeed();
  print('mnemonics are $mnemonics');
  // services.initSubstrateSDK();
  // StorageService.instance.clearTokens();
  // earn opinion sketch humble turn unaware keep defy what clay tip tribe
  // bone erase document label member evolve sense absent smoke dumb foster daring
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
