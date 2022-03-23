import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/services.dart';

class APITestpage extends StatefulWidget {
  const APITestpage({Key? key}) : super(key: key);

  @override
  State<APITestpage> createState() => _APITestpageState();
}

class _APITestpageState extends State<APITestpage> {
  final TextEditingController responseController = TextEditingController();
  // final TextEditingController jsonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget button(String? text, api) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 0.4 * Get.width,
            child: ElevatedButton(
              onPressed: () async {
                var result = await api;
                setState(() {
                  responseController.text = result.toString();
                });
              },
              child: Text("$text"),
              style: MyButtonStyles.onboardStyle,
            ),
          ),
        );

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text("API Testing"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  children: [
                    button(
                        "Sign up",
                        APIServices().signUp(
                          firstName: "zaid",
                          phoneNumber: "8660885125",
                          phoneCode: "91",
                          password: "123qwe!@#",
                        )),
                    button(
                        "Sign in",
                        APIServices().signIn(
                          email: "mohd.zaid@zeeve.io",
                          password: "123qwe!@#",
                          deviceId: "987654321",
                        )),
                    button(
                        "Get Profile",
                        APIServices().getProfile(
                          authToken:
                              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
                        )),
                    button(
                        "Get Auth",
                        APIServices().getAuthToken(
                          sessionId:
                              "cfe25f8f7ff3b5974141914ac69ea76fb2eccc150e00d2d1a20f872cec4eb94e",
                          deviceId: "987654321",
                        )),
                    button(
                        "Verify",
                        APIServices().userVerify(
                          phoneNumber: "7906706094",
                          phoneCode: "91",
                          otp: "855015",
                        )),
                    button(
                        "Name update",
                        APIServices().userNameUpdate(
                          lastName: "zaid",
                          firstName: "mohd1",
                          authToken:
                              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
                        )),
                    button(
                        "Password update",
                        APIServices().userPasswordUpdate(
                          currentPassword: "123qwe!@#",
                          newPassword: "!@#qwe123",
                          authToken:
                              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InVzZXJJZCI6ImJjZDk2NjdlLTgyMzctNDAzMC1hNTI5LWY4OTZiZDZjOWZmMiJ9LCJzZXNzaW9uSUQiOiJjZmUyNWY4ZjdmZjNiNTk3NDE0MTkxNGFjNjllYTc2ZmIyZWNjYzE1MGUwMGQyZDFhMjBmODcyY2VjNGViOTRlIiwiaWF0IjoxNjQ3ODQ4MzU2LCJleHAiOjE2NDc4NTE5NTYsImF1ZCI6InpicC11bmlmaWVkLWdhdGV3YXktc2VydmljZSIsInN1YiI6IkFjY2VzcyBNYWluIn0.W-EwMS2WchCtPYr59AusksBy50k8UURSzoGllbKz3MU",
                        )),
                    button(
                        "Password OTP",
                        APIServices().forgotPasswordOtp(
                          email: "mohd.zaid@zeeve.io",
                        )),
                    button("Reset Password", APIServices().resetPassword()),
                    button(
                        "Verify OTP",
                        APIServices().sendVerifyOTP(
                          phoneNumber: "7906706095",
                          phoneCode: "91",
                        )),
                    button(
                        "Create Address", APIServices().cryptoAddressCreate()),
                    button("Fetch From Mnemonic",
                        APIServices().fetchFromMnemonic()),
                    button("Export Data", APIServices().exportData()),
                    button("Import Address", APIServices().importAddress()),
                    button("List Address", APIServices().listAddress()),
                    button("Get Balance", APIServices().getBalance()),
                    button(
                        "Logout",
                        APIServices().logOut(
                          sessionId:
                              "3cb54c6edeb0221e8f414edaf30992f7290a56ac288d57519d551b51c78a9e36",
                          deviceId: "1234567891",
                        )),
                  ],
                ),
                Divider(thickness: 5),
                // Container(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: TextFormField(
                //       decoration: InputDecoration(labelText: "JSON data here"),
                //       controller: jsonController,
                //       maxLines: 10,
                //       onEditingComplete: () => setState(() {
                //         print(jsonController.text);
                //       }),
                //     ),
                //   ),
                // ),
                // Divider(thickness: 5),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration:
                          InputDecoration(hintText: "API Response here"),
                      controller: responseController,
                      maxLines: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // jsonController.dispose();
    responseController.dispose();
    super.dispose();
  }
}
