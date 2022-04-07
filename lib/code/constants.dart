import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/currencies/bitcoin.dart';
import 'package:wallet/currencies/ethereum.dart';

MaterialColor appColor = Colors.pink;
Color tickerRed = Colors.red[900]!;
Color tickerGreen = Colors.green[800]!;

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: appColor,
    appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light));
ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: appColor,
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: Colors.black38));

class MyButtonStyles {
  MyButtonStyles._();
  static ButtonStyle onboardStyle =
      ElevatedButton.styleFrom(padding: EdgeInsets.all(16));
  static ButtonStyle statefulStyle(bool enabled) => ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        primary: enabled ? appColor : Colors.black12,
        shadowColor: enabled ? Colors.grey : Colors.transparent,
        splashFactory:
            enabled ? InkRipple.splashFactory : NoSplash.splashFactory,
      );
}

bool isTestNet = true;
List<Currency> currencyList = [
  Bitcoin(),
  Ethereum(),
];

String encKey = "keyForEncryptingMnemonic";
String dummyAddress = "1LwQsHAULv2dx8C5PVtxCGU9QG7VvFKTVn";
const ipAddress = "http://13.235.53.197:3000/";
String network = isTestNet ? "TESTNET" : "MAINNET";
