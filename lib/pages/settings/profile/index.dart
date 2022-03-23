import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/settings/profile/change_name.dart';
import 'package:wallet/pages/settings/profile/change_password.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String user = "";
  String userName = "user";
  String? firstName;
  String? lastName;
  bool isLoading = true;

  logOut() async {
    String sessionID = StorageService.instance.sessionID!;
    String deviceID = StorageService.instance.deviceID!;
    var response =
        await APIServices().logOut(sessionId: sessionID, deviceId: deviceID);
    if (response["success"]) {
      StorageService.instance.clearTokens();
      Get.offAll(() => LoginPage());
    }
  }

  getProfile() async {
    var response = await APIServices()
        .getProfile(authToken: StorageService.instance.authToken!);
    if (response["success"]) {
      user = response.toString();
      firstName = response["data"]["firstName"];
      lastName = response["data"]["lastName"];
      userName = "$firstName ${lastName ?? ""}";
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello $userName",
                  style: context.textTheme.headline4,
                ),
                SizedBox(
                  height: 32,
                ),
                Text(
                  "Welcome to your Wallet",
                  style: context.textTheme.caption!.copyWith(fontSize: 24),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(user),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => ChangeUserProfile(
                                firstName: firstName,
                                lastName: lastName,
                              ))!
                          .then((value) {
                        if (value != null && value) {
                          getProfile();
                        }
                      });
                    },
                    child: Text("Change Name"),
                    style: MyButtonStyles.onboardStyle,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => ChangePassword(resetPassword: false));
                    },
                    child: Text("Change Password"),
                    style: MyButtonStyles.onboardStyle,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      logOut();
                    },
                    child: Text("Logout"),
                    style: MyButtonStyles.onboardStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
