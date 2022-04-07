import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/new_user/create_wallet/disclaimer.dart';
import 'package:wallet/pages/new_user/create_wallet/import_wallet.dart';
import 'package:wallet/widgets/tabpageselector.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({Key? key}) : super(key: key);

  @override
  _OnboardPageState createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  List<OnboardItemData> itemData = [
    OnboardItemData("Private and Secure",
        "Private keys never leave your device", Icons.security),
    OnboardItemData("All assets in one place",
        "View and store your assets seamlessly", Icons.monetization_on),
    OnboardItemData(
        "Trade assets", "Trade your assets anonymously", Icons.perm_identity),
    OnboardItemData("Explore decentralized apps",
        "Earn, explore, utilize, spend, trade, and more", Icons.attractions),
  ];

  Widget item(OnboardItemData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          data.icon,
          size: 64,
        ),
        SizedBox(
          height: 64,
        ),
        Text(
          data.title,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Text(
          data.subtitle,
          style: Theme.of(context).textTheme.caption,
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: itemData.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = itemData.map((e) => item(e)).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        centerTitle: true,
      ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       child: Icon(Icons.light_mode),
      //       onPressed: () => Get.changeTheme(lightTheme),
      //     ),
      //     SizedBox(
      //       height: 8,
      //     ),
      //     FloatingActionButton(
      //       child: Icon(Icons.dark_mode),
      //       onPressed: () => Get.changeTheme(darkTheme),
      //     ),
      //   ],
      // ),
      body: Container(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TabBarView(controller: tabController, children: items),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: MyTabPageSelector(
                controller: tabController,
                color: Colors.grey.withOpacity(0.2),
                indicatorSize: 8,
              ),
            ),
            SizedBox(
              width: Get.width * 0.92,
              child: ElevatedButton(
                onPressed: () => Get.to(() => DisclaimerPage()),
                child: Text("CREATE WALLET"),
                style: MyButtonStyles.onboardStyle,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            SizedBox(
                width: Get.width * 0.92,
                child: TextButton(
                    onPressed: () => Get.to(() => ImportWalletPage()),
                    child: Text("IMPORT WALLET"),
                    style: MyButtonStyles.onboardStyle)),
            SizedBox(
              height: 32,
            )
          ],
        ),
      ),
    );
  }
}
