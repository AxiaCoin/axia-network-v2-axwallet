import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:wallet/pages/new_user/login.dart';

Future<void> main() async {
  // await initServices();
  runApp(MyApp());
}

initServices() async {
  // Get.changeTheme(Get.isDarkMode ? darkTheme : lightTheme);
  Get.changeTheme(Get.isDarkMode ? lightTheme : darkTheme);
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
        home: LoginPage(),
      ),
    );
  }
}
