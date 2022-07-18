import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/currencies/axiacoin.dart';
import 'package:wallet/currencies/bitcoin.dart';
import 'package:wallet/currencies/ethereum.dart';

Map<int, Color> getSwatch(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final lightness = hslColor.lightness;
  final lowDivisor = 6;
  final highDivisor = 5;

  final lowStep = (1.0 - lightness) / lowDivisor;
  final highStep = lightness / highDivisor;

  return {
    50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
    100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
    200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
    300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
    400: (hslColor.withLightness(lightness + lowStep)).toColor(),
    500: (hslColor.withLightness(lightness)).toColor(),
    600: (hslColor.withLightness(lightness - highStep)).toColor(),
    700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
    800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
    900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
  };
}

MaterialColor appColor =
    MaterialColor(Color(0xff178fe1).value, getSwatch(Color(0xff178fe1)));
// MaterialColor appColor = MaterialColor(0xff178FE1, {
//   50: Color(0xFFE3F2FD),
//   100: Color(0xFFBBDEFB),
//   200: Color(0xFF90CAF9),
//   300: Color(0xFF64B5F6),
//   400: Color(0xFF42A5F5),
//   500: Color(0xff178FE1),
//   600: Color(0xFF007CBD),
//   700: Color(0xFF1976D2),
//   800: Color(0xFF1565C0),
//   900: Color(0xFF0D47A1),
// });
Color tickerRed = Color(0xffF12F2F);
Color tickerGreen = Color(0xff35B994);
Color appGrey = Colors.grey[50]!;

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
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 2,
    ));
ThemeData darkTheme = lightTheme.copyWith(
  brightness: Brightness.dark,
  bottomNavigationBarTheme:
      BottomNavigationBarThemeData(backgroundColor: Colors.black38),
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
        splashFactory:
            enabled ? InkRipple.splashFactory : NoSplash.splashFactory,
      );
}

// bool isTestNet = true;
List<String> substrateNetworks = ["AXC"];
List<Currency> currencyList = [
  // AXIACoin(),
  Bitcoin(),
  Ethereum(),
];

String encKey = "keyForEncryptingMnemonic";
String dummyAddress = "1LwQsHAULv2dx8C5PVtxCGU9QG7VvFKTVn";
const ipAddress = "http://13.235.53.197:3000/";
const denomination = 9;
bool isMulticurrencyEnabled = false;
String network = StorageService.instance.isTestNet ? "TESTNET" : "MAINNET";
const networkConfigURL = "https://pastebin.com/raw/RiUt8Lsn";
const networkConfigURLAlt = "https://pastebinp.com/raw/RiUt8Lsn";
const jsCodeURL = "https://pastebin.com/raw/Le82ZE1s";
const jsCodeURLAlt = "https://pastebinp.com/raw/Le82ZE1s";
const jsVersion = "2.0.2";
int minStakeAmount = 20;
int minAddValidatorStake = 100000;
int minStakeDays = 120;
// int satoshi = 100000000;
// int wei = 1000000000000000000;