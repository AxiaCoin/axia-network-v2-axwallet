import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/pages/earn/add_validator.dart';
import 'package:wallet/pages/earn/nominate.dart';
import 'package:wallet/pages/earn/rewards.dart';
import 'package:wallet/pages/transfers/cross_chain.dart';
import 'package:wallet/pages/transfers/same_chain.dart';
import 'package:wallet/pages/wallet/new_wallet.dart';
import 'package:wallet/widgets/plugin_widgets.dart';

class EarnPage extends StatefulWidget {
  const EarnPage({Key? key}) : super(key: key);

  @override
  State<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends State<EarnPage> {
  AXCWalletData axcWalletData = Get.find();
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Earn & Transfer"),
          centerTitle: true,
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: appBar(),
        body: Container(
          // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: ListView(
            children: [
              // NewWalletDashboard(),
              // PluginWidgets.indexTitle(
              //     "You can earn more AXC by staking your existing tokens."),
              SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Same Chain Transfer",
                  "Send coins to other wallets in the Swap-Chain or AX-Chain",
                  Icons.double_arrow,
                  () => pushNewScreen(context, screen: SameChainTransfer())),
              SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Cross Chain Transfer",
                  "Exchange coins from one chain to another within your own wallet",
                  Icons.swap_horiz,
                  () => pushNewScreen(context, screen: CrossChainPage())),
              SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Validate",
                  "You have an AXIA node that you want to stake with.",
                  Icons.people,
                  () => pushNewScreen(context, screen: AddValidatorPage())),
              SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Nominate",
                  "You do not own a node, but you want to stake using another node.",
                  Icons.shield,
                  () => pushNewScreen(context, screen: NominatePage())),
              SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Estimated Rewards",
                  "View staking rewards you will receive.",
                  Icons.currency_exchange,
                  () => pushNewScreen(context, screen: RewardsPage())),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
