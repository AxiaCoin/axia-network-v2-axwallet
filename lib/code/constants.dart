import 'package:flutter/material.dart';

MaterialColor appColor = Colors.pink;
Color tickerRed = Colors.red[900]!;
Color tickerGreen = Colors.green[800]!;

ThemeData lightTheme =
    ThemeData(brightness: Brightness.light, primarySwatch: appColor, appBarTheme: AppBarTheme(brightness: Brightness.dark));
ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: appColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.black38));

class MyButtonStyles {
  MyButtonStyles._();
  static ButtonStyle onboardStyle = ElevatedButton.styleFrom(padding: EdgeInsets.all(16));
  static ButtonStyle statefulStyle(bool enabled) => ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        primary: enabled ? appColor : Colors.black12,
        shadowColor: enabled ? Colors.grey : Colors.transparent,
        splashFactory: enabled ? InkRipple.splashFactory : NoSplash.splashFactory,
      );
}
