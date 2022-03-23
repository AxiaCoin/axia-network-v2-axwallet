import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wallet/code/storage.dart';
import 'package:wallet/widgets/common.dart';

class APIServices {
  final ipAddress = "http://13.235.53.197:3000/";

  baseapi(String url, Map body) async {
    try {
      var response = await http.post(Uri.parse(ipAddress + url),
          headers: {
            'Authorization': 'Basic dGVzdDp0ZXN0',
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
            return baseapi(url, body);
          }
          return;
        }
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      print("No internet connection");
    } on HttpException {
      print("Couldn't find post URL");
    } on FormatException {
      print("Bad response format");
    } catch (e) {
      print("Server response:${e.toString()}");
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
    return baseapi(
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
    return baseapi(
      "user/sign-in",
      {
        "email": email,
        "phoneNumber": phoneNumber,
        "phoneCode": phoneCode,
        "password": password,
        "deviceId": deviceId
      },
    );
  }

  getProfile({required String authToken}) async {
    return baseapi(
      "user/get-profile",
      {"authToken": authToken},
    );
  }

  getAuthToken({required String sessionId, required String deviceId}) async {
    return baseapi(
      "user/get-auth-token",
      {"sessionId": sessionId, "deviceId": deviceId},
    );
  }

  userVerify(
      {String? email,
      String? phoneNumber,
      String? phoneCode,
      required String otp}) async {
    return baseapi(
      "user/verify",
      {
        "email": email,
        "phoneNumber": phoneNumber,
        "phoneCode": phoneCode,
        "otp": otp
      },
    );
  }

  userNameUpdate(
      {required String firstName,
      String? lastName,
      required String authToken}) async {
    return baseapi(
      "user/update",
      {"lastName": lastName, "firstName": firstName, "authToken": authToken},
    );
  }

  userPasswordUpdate(
      {required String currentPassword,
      required String newPassword,
      required String authToken}) async {
    return baseapi(
      "user/update-password",
      {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": newPassword,
        "authToken": authToken
      },
    );
  }

  forgotPasswordOtp(
      {String? email, String? phoneNumber, String? phoneCode}) async {
    return baseapi(
      "user/send-forget-pass-otp",
      {"email": email, "phoneNumber": phoneNumber, "phoneCode": phoneCode},
    );
  }

  resetPassword() async {
    return baseapi(
      "user/reset-password",
      {
        "email": "mohd.zaid@zeeve.io",
        "newPassword": "123qwe!@#",
        "confirmPassword": "123qwe!@#",
        "otp": "032249"
      },
    );
  }

  sendVerifyOTP({String? email, String? phoneNumber, String? phoneCode}) async {
    return baseapi(
      "user/send-verify-otp",
      {"email": email, "phoneNumber": phoneNumber, "phoneCode": phoneCode},
    );
  }

  cryptoAddressCreate() async {
    return baseapi(
      "crypto/address/create",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
        "currencyType": ["ETH", "BTC"]
      },
    );
  }

  fetchFromMnemonic() async {
    return baseapi(
      "crypto/address/fetch-from-mnemonic",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
        "mnemonic":
            "stuff frozen govern alpha empty town angry horror crucial north margin goose",
        "currencyType": ["BTC", "ETH", "AXC"]
      },
    );
  }

  exportData() async {
    return baseapi(
      "crypto/export-data",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU"
      },
    );
  }

  importAddress() async {
    return baseapi(
      "crypto/address/import",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
        "currencyType": "BTC",
        "address": "mx7JUSgyjx476CpcTTTexdJLL9p6okDee3"
      },
    );
  }

  listAddress() async {
    return baseapi(
      "crypto/address/list",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
        "currencyType": ["BTC"],
        "limit": 10,
        "offset": 0
      },
    );
  }

  getBalance() async {
    return baseapi(
      "crypto/address/get-balance",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
        "currencyType": ["ETH", "BTC"]
      },
    );
  }

  logOut({required String sessionId, required String deviceId}) async {
    return baseapi(
      "user/log-out",
      {"sessionId": sessionId, "deviceId": deviceId},
    );
  }
}
