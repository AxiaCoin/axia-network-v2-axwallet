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
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/widgets/common.dart';
import 'package:bip39/bip39.dart' as bip39;

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

class Services {
  HDWallet? hdWallet;
  WalletData walletData = Get.put(WalletData());
  Map<String, HDWalletInfo> hdWallets = {};
  Timer? timer;

  // SubstrateSDK substrateSDK = SubstrateSDK();

  initSubstrateSDK() async {
    // if (substrateSDK.api == null) await substrateSDK.init();
  }

  // generateAXIAMnemonic() async {
  //   await _keyring.init([0]);
  //   if (walletSDK.api == null) await walletSDK.init(_keyring);
  //   SubstrateService subService = SubstrateService();
  //   ServiceAccount service = ServiceAccount(subService);
  //   AXIAWalletApi apiRoot = AXIAWalletApi(subService);
  //   // var data = ApiAccount(apiRoot, service).apiRoot.keyring.generateMnemonic();
  //   var data = await walletSDK.api.keyring.generateMnemonic();
  //   print(data);
  // }

  // sendAXtransaction() async {
  //   print("sending transaction");
  //   var data = await walletSDK.api!.basic.signTransaction();
  //   print("wallet app");
  //   print(data);
  // }

  String generateMnemonic() {
    return bip39.generateMnemonic();
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

  Future<void> initWallet(String mnemonic) async {
    void toSeed(IsolateParams isolateParams) {
      var seed = bip39.mnemonicToSeed(isolateParams.mnemonic);
      print("a");
      var b = HexEncoder().convert(seed);
      print("aaa");
      var c = HexDecoder().convert(b);
      print("bbbb");
      isolateParams.sendPort.send(c);
    }

    var receivePort = ReceivePort();
    await Isolate.spawn(toSeed, IsolateParams(mnemonic, receivePort.sendPort));
    var seed = await receivePort.first;
    receivePort.close();
    hdWallet = new HDWallet.fromSeed(seed);
    print("wallet created");
    currencyList.forEach(
      (e) => e.getWallet(),
    );
  }

  Future<void> createMCWallet(String mnemonic, String name) async {
    String seed = await compute(toSeed, mnemonic);
    var seedData = HexDecoder().convert(seed) as Uint8List;
    HDWallet wallet = HDWallet.fromSeed(seedData);
    HDWalletInfo walletInfo = HDWalletInfo(
        seed: seed, name: name, mnemonic: mnemonic, hdWallet: wallet);
    StorageService.instance.storeMnemonicSeed(wallet.pubKey!, walletInfo);
    hdWallets[wallet.pubKey!] = walletInfo;
    StorageService.instance.storeCurrentPubKey(wallet.pubKey!);
    initMCWallet(wallet.pubKey!);
  }

  void initMCWallet(
    String? pubKey,
  ) {
    var mnemonicSeeds = StorageService.instance.readMnemonicSeed();
    if (mnemonicSeeds == null || mnemonicSeeds.isEmpty) return;
    mnemonicSeeds.forEach((key, value) {
      var seedData = HexDecoder().convert(value.seed) as Uint8List;
      value.hdWallet = HDWallet.fromSeed(seedData);
      hdWallets[key] = value;
    });
    if (pubKey != null) {
      walletData.updateWallet(pubKey);
      print("wallet created");
      currencyList.forEach(
        (e) => e.getWallet(),
      );
    }
  }

  updateBalances() async {
    BalanceData balanceCont = Get.find();
    void update() async {
      await Future.wait(currencyList.map((e) async {
        double balance = (await e.getBalance()).toDouble();
        balanceCont.updateBalance(e, balance);
      }));
    }

    if (timer != null) {
      timer?.cancel();
      print("timer cancelled");
    }
    update();
    timer = Timer.periodic(Duration(seconds: 10), (t) {
      update();
    });
  }

  logOut() async {
    bool? confirm = await Get.dialog(
      AlertDialog(
        title: Text("Do you want to logout of your current account?"),
        content: Text(
            "This will remove the wallet(s) you have created and you will need to re-import them with the secret phrase.\n"
            "If you do not have access to the secret phrase(s) then you risk losing all the assets and we cannot help you recover them!"),
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
    String sessionID = StorageService.instance.sessionID!;
    String deviceID = StorageService.instance.deviceID!;
    var response =
        await APIServices().logOut(sessionId: sessionID, deviceId: deviceID);
    if (response["success"]) {
      timer?.cancel();
      StorageService.instance
        ..clearTokens()
        ..init();
      Get.offAll(() => LoginPage());
    }
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
}

class APIServices {
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
