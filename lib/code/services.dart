import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
// import 'package:axiawallet_sdk/api/api.dart';
// import 'package:axiawallet_sdk/api/apiAccount.dart';
// import 'package:axiawallet_sdk/api/apiKeyring.dart';
// import 'package:axiawallet_sdk/axiawallet_sdk.dart';
// import 'package:axiawallet_sdk/service/account.dart';
// import 'package:axiawallet_sdk/service/index.dart';
// import 'package:axiawallet_sdk/storage/keyring.dart';
import 'package:coinslib/coinslib.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';
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

Services services = Services();

class Services {
  HDWallet? hdWallet;

  // WalletSDK walletSDK = WalletSDK();
  // var _keyring = Keyring();
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

  String generateMnemonic() {
    String mnemonic = bip39.generateMnemonic();
    print(mnemonic);
    return mnemonic;
  }

  Future<void> initWallet(String mnemonic) async {
    void toSeed(IsolateParams isolateParams) {
      var seed = bip39.mnemonicToSeed(isolateParams.mnemonic);
      isolateParams.sendPort.send(seed);
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
            body["authToken"] = authToken;
            return noAuthbaseAPI(url, body);
          }
          return;
        }
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return "No internet connection";
    } on HttpException {
      return "Couldn't find URL";
    } on FormatException {
      return "Bad response format";
    } catch (e) {
      return "Server response:${e.toString()}";
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
            body["authToken"] = authToken;
            return patchbaseAPI(url, body);
          }
          return;
        }
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return "No internet connection";
    } on HttpException {
      return "Couldn't find URL";
    } on FormatException {
      return "Bad response format";
    } catch (e) {
      return "Server response:${e.toString()}";
    }
  }

  getProfile() async {
    try {
      var response = await http.get(
        Uri.parse(ipAddress + 'user'),
        headers: {
          'Authorization': 'Bearer ' + StorageService.instance.authToken!,
          'Content-Type': 'application/json'
        },
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
            return getProfile();
          }
          return;
        }
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return "No internet connection";
    } on HttpException {
      return "Couldn't find URL";
    } on FormatException {
      return "Bad response format";
    } catch (e) {
      return "Server response:${e.toString()}";
    }
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
      {String? phoneNumber, String? phoneCode, required String otp}) async {
    return noAuthbaseAPI("user/verify",
        {"phoneNumber": phoneNumber, "phoneCode": phoneCode, "otp": otp});
  }

  sendVerifyOTP({String? phoneNumber, String? phoneCode}) async {
    return noAuthbaseAPI(
      "user/send-verify-otp",
      {"phoneNumber": phoneNumber, "phoneCode": phoneCode},
    );
  }

  forgotPasswordOtp({String? email}) async {
    return noAuthbaseAPI(
      "user/send-forget-pass-otp",
      {"email": email},
    );
  }

  verifyforgotPasswordOtp({String? email, required String otp}) {
    return noAuthbaseAPI(
      "user/verify-forget-pass-otp",
      {"email": email, "otp": otp},
    );
  }

  resetPassword(
      {required String email,
      required String currentPassword,
      required String newPassword,
      required String authToken}) async {
    return noAuthbaseAPI(
      "user/update-password",
      {
        "email": email,
        "currentPassword": currentPassword,
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
}
