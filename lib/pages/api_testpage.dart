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
                    button("Sign up", APIServices().signUp()),
                    button("Sign in", APIServices().signIn()),
                    button("Get Profile", APIServices().getProfile()),
                    button("Get Auth", APIServices().getAuthToken()),
                    button("Verify", APIServices().userMobileVerify()),
                    button("Name update", APIServices().userNameUpdate()),
                    button(
                        "Password update", APIServices().userPasswordUpdate()),
                    button("Password OTP", APIServices().forgotPasswordOtp()),
                    button("Reset Password", APIServices().resetPassword()),
                    button("Verify OTP", APIServices().sendVerifyOTP()),
                    button(
                        "Create Address", APIServices().cryptoAddressCreate()),
                    button("Fetch From Mnemonic",
                        APIServices().fetchFromMnemonic()),
                    button("Export Data", APIServices().exportData()),
                    button("Import Address", APIServices().importAddress()),
                    button("List Address", APIServices().listAddress()),
                    button("Get Balance", APIServices().getBalance()),
                    button("Logout", APIServices().logOut()),
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
