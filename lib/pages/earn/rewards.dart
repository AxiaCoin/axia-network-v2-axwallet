import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Rewards"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );
    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: Get.width * 0.25,
                  width: Get.width * 0.25,
                  child: Image.asset(
                    "assets/icons/empty_txn.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                HomeWidgets.emptyListText(
                    "You do not have any pending rewards."),
                // SizedBox(height: 8,),
                // TextButton(
                //     onPressed: () => Get.to(() => BuyPage(
                //           currency: currency,
                //           minimum: 50,
                //         )),
                //     child: Text("Buy ${currency.coinData.name}"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
