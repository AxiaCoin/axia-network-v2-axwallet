import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:axwallet_sdk/axwallet_sdk.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();
  final secureStorage = new FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final box = GetStorage();
  // final AX1box = GetStorage('configuration');
  // final AX2box = GetStorage('axia_wallet_sdk');
  String _pin = "pin";
  String _pubKey = "pubKey";
  String _walletKey = "wallets";
  String _authTokenKey = "authToken";
  String _sessionIDKey = "sessionID";

  String? authToken;
  String? sessionID;
  String? deviceID;
  String? pin;
  bool? useBiometric;
  bool isTestNet = true;
  List<String>? defaultWallets;
  String? isoCode;
  NetworkConfig? connectedNetwork;
  bool isNotMainNetReady = false;

  Future<void> init() async {
    if (box.read("isNotMainNetReady") ?? true) await resetStorage();
    isoCode = box.read("isoCode");
    isTestNet = box.read("isTestNet") ?? true;
    useBiometric = box.read("useBiometric") ?? true;
    deviceID = box.read("deviceID");
    if (deviceID == null) getDeviceID();
    getConnectedNetwork();
    getInitialWallets();
    await Future.wait([
      getPIN(),
      getAuthToken(),
      getSessionID(),
    ]);
  }

  resetStorage() async {
    box.erase();
    await secureStorage.deleteAll();
    box.write("isNotMainNetReady", false);
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
    List<dynamic>? data = box.read("defaultWallets");
    if (data != null) {
      defaultWallets = data.map((e) => e.toString()).toList();
    } else {
      defaultWallets = currencyList
          .where((e) => e.coinData.selected)
          .map((e) => e.coinData.unit)
          .toList();
    }
  }

  getConnectedNetwork() {
    var data = box.read("connectedNetwork");
    if (data == null) {
      connectedNetwork = null;
    } else {
      connectedNetwork = NetworkConfig.fromJson(data);
    }
  }

  updateAuthToken(String value) {
    authToken = value;
    secureStorage.write(key: _authTokenKey, value: value);
  }

  Future getAuthToken() async {
    authToken = await secureStorage.read(key: _authTokenKey);
  }

  updateSessionID(String value) {
    sessionID = value;
    secureStorage.write(key: _sessionIDKey, value: value);
  }

  Future getSessionID() async {
    sessionID = await secureStorage.read(key: _sessionIDKey);
  }

  updateDeviceID(String value) {
    deviceID = value;
    box.write("deviceID", value);
  }

  updatePIN(String value) {
    secureStorage.write(key: _pin, value: value);
  }

  Future<String?> getPIN() async {
    String? data = await secureStorage.read(key: _pin);
    return pin = data;
  }

  updateISOCode(String? value) {
    isoCode = value;
    box.write("isoCode", value);
  }

  updateBiometricPreference(bool value) {
    useBiometric = value;
    box.write("useBiometric", value);
  }

  updateNetworkType(bool value) {
    isTestNet = value;
    print("isTestnet:$isTestNet");
    box.write("isTestNet", value);
  }

  updateConnectedNetwork(NetworkConfig value) {
    connectedNetwork = value;
    box.write("connectedNetwork", value.toJson());
    isTestNet = value.isTestNet;
    updateNetworkType(isTestNet);
    network = isTestNet ? "TESTNET" : "MAINNET";
    if (services.walletData.hdWallet != null) {
      services.updateBalances();
    }
  }

  updateDefaultWallets(String wallet, {required isSelected}) {
    if (isSelected && !defaultWallets!.contains(wallet)) {
      defaultWallets!.add(wallet);
    } else {
      defaultWallets!.remove(wallet);
    }
    box.write("defaultWallets", defaultWallets);
  }

  updateWalletName(String newname) async {
    WalletData walletData = Get.find();
    String pubKey = (await readCurrentPubKey())!;
    var hdWalletInfo = await readMnemonicSeed();
    hdWalletInfo[pubKey].name = newname;
    HDWalletInfo walletInfo =
        HDWalletInfo.fromJson(hdWalletInfo[pubKey].toJson());
    storeMnemonicSeed(pubKey, walletInfo);
    services.hdWallets[pubKey]!.name = newname;
    walletData.updateWallet(pubKey);
    print("Wallet name updated");
  }

  clearTokens() {
    authToken = null;
    sessionID = null;
    pin = null;
    secureStorage.delete(key: _authTokenKey);
    secureStorage.delete(key: _sessionIDKey);
    secureStorage.delete(key: _pin);
    secureStorage.delete(key: _pubKey);
    secureStorage.delete(key: _walletKey);
    box.remove("defaultWallets");
    box.remove("useBiometric");
    box.remove("isTestNet");
  }

  storeCurrentPubKey(String pubKey) {
    secureStorage.write(key: _pubKey, value: pubKey);
  }

  Future<String?> readCurrentPubKey() async {
    return await secureStorage.read(key: _pubKey);
  }

  // storeMnemonicSeed(String pubKey, HDWalletInfo walletInfo) {
  //   var encryptedSeed = encrypter.encrypt(walletInfo.toJson(), iv: iv);
  //   var encryptedPubKey = encrypter.encrypt(pubKey, iv: iv);
  //   var data = box.read("seeds");
  //   if (data == null) {
  //     data = {encryptedPubKey.base16: encryptedSeed.base16};
  //   } else {
  //     data[encryptedPubKey.base16] = encryptedSeed.base16;
  //   }
  //   box.write("seeds", data);
  // }

  // dynamic readMnemonicSeed({String? pubKey}) {
  //   var seeds = box.read("seeds");
  //   if (seeds == null) return null;
  //   // if (pubKey == null) {
  //   var data = {};
  //   seeds.forEach((key, value) {
  //     var decryptedSeed = encrypter.decrypt16(value, iv: iv);
  //     var decryptedPubKey = encrypter.decrypt16(key, iv: iv);
  //     data[decryptedPubKey] = HDWalletInfo.fromJson(decryptedSeed);
  //   });
  //   if (pubKey != null) return data[pubKey];
  //   return data;
  // }

  storeMnemonicSeed(String pubKey, HDWalletInfo walletInfo) async {
    var wallets = await secureStorage.read(key: _walletKey);
    if (wallets == null) {
      Map<String, String> map = {pubKey: walletInfo.toJson()};
      await secureStorage.write(key: _walletKey, value: jsonEncode(map));
    } else {
      var map = jsonDecode(wallets);
      map[pubKey] = walletInfo.toJson();
      await secureStorage.write(key: _walletKey, value: jsonEncode(map));
    }
  }

  readMnemonicSeed({String? pubKey}) async {
    var wallets = await secureStorage.read(key: _walletKey);
    if (wallets == null) return;
    Map map = jsonDecode(wallets);
    Map<String, HDWalletInfo> data = map.map(
        (key, value) => MapEntry(key.toString(), HDWalletInfo.fromJson(value)));
    if (pubKey != null) return data[pubKey];
    return data;
  }
}
