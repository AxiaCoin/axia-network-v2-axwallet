import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/wallet/collectibles.dart';
import 'package:wallet/pages/search.dart';
import 'package:wallet/pages/wallet/finance.dart';
import 'package:wallet/pages/wallet/notifications.dart';
import 'package:wallet/pages/wallet/tokens.dart';
import 'package:wallet/widgets/home_widgets.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int slidingIndex = 0;
  PageController pageController = PageController(keepPage: false);
  List<Widget> pages = [TokensPage(), FinancePage(), CollectiblesPage()];

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          actions: [
            slidingIndex == 0
                ? IconButton(
                    icon: Icon(Icons.tune_outlined),
                    onPressed: () {
                      pushNewScreen(context, screen: SearchPage(searchMode: SearchMode.customize,)).then((value) {
                        tokensKey.currentState?.setState(() {});
                      });
                    },
                  )
                : Container()
          ],
          leading: slidingIndex == 0
              ? IconButton(
                  icon: Icon(Icons.notifications_none),
                  onPressed: () => Get.to(() => NotificationsPage()),
                )
              : Container(),
          elevation: 0,
          title: CupertinoSlidingSegmentedControl<int>(
            children: {
              0: HomeWidgets.segmentedText("Tokens"),
              1: HomeWidgets.segmentedText("Finance"),
              2: HomeWidgets.segmentedText("Collectibles"),
            },
            groupValue: slidingIndex,
            onValueChanged: (int? val) {
              setState(() {
                slidingIndex = val!;
                pageController.jumpToPage(val);
              });
            },
            backgroundColor: Colors.black.withOpacity(0.2),
            thumbColor: appColor,
          ),
          //brightness: Brightness.dark,
        );

    return Scaffold(
      appBar: appBar(),
      body: PageView(
        controller: pageController,
        children: pages,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
