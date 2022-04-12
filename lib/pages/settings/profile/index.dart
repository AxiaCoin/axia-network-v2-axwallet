import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/settings/profile/change_name.dart';
import 'package:wallet/pages/settings/profile/change_password.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late UserModel userModel;
  late String firstName = userModel.firstName;
  late String lastName = userModel.lastName ?? "";
  late String userName = "$firstName $lastName";
  bool isLoading = true;
  var localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;

  initAuthentication() async {
    canCheckBiometrics = await Services().canCheckBiometrics();
    setState(() {});
  }

  void toggleBiometrics(bool value) async {
    bool success = await localAuth.authenticate(
        localizedReason: "Please authenticate to toggle", biometricOnly: true);
    if (success) StorageService.instance.updateBiometricPreference(value);
    setState(() {});
  }

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

  // getProfile() async {
  //   var response = await APIServices().getProfile();
  //   if (response["success"]) {
  //     userModel = UserModel.fromMap(response["data"]);
  //     // user = response.toString();
  //     firstName = userModel!.firstName;
  //     lastName = userModel!.lastName;
  //     userName = "$firstName ${lastName ?? ""}";
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // getProfile();
    initAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    User user = Get.find();
    userModel = user.userModel.value;
    firstName = userModel.firstName;
    lastName = userModel.lastName ?? "";
    userName = "$firstName $lastName";
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Details"),
        centerTitle: true,
        elevation: 0,
        // leading: CommonWidgets.backButton(context),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: Get.height * 0.15,
              color: appColor[600],
            ),
            CommonWidgets.elevatedContainer(
              padding: 16,
              margin: 16,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Hello $userName",
                    //   style: context.textTheme.headline4,
                    // ),
                    // SizedBox(
                    //   height: 32,
                    // ),
                    CommonWidgets.profileItem(
                      context,
                      key: "Name: ",
                      value: "${userModel.firstName} ${userModel.lastName}",
                      onPressed: () {
                        Get.to(() => ChangeUserProfile(
                                  firstName: firstName,
                                  lastName: lastName,
                                ))!
                            .then((value) {
                          if (value != null && value) {
                            Services()
                                .loadUser(loadController: false)
                                .then((value) => setState(() {}));
                          }
                        });
                      },
                    ),
                    userModel.email == null
                        ? Container()
                        : CommonWidgets.profileItem(
                            context,
                            key: "Email: ",
                            value: userModel.email!,
                          ),
                    userModel.phoneNumber == null
                        ? Container()
                        : CommonWidgets.profileItem(
                            context,
                            key: "Phone number: ",
                            value:
                                "+${userModel.phoneCode}${userModel.phoneNumber}",
                          ),
                    // SizedBox(
                    //   height: 8,
                    // ),
                    // Text(userModel.toMap().toString()),
                    SizedBox(
                      height: 16,
                    ),
                    // SizedBox(
                    //   width: Get.width,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       Get.to(() => ChangeUserProfile(
                    //                 firstName: firstName,
                    //                 lastName: lastName,
                    //               ))!
                    //           .then((value) {
                    //         if (value != null && value) {
                    //           Services()
                    //               .loadUser(loadController: false)
                    //               .then((value) => setState(() {}));
                    //         }
                    //       });
                    //     },
                    //     child: Text("Change Name"),
                    //     style: MyButtonStyles.onboardStyle,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 16,
                    // ),

                    canCheckBiometrics
                        ? SizedBox(
                            width: Get.width * 0.9,
                            child: SwitchListTile.adaptive(
                              value: StorageService.instance.useBiometric!,
                              onChanged: toggleBiometrics,
                              title: Text("Enable FaceID/Fingerprint"),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      width: Get.width,
                      child: TextButton(
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
                      child: TextButton(
                        onPressed: () {
                          logOut();
                        },
                        child: Text("Logout"),
                        style: MyButtonStyles.onboardStyle,
                      ),
                    ),
                    // SizedBox(
                    //   height: 16,
                    // ),
                    // SizedBox(
                    //   width: Get.width,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       services.generateAXIAMnemonic();
                    //     },
                    //     child: Text("Testing"),
                    //     style: MyButtonStyles.onboardStyle,
                    //   ),
                    // ),
                    // kDebugMode
                    //     ? SizedBox(
                    //         height: 16,
                    //       )
                    //     : SizedBox.shrink(),
                    // kDebugMode
                    //     ? SizedBox(
                    //         width: Get.width,
                    //         child: TextButton(
                    //           onPressed: () {
                    //             // services.generateAXIAMnemonic();
                    //             // currencyList.forEach(
                    //             //   (e) => e.generateWalletAddress(),
                    //             // );
                    //             // currencyList.last.getBalance();
                    //           },
                    //           child: Text("Test"),
                    //           style: MyButtonStyles.onboardStyle,
                    //         ),
                    //       )
                    //     : SizedBox.shrink(),
                    // CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
