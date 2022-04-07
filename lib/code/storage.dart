import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wallet/code/constants.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();
  final box = GetStorage();

  String? authToken;
  String? sessionID;
  String? deviceID;
  String? pin;
  // Map<String, double> balances = {};
  // Map<String, String> currencies = {};
  List<String>? defaultWallets;

  init() {
    // box.remove("authToken");
    authToken = box.read("authToken");
    sessionID = box.read("sessionID");
    deviceID = box.read("deviceID");
    pin = box.read("pin");
    if (deviceID == null) getDeviceID();

    List<dynamic>? wallets = box.read("defaultWallets");
    if (wallets == null) {
      getInitialWallets();
    } else {
      defaultWallets = wallets.map((e) => e.toString()).toList();
    }
  }

  getDeviceID() async {
    if (Platform.isAndroid) {
      var deviceInfo = await DeviceInfoPlugin().androidInfo;
      deviceID = deviceInfo.androidId!;
    } else {
      var deviceInfo = await DeviceInfoPlugin().iosInfo;
      deviceID = deviceInfo.identifierForVendor!;
    }
  }

  getInitialWallets() {
    defaultWallets = currencyList
        .where((e) => e.coinData.selected)
        .map((e) => e.coinData.unit)
        .toList();
  }

  updateAuthToken(String value) {
    authToken = value;
    box.write("authToken", value);
  }

  updateSessionID(String value) {
    sessionID = value;
    box.write("sessionID", value);
  }

  updateDeviceID(String value) {
    deviceID = value;
    box.write("deviceID", value);
  }

  updatePIN(String value) {
    pin = value;
    box.write("pin", value);
  }

  updateDefaultWallets(String wallet, {required isSelected}) {
    if (isSelected && !defaultWallets!.contains(wallet)) {
      defaultWallets!.add(wallet);
    } else {
      defaultWallets!.remove(wallet);
    }
    box.write("defaultWallets", defaultWallets);
  }

  clearTokens() {
    authToken = null;
    sessionID = null;
    box.remove("authToken");
    box.remove("sessionID");
    box.remove("mnemonic");
    box.remove("pin");
  }

  // initBalances() {
  //   currencyList.forEach((element) {
  //     balances[element.coinData.unit] = 0;
  //   });
  //   box.write("balances", balances);
  // }

  // updateCurrencies(Map<String, String> data) {
  //   data.forEach((key, value) {});
  // }

  storeMnemonic(String mnemonic) {
    var iv = IV.fromLength(16);
    var key = Key.fromUtf8(encKey);
    var encrypter = Encrypter(AES(key));
    var encrypted = encrypter.encrypt(mnemonic, iv: iv);
    box.write("mnemonic", encrypted.base16);
  }

  readMnemonic() {
    String mnemonic = box.read("mnemonic");
    var iv = IV.fromLength(16);
    var key = Key.fromUtf8(encKey);
    var encrypter = Encrypter(AES(key));
    var decrypted = encrypter.decrypt16(mnemonic, iv: iv);
    return decrypted;
  }
}
