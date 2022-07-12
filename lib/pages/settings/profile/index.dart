// import 'package:app/service/index.dart';
// import 'package:app/utils/i18n/index.dart';
// import 'package:axiawallet_sdk/utils/i18n.dart';
// import 'package:biometric_storage/biometric_storage.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/settings/profile/change_name.dart';
import 'package:wallet/pages/settings/profile/change_password.dart';
// import 'package:axiawallet_ui/components/passwordInputDialog.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/pages/settings/profile/settings.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';

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
            Column(
              children: [
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
                          value:
                              "${userModel.firstName} ${userModel.lastName ?? ""}",
                          onPressed: () {
                            Get.to(() => ChangeUserProfile(
                                      firstName: firstName,
                                      lastName: lastName,
                                    ))!
                                .then((value) => setState(() {}));
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
                        SizedBox(
                          height: 16,
                        ),

                        ListTile(
                          title: Text("Settings"),
                          trailing: Icon(Icons.navigate_next),
                          leading: HomeWidgets.settingsTileIcon(
                              icon: Icon(Icons.settings), color: appColor),
                          onTap: () {
                            pushNewScreen(context, screen: NewSettingsPage());
                          },
                        ),

                        // SizedBox(
                        //   width: Get.width,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       Get.to(
                        //           () => ChangePassword(resetPassword: false));
                        //     },
                        //     child: Text("Change Password"),
                        //     style: MyButtonStyles.onboardStyle,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),
                        // SizedBox(
                        //   width: Get.width,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       services.logOut();
                        //     },
                        //     child: Text("Logout"),
                        //     style: MyButtonStyles.onboardStyle,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  width: Get.width,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton(
                    onPressed: () {
                      services.logOut();
                    },
                    child: Text("Logout"),
                    style: MyButtonStyles.onboardStyle,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
