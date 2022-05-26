import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/pages/settings/profile/index.dart';
import 'package:wallet/pages/wallet/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  PageController pageController = PageController();
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  final TokenData list = Get.find();
  final BalanceData balanceCont = Get.find();
  SettingsState settingsState = Get.find();
  WalletData walletData = Get.find();

  int pageIndex = 0;

  List<Widget> pages = [WalletPage(), ProfilePage()];
  List<PersistentBottomNavBarItem> bottomNavBarItems = [
    PersistentBottomNavBarItem(
        icon: Icon(Icons.shield),
        title: "Wallet",
        activeColorPrimary: appColor,
        inactiveColorPrimary: Colors.grey),
    // PersistentBottomNavBarItem(
    //     icon: Icon(Icons.apps),
    //     title: "DApps",
    //     activeColorPrimary: appColor,
    //     inactiveColorPrimary: Colors.grey),
    // PersistentBottomNavBarItem(
    //     icon: Icon(Icons.swap_horiz),
    //     title: "DEX",
    //     activeColorPrimary: appColor,
    //     inactiveColorPrimary: Colors.grey),
    PersistentBottomNavBarItem(
        icon: Icon(Icons.account_circle),
        title: "Profile",
        activeColorPrimary: appColor,
        inactiveColorPrimary: Colors.grey),
  ];

  // List<PersistentBottomNavBarItem> bottomNavBarItems = [
  //   PersistentBottomNavBarItem(icon: Icon(Icons.shield), tit),
  // ]

  @override
  void initState() {
    super.initState();
    Services().loadUser();
    services.updateBalances();
  }

  @override
  Widget build(BuildContext context) {
    Color darkNavBar = darkTheme.bottomNavigationBarTheme.backgroundColor!;
    Color lightNavBar = Color(0xFFF4F5F6);

    return Obx(
      () => PersistentTabView(
        context,
        controller: _controller,
        screens: pages,
        items: bottomNavBarItems,
        confineInSafeArea: true,
        backgroundColor: settingsState.darkMode.value
            ? darkNavBar
            : lightNavBar, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar:
              settingsState.darkMode.value ? darkNavBar : lightNavBar,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style8, // Choose the nav bar style with this property.
      ),
    );
    // return Scaffold(
    //   bottomNavigationBar: CupertinoTabBar(
    //     currentIndex: pageIndex,
    //     items: bottomNavBarItems,
    //     onTap: (i) {
    //       setState(() {
    //         pageIndex = i;
    //         pageController.jumpToPage(i);
    //       });
    //     },
    //   ),
    //   body: PageView(
    //     controller: pageController,
    //     physics: NeverScrollableScrollPhysics(),
    //     children: pages,
    //   ),
    // );
  }
}
