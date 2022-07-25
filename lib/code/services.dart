import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:coinslib/coinslib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/cache.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/widgets/common.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:axwallet_sdk/axwallet_sdk.dart';
import 'package:path_provider/path_provider.dart';

class IsolateParams {
  String mnemonic;
  SendPort sendPort;
  IsolateParams(
    this.mnemonic,
    this.sendPort,
  );
}

String toSeed(String mnemonic) {
  return HexEncoder().convert(bip39.mnemonicToSeed(mnemonic));
}

Services services = Services();

enum AXCWalletStatus {
  idle,
  loading,
  finished,
}

class Services {
  HDWallet? hdWallet;
  WalletData walletData = Get.put(WalletData());
  Map<String, HDWalletInfo> hdWallets = {};
  Timer? timer;
  Timer? timerAXC;
  AXCWalletStatus axcWalletStatus = AXCWalletStatus.idle;

  AXwalletSDK axSDK = AXwalletSDK();

  initAXSDK({String? mnemonic}) async {
    String? jsCode = await getJSCode();
    if (mnemonic != null) axcWalletStatus = AXCWalletStatus.loading;
    if (axSDK.api == null) {
      await axSDK.init(jsCode: jsCode);
    }
    if (mnemonic != null) {
      var networks = CustomCacheManager.instance
          .networkConfigs(); // This is never empty by design
      NetworkConfig? lastConnected = StorageService.instance.connectedNetwork;
      NetworkConfig? network;
      NetworkConfig first = networks.first;
      if (lastConnected != null) {
        try {
          network = networks.firstWhere((element) => element == lastConnected);
        } catch (e) {}
      }
      network ??= first;
      bool isSuccessful =
          await axSDK.api!.basic.init(mnemonic: mnemonic, network: network);
      if (isSuccessful) {
        StorageService.instance.updateConnectedNetwork(network);
      } else {
        // Will return false when the cached network config is out of order.
        // New active network configs will have been fetched by this time and
        // another attempt can be made.
        await Future.delayed(Duration(milliseconds: 500));
        return await initAXSDK(mnemonic: mnemonic);
      }
      getAXCWalletDetails();
      axcWalletStatus = AXCWalletStatus.finished;
    }
  }

  String generateMnemonic() {
    return bip39.generateMnemonic(strength: 256);
  }

  validateMnemonic(String mnemonic) {
    try {
      return bip39.validateMnemonic(mnemonic);
    } catch (e) {
      print(e);
      CommonWidgets.snackBar(e.toString());
      return false;
    }
  }

  Future<void> createMCWallet(String mnemonic, String name) async {
    String seed = await compute(toSeed, mnemonic);
    var seedData = HexDecoder().convert(seed) as Uint8List;
    HDWallet wallet = HDWallet.fromSeed(seedData);
    HDWalletInfo walletInfo = HDWalletInfo(
        seed: seed, name: name, mnemonic: mnemonic, hdWallet: wallet);
    await StorageService.instance.storeMnemonicSeed(wallet.pubKey!, walletInfo);
    hdWallets[wallet.pubKey!] = walletInfo;
    await StorageService.instance.storeCurrentPubKey(wallet.pubKey!);
    await initMCWallet(wallet.pubKey!);
  }

  initMCWallet(String? pubKey, {int retryCount = 0}) async {
    String? currentPubKey = walletData.hdWallet?.value.pubKey!;
    bool isChangingWallet =
        pubKey != null && currentPubKey != null && currentPubKey != pubKey;
    print("isChangingWallet = $isChangingWallet");
    var mnemonicSeeds = await StorageService.instance.readMnemonicSeed();
    if (mnemonicSeeds == null || mnemonicSeeds.isEmpty) return;
    mnemonicSeeds.forEach((key, value) {
      var seedData = HexDecoder().convert(value.seed) as Uint8List;
      value.hdWallet = HDWallet.fromSeed(seedData);
      hdWallets[key] = value;
    });
    if (pubKey != null) {
      // if (axcWalletStatus == AXCWalletStatus.loading) {
      //   print("Wallet Loading. Please wait ($retryCount)");
      //   await Future.delayed(Duration(milliseconds: 1000));
      //   return await initMCWallet(pubKey, retryCount: retryCount + 1);
      // }
      walletData.updateWallet(pubKey);
      if (isChangingWallet || axcWalletStatus == AXCWalletStatus.idle) {
        await this.initAXSDK(mnemonic: hdWallets[pubKey]!.mnemonic);
      }
      StorageService.instance.storeCurrentPubKey(pubKey);
      AXCWalletData axcWalletData = Get.find();
      axcWalletData.setCachedData();
      print("wallet created");
      currencyList.forEach(
        (e) => e.getWallet(),
      );
    }
  }

  getAXCWalletDetails() async {
    AXCWalletData axcWalletData = Get.find();
    axcWalletData.setCachedData();
    update() async {
      var api = this.axSDK.api!;
      var data = await Future.wait([
        api.basic.getWallet(),
        api.basic.getBalance(),
        api.transfer.getTransactions(),
      ]);
      AXCWallet wallet = AXCWallet.fromMap(data[0]);
      AXCBalance balance = AXCBalance.fromMap(data[1]);
      List<AXCTransaction> transactions = data[2];
      CustomCacheManager.instance.cacheAddress(wallet);
      CustomCacheManager.instance.cacheBalance(balance);
      CustomCacheManager.instance.cacheTransactions(transactions);
      axcWalletData.updateWallet(wallet);
      axcWalletData.updateBalance(balance);
      axcWalletData.updateTransactions(transactions);
    }

    if (timerAXC != null) {
      timerAXC?.cancel();
    }
    await update();

    // called only once when any configs/wallets change
    updateValidators();

    timerAXC = Timer.periodic(Duration(minutes: 1), (t) {
      update();
    });
  }

  updateValidators() async {
    var response = (await axSDK.api!.nomination.getValidators()) as List;
    List<ValidatorItem> validators =
        response.map((e) => ValidatorItem.fromMap(e)).toList();
    validators
        .sort((a, b) => b.nominators.length.compareTo(a.nominators.length));
    CustomCacheManager.instance.cacheValidators(validators);
  }

  updateBalances() async {
    BalanceData balanceCont = Get.find();
    void update() async {
      if (!isMulticurrencyEnabled) {
        balanceCont.updateAXCBalance();
        return;
      }
      await Future.wait(currencyList.map((e) async {
        double balance = (await e.getBalance()).toDouble();
        balanceCont.updateBalance(e, balance);
      }));
    }

    if (timer != null) {
      timer?.cancel();
    }
    update();
    timer = Timer.periodic(Duration(seconds: 10), (t) {
      update();
    });
  }

  deleteWallet(BuildContext context, String pubKey) async {
    String current = walletData.hdWallet!.value.pubKey!;
    hdWallets.remove(pubKey);
    StorageService.instance.removeMnemonicSeed(pubKey);
    print("hdWallets is $hdWallets");
    if (hdWallets.isEmpty) {
      print("wallet is empty");
      StorageService.instance.clearCurrentPubKey();
      Get.offAll(() => OnboardPage());
    } else if (current == pubKey) {
      print("deleting me $pubKey");
      String nextPubKey = hdWallets.entries.first.key;
      CommonWidgets.waitDialog(
          text: "Switching to a different wallet. Please wait");
      print("new key is $nextPubKey");
      await initMCWallet(nextPubKey);
      hdWallets
          .remove(pubKey); // need to call this for reasons I have no answer for
      Get.back();
    } else {
      print("deleting other");
      CommonWidgets.snackBar("Wallet Deleted!");
    }
  }

  logOut({bool showMessage = true}) async {
    bool? confirm = await Get.dialog(
      AlertDialog(
        title: Text("Do you want to logout of your current account?"),
        content: showMessage
            ? Text(
                "This will remove the wallet(s) you have created and you will need to re-import them with the secret phrase.\n"
                "If you do not have access to the secret phrase(s) then you risk losing all the assets and we cannot help you recover them!")
            : null,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text("Logout"),
          ),
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
    if (confirm == null || confirm == false) return;
    await logOutAPI();
  }

  logOutAPI() async {
    String sessionID = StorageService.instance.sessionID!;
    String deviceID = StorageService.instance.deviceID!;
    var response =
        await APIServices().logOut(sessionId: sessionID, deviceId: deviceID);
    // if (response["success"]) {
    timer?.cancel();
    timerAXC?.cancel();
    StorageService.instance
      ..clearTokens()
      ..init();
    hdWallets.clear();
    Get.offAll(() => LoginPage());
    // }
  }

  Future<bool> canCheckBiometrics() async {
    var localAuth = LocalAuthentication();
    return await localAuth.canCheckBiometrics;
  }

  loadUser({bool loadController = true}) async {
    var response = await APIServices().getProfile();
    if (response["success"]) {
      UserModel userModel = UserModel.fromMap(response["data"]);
      if (loadController) {
        final User user = Get.put(User());
        user.updateUser(userModel);
      } else {
        User user = Get.find();
        user.updateUser(userModel);
      }
    }
  }

  Future<List<NetworkConfig>?> fetchNetworkConfigs() async {
    var data = (await APIServices().generalRequest(networkConfigURL));
    if (data == null) return null;
    List<NetworkConfig> networkConfigs =
        (data["data"] as List).map((e) => NetworkConfig.fromMap(e)).toList();
    CustomCacheManager.instance.cacheNetworkConfigs(networkConfigs);
    return networkConfigs;
  }

  Future<Map?> fetchJSCodeInfo() async {
    var data = (await APIServices().generalRequest(jsCodeURL));
    if (data == null) return null;
    var jsCode = data["data"] as Map;
    return jsCode;
  }

  getJSCode() async {
    Map? jsCode = await fetchJSCodeInfo();
    if (jsCode == null) return null;
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/js_code.json');
    String? localVersion;
    String? localJSCode;
    try {
      var data = jsonDecode(await file.readAsString());
      localVersion = data["version"];
      localJSCode = data["jsCode"];
    } catch (e) {
      print("failed to get local js code");
    }
    double currentLocal =
        double.parse(localVersion?.replaceAll(".", "") ?? "0");
    double currentPackage = double.parse(jsVersion.replaceAll(".", ""));
    double newCloud = double.parse(jsCode["version"].replaceAll(".", ""));
    if (newCloud > currentLocal && newCloud > currentPackage) {
      var jsFile =
          await APIServices().generalRequest(jsCode["url"], getBody: true);
      if (jsFile == null) return;
      var data = {"version": jsCode["version"], "jsCode": jsFile};
      await file.writeAsString(jsonEncode(data));
      return jsFile;
    }
    return currentLocal > currentPackage ? localJSCode : null;
  }
}

class APIServices {
  _checkIfSessionExpired(Map val) {
    if (val.toString().contains("Session is expired")) services.logOutAPI();
  }

  generalRequest(String url,
      {Map? body, Map<String, String>? headers, getBody = false}) async {
    try {
      var response = body == null
          ? await http.get(Uri.parse(url))
          : await http.post(Uri.parse(url), headers: headers, body: body);
      print("response code:${response.statusCode}");
      if (response.statusCode == 200) {
        print("success");
        if (getBody) {
          return response.body;
        }
        Map val = jsonDecode(response.body);
        print("result: $val");
        return val;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return null;
      }
    } on SocketException {
      if (url == networkConfigURL) {
        return generalRequest(networkConfigURLAlt);
      }
      if (url == jsCodeURL) {
        return generalRequest(jsCodeURLAlt);
      }
      return CommonWidgets.snackBar("No internet connection");
    } on HttpException {
      return CommonWidgets.snackBar("Couldn't find URL");
    } on FormatException {
      return CommonWidgets.snackBar("Bad response format");
    } catch (e) {
      return CommonWidgets.snackBar("Server response:${e.toString()}");
    }
  }

  noAuthbaseAPI(String url, Map body) async {
    try {
      var response = await http.post(Uri.parse(ipAddress + url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      print("response code:${response.statusCode}");
      if (response.statusCode == 200) {
        print("success");
        Map val = jsonDecode(response.body);
        print("result: $val");
        return val;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices()
              .getAuthToken(sessionId: sessionID, deviceId: deviceID);
          if (result["success"]) {
            String authToken = result["data"]["authToken"];
            StorageService.instance.updateAuthToken(authToken);
            body["authToken"] = authToken;
            return noAuthbaseAPI(url, body);
          }
          return;
        }
        _checkIfSessionExpired(val);
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return CommonWidgets.snackBar("No internet connection");
    } on HttpException {
      return CommonWidgets.snackBar("Couldn't find URL");
    } on FormatException {
      return CommonWidgets.snackBar("Bad response format");
    } catch (e) {
      return CommonWidgets.snackBar("Server response:${e.toString()}");
    }
  }

  getBaseAPI(String url) async {
    try {
      var response = await http.get(
        Uri.parse(ipAddress + url),
        headers: {
          'Authorization': 'Bearer ' + StorageService.instance.authToken!,
          'Content-Type': 'application/json'
        },
      );
      // print("response code:${response.statusCode}");
      if (response.statusCode == 200) {
        // print("success");
        Map val = jsonDecode(response.body);
        // print("result: $val");
        return val;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices()
              .getAuthToken(sessionId: sessionID, deviceId: deviceID);
          if (result["success"]) {
            String authToken = result["data"]["authToken"];
            StorageService.instance.updateAuthToken(authToken);
            return getBaseAPI(url);
          }
          return;
        }
        _checkIfSessionExpired(val);
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return CommonWidgets.snackBar("No internet connection");
    } on HttpException {
      return CommonWidgets.snackBar("Couldn't find URL");
    } on FormatException {
      return CommonWidgets.snackBar("Bad response format");
    } catch (e) {
      return CommonWidgets.snackBar("Server response:${e.toString()}");
    }
  }

  authBaseAPI(String url, Map body) async {
    try {
      var response = await http.post(
        Uri.parse(ipAddress + url),
        headers: {
          'Authorization': 'Bearer ' + StorageService.instance.authToken!,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );
      print("response code:${response.statusCode}");
      if (response.statusCode == 200) {
        print("success");
        Map val = jsonDecode(response.body);
        print("result: $val");
        return val;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices()
              .getAuthToken(sessionId: sessionID, deviceId: deviceID);
          if (result["success"]) {
            String authToken = result["data"]["authToken"];
            StorageService.instance.updateAuthToken(authToken);
            return authBaseAPI(url, body);
          }
          return;
        }
        _checkIfSessionExpired(val);
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return CommonWidgets.snackBar("No internet connection");
    } on HttpException {
      return CommonWidgets.snackBar("Couldn't find URL");
    } on FormatException {
      return CommonWidgets.snackBar("Bad response format");
    } catch (e) {
      return CommonWidgets.snackBar("Server response:${e.toString()}");
    }
  }

  patchbaseAPI(String url, Map body) async {
    try {
      var response = await http.patch(Uri.parse(ipAddress + url),
          headers: {
            'Authorization': 'Bearer ' + StorageService.instance.authToken!,
            'Content-Type': 'application/json'
          },
          body: json.encode(body));
      print("response code:${response.statusCode}");
      if (response.statusCode == 200) {
        print("success");
        Map val = jsonDecode(response.body);
        print("result: $val");
        return val;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices()
              .getAuthToken(sessionId: sessionID, deviceId: deviceID);
          if (result["success"]) {
            String authToken = result["data"]["authToken"];
            StorageService.instance.updateAuthToken(authToken);
            return patchbaseAPI(url, body);
          }
          return;
        }
        _checkIfSessionExpired(val);
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return CommonWidgets.snackBar("No internet connection");
    } on HttpException {
      return CommonWidgets.snackBar("Couldn't find URL");
    } on FormatException {
      return CommonWidgets.snackBar("Bad response format");
    } catch (e) {
      return CommonWidgets.snackBar("Server response:${e.toString()}");
    }
  }

  getProfile() async {
    return getBaseAPI('user');
  }

  signUp({
    required String firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? phoneCode,
    required String password,
  }) async {
    return noAuthbaseAPI(
      "user/sign-up",
      {
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "phoneCode": phoneCode,
        "email": email,
        "password": password,
        "confirmPassword": password
      },
    );
  }

  signIn(
      {String? email,
      String? phoneNumber,
      String? phoneCode,
      required String password,
      required String deviceId}) async {
    return noAuthbaseAPI(
      "user/sign-in",
      {
        "email": email,
        "password": password,
        "deviceId": deviceId,
        "phoneNumber": phoneNumber,
        "phoneCode": phoneCode,
      },
    );
  }

  getAuthToken({required String sessionId, required String deviceId}) async {
    return noAuthbaseAPI(
      "user/get-auth-token",
      {"sessionId": sessionId, "deviceId": deviceId},
    );
  }

  userVerify(
      {String? email,
      String? phoneNumber,
      String? phoneCode,
      required String otp}) async {
    // print("User Verify");
    // print(email);
    // print(phoneNumber);
    // print(phoneCode);
    return noAuthbaseAPI("user/verify", {
      "email": email,
      "phoneNumber": phoneNumber,
      "phoneCode": phoneCode,
      "otp": otp
    });
  }

  sendVerifyOTP({String? email, String? phoneNumber, String? phoneCode}) async {
    return noAuthbaseAPI(
      "user/send-verify-otp",
      {"email": email, "phoneNumber": phoneNumber, "phoneCode": phoneCode},
    );
  }

  forgotPasswordOtp(
      {String? email, String? phoneNumber, String? phoneCode}) async {
    return noAuthbaseAPI(
      "user/send-forget-pass-otp",
      {"email": email, "phoneNumber": phoneNumber, "phoneCode": phoneCode},
    );
  }

  verifyforgotPasswordOtp(
      {String? email,
      required String otp,
      String? phoneNumber,
      String? phoneCode}) {
    return noAuthbaseAPI(
      "user/verify-forget-pass-otp",
      {
        "email": email,
        "otp": otp,
        "phoneNumber": phoneNumber,
        "phoneCode": phoneCode,
      },
    );
  }

  resetPassword(
      {required String newPassword, required String authToken}) async {
    return noAuthbaseAPI(
      "user/reset-password",
      {
        "newPassword": newPassword,
        "confirmPassword": newPassword,
        "authToken": authToken
      },
    );
  }

  logOut({required String sessionId, required String deviceId}) async {
    return noAuthbaseAPI(
      "user/log-out",
      {"sessionId": sessionId, "deviceId": deviceId},
    );
  }

  userNameUpdate({
    required String firstName,
    String? lastName,
  }) async {
    return patchbaseAPI(
      "user",
      {"lastName": lastName, "firstName": firstName},
    );
  }

  userPasswordUpdate({
    required String currentPassword,
    required String newPassword,
  }) async {
    return patchbaseAPI("user/password", {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmPassword": newPassword,
    });
  }

  //CRYPTO APIs
  //-----------
  getBalance(List<String> address, String unit) async {
    return getBaseAPI(
        "address/balance?network=$network&addresses=${address.join(',')}&currency=$unit");
  }

  getTransactions(String address, String unit,
      {int offset = 0, int limit = 10, bool ascending = false}) async {
    // 'address/$address/transactions?network=$network&currency=${coinData.unit}&offset=0&limit=10&sort=asc'
    return getBaseAPI(
      "address/$address/transactions?network=$network&currency=$unit&offset=$offset&limit=$limit&sort=${ascending ? "asc" : "desc"}",
    );
  }

  getPlatformTransactions(String address, String unit,
      {int offset = 0, int limit = 10, bool ascending = false}) async {
    return getBaseAPI(
      "transaction/list/wallet?address=$address&network=$network&currency=$unit&offset=$offset&limit=$limit&sort=${ascending ? "asc" : "desc"}",
    );
  }

  sendTransaction(Map body) {
    return authBaseAPI("transaction/send", body);
  }
}
