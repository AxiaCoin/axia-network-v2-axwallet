import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();
  final box = GetStorage();
  var iv = IV.fromLength(16);
  var encrypter = Encrypter(AES(Key.fromUtf8(encKey)));

  String? authToken;
  String? sessionID;
  String? deviceID;
  String? pin;
  bool? useBiometric;
  bool isTestNet = false;
  // Map<String, double> balances = {};
  // Map<String, String> currencies = {};
  List<String>? defaultWallets;
  String? substrateWallets;
  String? isoCode;

  init() {
    // box.remove("authToken");
    // box.erase();
    authToken = box.read("authToken");
    sessionID = box.read("sessionID");
    deviceID = box.read("deviceID");
    pin = readPIN();
    isoCode = box.read("isoCode");
    isTestNet = box.read("isTestNet") ?? false;
    useBiometric = box.read("useBiometric") ?? true;
    print("isTestnet:$isTestNet");
    isTestNet = box.read("networkType") ?? true;
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
    defaultWallets = currencyList.where((e) => e.coinData.selected).map((e) => e.coinData.unit).toList();
  }

  generateSubstrateWallets() {
    Map<String, String> wallets = {};
    substrateNetworks.forEach((e) => wallets.addAll({e: CryptoWallet.dummyWallet().toJson()}));
    var stringified = jsonEncode(wallets);
    // var decoded = jsonDecode(stringified);
    substrateWallets = stringified;
    box.write("substrateWallets", stringified);
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

  clearTokens() {
    authToken = null;
    sessionID = null;
    box.remove("authToken");
    box.remove("sessionID");
    box.remove("mnemonic");
    box.remove("pin");
    box.remove("defaultWallets");
    box.remove("substrateWallets");
    box.remove("useBiometric");
    box.remove("isTestNet");
  }

  networkclearTokens() {
    // box.remove("defaultWallets");
    // box.remove("substrateWallets");
    box.remove("isTestNet");
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

  storeCurrentMnemonic(String mnemonic) {
    var encrypted = encrypter.encrypt(mnemonic, iv: iv);
    box.write("mnemonic", encrypted.base16);
  }

  String? readCurrentMnemonic() {
    String? mnemonic = box.read("mnemonic");
    if (mnemonic == null) return null;
    var decrypted = encrypter.decrypt16(mnemonic, iv: iv);
    return decrypted;
  }

  storeMnemonicSeed(String mnemonic, String seed) {
    var encryptedSeed = encrypter.encrypt(seed, iv: iv);
    var encryptedMnemonic = encrypter.encrypt(mnemonic, iv: iv);
    var data = box.read("seeds");
    if (data == null) {
      data = {encryptedMnemonic.base16: encryptedSeed.base16};
    } else {
      data[encryptedMnemonic.base16] = encryptedSeed.base16;
    }
    box.write("seeds", data);
    print("written seeds are $data");
  }

  dynamic readMnemonicSeed({String? mnemonic}) {
    var seeds = box.read("seeds");
    if (seeds == null) return null;
    print("read seeds are $seeds");
    if (mnemonic == null) {
      var data = {};
      seeds.forEach((key, value) {
        var decryptedSeed = encrypter.decrypt16(value, iv: iv);
        var decryptedMnemonic = encrypter.decrypt16(key, iv: iv);
        data[decryptedMnemonic] = decryptedSeed;
      });
      print("processed seeds are $data");
      return data;
    }
    print("processed seed is ${encrypter.decrypt16(seeds[mnemonic], iv: iv)}");
    return encrypter.decrypt16(seeds[mnemonic], iv: iv);
  }
}
