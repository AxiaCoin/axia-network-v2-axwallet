import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/currencies/axiacoin.dart';
import 'package:wallet/currencies/sub_axiacoin.dart';
import 'package:wallet/currencies/bitcoin.dart';
import 'package:wallet/currencies/ethereum.dart';

MaterialColor appColor = MaterialColor(0xff178FE1, {
  50: Color(0xFFE3F2FD),
  100: Color(0xFFBBDEFB),
  200: Color(0xFF90CAF9),
  300: Color(0xFF64B5F6),
  400: Color(0xFF42A5F5),
  500: Color(0xff178FE1),
  600: Color(0xFF007CBD),
  700: Color(0xFF1976D2),
  800: Color(0xFF1565C0),
  900: Color(0xFF0D47A1),
});
Color tickerRed = Color(0xffF12F2F);
Color tickerGreen = Color(0xff35B994);

ThemeData lightTheme = ThemeData(
  fontFamily: "MADETommySoft",
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  // colorSchemeSeed: appColor,
  primarySwatch: appColor,
  // elevatedButtonTheme: ,
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF000000),
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    color: appColor[600],
    elevation: 0,
  ),
);
ThemeData darkTheme = lightTheme.copyWith(
  brightness: Brightness.dark,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.black38),
);

class MyButtonStyles {
  MyButtonStyles._();
  static ButtonStyle onboardStyle = TextButton.styleFrom(
    padding: EdgeInsets.all(16),
    backgroundColor: appColor,
    primary: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12),
      ),
    ),
  );
  static ButtonStyle statefulStyle(bool enabled) => TextButton.styleFrom(
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        backgroundColor: enabled ? appColor : Colors.grey[100],
        primary: enabled ? Colors.white : Colors.black12,
        splashFactory: enabled ? InkRipple.splashFactory : NoSplash.splashFactory,
      );
}

// bool isTestNet = true;
List<String> substrateNetworks = ["AXC"];
List<Currency> currencyList = [
  Bitcoin(),
  Ethereum(),
  AXIACoin(),
];

String encKey = "keyForEncryptingMnemonic";
String dummyAddress = "1LwQsHAULv2dx8C5PVtxCGU9QG7VvFKTVn";
const ipAddress = "http://13.235.53.197:3000/";
String network = StorageService.instance.isTestNet ? "TESTNET" : "MAINNET";
// int satoshi = 100000000;
// int wei = 1000000000000000000;