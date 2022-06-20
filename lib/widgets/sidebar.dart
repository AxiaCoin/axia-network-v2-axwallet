import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/new_user/login.dart';
import 'package:wallet/pages/search.dart';
import 'package:wallet/pages/webview.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/network_switcher.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BalanceData balanceData = Get.find();
    final WalletData walletData = Get.find();
    User user = Get.find();
    UserModel userModel = user.userModel.value;
    String firstName = userModel.firstName;
    String lastName = userModel.lastName ?? "";
    String userName = "$firstName $lastName";
    double height = Get.height;
    double width = Get.width;
    List<String> cat = [
      // "Browser",
      // "Wallet",
      // "Activity",
      // "DApps",
      // "Share my Address",
      // "View on AXIA Network",
      // "Settings",
      "Support",
      "Logout"
    ];

    Widget dash() => Container(
          height: height * 0.28,
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "My AXIA Wallet",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Spacer(),
                  Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Obx(
                    () => Text(
                      "\$${balanceData.totalBalance.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              // Positioned(
              //   right: 0,
              //   bottom: 0,
              //   child: NetworkSwitcher(onChanged: (inTestNet) {}),
              // )
            ],
          ),
        );

    Widget buttons() => Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                child: HomeWidgets.roundedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    pushNewScreen(
                      context,
                      screen: SearchPage(searchMode: SearchMode.send),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/assets_send.svg",
                    color: Colors.white,
                  ),
                  label: "Send",
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                child: HomeWidgets.roundedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    pushNewScreen(
                      context,
                      screen: SearchPage(searchMode: SearchMode.receive),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/qr.svg",
                    color: Colors.white,
                  ),
                  label: "Receive",
                  color: tickerGreen,
                ),
              ),
            ),
          ],
        );

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [appColor[600]!, Colors.white],
                stops: [0.33, 0])),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              dash(),
              buttons(),
              Divider(),
              Spacer(),
              // ListTile(
              //   onTap: () => Get.to(() => WebViewPage(url: "https://www.google.com/")),
              //   title: Text(
              //     cat[0],
              //     style: TextStyle(color: appColor[800], fontSize: 16),
              //   ),
              // ),
              Divider(),
              ListTile(
                onTap: support,
                title: Text(
                  cat[0],
                  style: TextStyle(color: appColor[800], fontSize: 16),
                ),
              ),
              Divider(),
              ListTile(
                onTap: () => services.logOut(),
                title: Text(
                  cat[1],
                  style: TextStyle(color: appColor[800], fontSize: 16),
                ),
              ),
              SizedBox(
                height: kBottomNavigationBarHeight * 0.25,
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: ListView.separated(
              //     separatorBuilder: ((context, index) {
              //       return Divider();
              //     }),
              //     shrinkWrap: true,
              //     primary: false,
              //     itemCount: cat.length,
              //     itemBuilder: ((context, index) {
              //       return Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Text(
              //           cat[index],
              //           style: TextStyle(color: appColor[800], fontSize: 16),
              //         ),
              //       );
              //     }),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  support() async {
    String url = "https://axia.global/";
    CommonWidgets.launch(url);
  }
}
