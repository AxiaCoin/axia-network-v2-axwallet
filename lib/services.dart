import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class APIServices {
  final ipAddress = "http://13.235.53.197:3000/";

  baseapi(String url, Object body) async {
    try {
      print(Uri.parse(ipAddress + url));
      var response = await http.post(Uri.parse(ipAddress + url),
          headers: {
            'Authorization': 'Basic dGVzdDp0ZXN0',
            'Content-Type': 'application/json'
          },
          body: json.encode(body));
      print("response code:${response.statusCode}");
      if (response.statusCode == 200) {
        Map val = jsonDecode(response.body);
        print(val);
        print("result:$val.values");
        print(val.values);
        return val;
      } else {
        Map val = jsonDecode(response.body);
        print("result:$val");
        print(val.values);
        return val;
      }
    } on SocketException {
      return "No internet connection";
    } on HttpException {
      return "Couldn't find post URL";
    } on FormatException {
      return "Bad response format";
    } catch (e) {
      return "Server response:${e.toString()}";
    }
  }

  signUp() async {
    return baseapi(
      "user/sign-up",
      {
        "firstName": "zaid",
        "phoneNumber": "8660885125",
        "phoneCode": "91",
        "password": "123qwe!@#",
        "confirmPassword": "123qwe!@#"
      },
    );
  }

  signIn() async {
    return baseapi(
      "user/sign-in",
      {
        "email": "mohd.zaid@zeeve.io",
        "password": "123qwe!@#",
        "deviceId": "987654321"
      },
    );
  }

  getProfile() async {
    return baseapi(
      "user/get-profile",
      {
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU"
      },
    );
  }

  getAuthToken() async {
    return baseapi(
      "user/get-auth-token",
      {
        "sessionId":
            "cfe25f8f7ff3b5974141914ac69ea76fb2eccc150e00d2d1a20f872cec4eb94e",
        "deviceId": "987654321"
      },
    );
  }

  userMobileVerify() async {
    return baseapi(
      "user/verify",
      {"phoneNumber": "7906706094", "phoneCode": "91", "otp": "855015"},
    );
  }

  userNameUpdate() async {
    return baseapi(
      "user/update",
      {
        "lastName": "zaid",
        "firstName": "mohd1",
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU"
      },
    );
  }

  userPasswordUpdate() async {
    return baseapi(
      "user/update-password",
      {
        "currentPassword": "123qwe!@#",
        "newPassword": "!@#qwe123",
        "confirmPassword": "!@#qwe123",
        "authToken":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU"
      },
    );
  }

  forgotPasswordOtp() async {
    return baseapi(
      "user/send-forget-pass-otp",
      {"email": "mohd.zaid@zeeve.io"},
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

  sendVerifyOTP() async {
    return baseapi(
      "user/send-verify-otp",
      {"phoneNumber": "7906706095", "phoneCode": "91"},
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

  logOut() async {
    return baseapi(
      "user/log-out",
      {
        "sessionId":
            "3cb54c6edeb0221e8f414edaf30992f7290a56ac288d57519d551b51c78a9e36",
        "deviceId": "1234567891"
      },
    );
  }
}
