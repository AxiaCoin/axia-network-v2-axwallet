import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';
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
  final box = GetStorage();
  final AX1box = GetStorage('configuration');
  final AX2box = GetStorage('axia_wallet_sdk');
  var iv = IV.fromLength(16);
  var encrypter = Encrypter(AES(Key.fromUtf8(encKey)));

  String? authToken;
  String? sessionID;
  String? deviceID;
  String? pin;
  bool? useBiometric;
  bool isTestNet = true;
  // Map<String, double> balances = {};
  // Map<String, String> currencies = {};
  List<String>? defaultWallets;
  String? substrateWallets;
  String? isoCode;
  NetworkConfig? connectedNetwork;

  init() {
    // box.remove("authToken");
    // box.erase();
    authToken = box.read("authToken");
    sessionID = box.read("sessionID");
    deviceID = box.read("deviceID");
    pin = readPIN();
    isoCode = box.read("isoCode");
    isTestNet = true;
    useBiometric = box.read("useBiometric") ?? true;
    getConnectedNetwork();
    if (deviceID == null) getDeviceID();

    List<dynamic>? wallets = box.read("defaultWallets");
    if (wallets == null) {
      getInitialWallets();
    } else {
      defaultWallets = wallets.map((e) => e.toString()).toList();
    }
    substrateWallets = box.read("substrateWallets");
    if (substrateWallets == null) {
      generateSubstrateWallets();
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

  generateSubstrateWallets() {
    Map<String, String> wallets = {};
    substrateNetworks.forEach(
        (e) => wallets.addAll({e: CryptoWallet.dummyWallet().toJson()}));
    var stringified = jsonEncode(wallets);
    // var decoded = jsonDecode(stringified);
    substrateWallets = stringified;
    box.write("substrateWallets", stringified);
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
    var encrypted = encrypter.encrypt(value, iv: iv);
    pin = value;
    box.write("pin", encrypted.base16);
  }

  String? readPIN() {
    String? pin = box.read("pin");
    if (pin == null) return null;
    var decrypted = encrypter.decrypt16(pin, iv: iv);
    return decrypted;
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
  }

  updateDefaultWallets(String wallet, {required isSelected}) {
    if (isSelected && !defaultWallets!.contains(wallet)) {
      defaultWallets!.add(wallet);
    } else {
      defaultWallets!.remove(wallet);
    }
    box.write("defaultWallets", defaultWallets);
  }

  CryptoWallet getSubstrateWallet(String unit) {
    Map subWallet = jsonDecode(substrateWallets!);
    return CryptoWallet.fromJson(subWallet[unit]!);
  }

  updateSubstrateWallets(String unit, CryptoWallet wallet) {
    Map<String, dynamic> subWallet = jsonDecode(substrateWallets!);
    subWallet[unit] = wallet.toJson();
    substrateWallets = jsonEncode(subWallet);
    box.write("substrateWallets", substrateWallets);
  }

  updateWalletName(String newname) {
    WalletData walletData = Get.find();
    String pubKey = readCurrentPubKey()!;
    var hdWalletInfo = readMnemonicSeed();
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
    box.remove("authToken");
    box.remove("sessionID");
    box.remove("pubKey");
    box.remove("seeds");
    box.remove("pin");
    box.remove("defaultWallets");
    box.remove("substrateWallets");
    box.remove("useBiometric");
    box.remove("isTestNet");
  }

  storeCurrentPubKey(String pubKey) {
    var encrypted = encrypter.encrypt(pubKey, iv: iv);
    box.write("pubKey", encrypted.base16);
  }

  String? readCurrentPubKey() {
    String? pubKey = box.read("pubKey");
    if (pubKey == null) return null;
    var decrypted = encrypter.decrypt16(pubKey, iv: iv);
    return decrypted;
  }

  storeMnemonicSeed(String pubKey, HDWalletInfo walletInfo) {
    var encryptedSeed = encrypter.encrypt(walletInfo.toJson(), iv: iv);
    var encryptedPubKey = encrypter.encrypt(pubKey, iv: iv);
    var data = box.read("seeds");
    if (data == null) {
      data = {encryptedPubKey.base16: encryptedSeed.base16};
    } else {
      data[encryptedPubKey.base16] = encryptedSeed.base16;
    }
    box.write("seeds", data);
  }

  dynamic readMnemonicSeed({String? pubKey}) {
    var seeds = box.read("seeds");
    if (seeds == null) return null;
    // if (pubKey == null) {
    var data = {};
    seeds.forEach((key, value) {
      var decryptedSeed = encrypter.decrypt16(value, iv: iv);
      var decryptedPubKey = encrypter.decrypt16(key, iv: iv);
      data[decryptedPubKey] = HDWalletInfo.fromJson(decryptedSeed);
    });
    if (pubKey != null) return data[pubKey];
    return data;
  }
}
