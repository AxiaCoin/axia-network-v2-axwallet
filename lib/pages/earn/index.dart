import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/earn/delegate.dart';
import 'package:wallet/pages/earn/rewards.dart';
import 'package:wallet/pages/network_switch.dart';
import 'package:wallet/pages/transfers/cross_chain.dart';
import 'package:wallet/pages/transfers/same_chain.dart';
import 'package:wallet/widgets/address_card.dart';
import 'package:wallet/widgets/balance_card.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/plugin_widgets.dart';
import 'package:axwallet_sdk/axwallet_sdk.dart';

class EarnPage extends StatefulWidget {
  const EarnPage({Key? key}) : super(key: key);

  @override
  State<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends State<EarnPage> {
  AXCWalletData axcWalletData = Get.find();

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Earn & Transfer"),
          centerTitle: true,
        );

    Widget networkStatus() {
      NetworkConfig? network = StorageService.instance.connectedNetwork;
      return Obx(
        () => Center(
          child: GestureDetector(
            onTap: () {
              Get.to(() => NetworkSwitchPage());
            },
            child: Container(
              padding: EdgeInsets.all(4),
              child: Text.rich(
                TextSpan(
                  text: axcWalletData.wallet.value.swap != null
                      ? "Connected to "
                      : "Connecting to a node",
                  children: [
                    TextSpan(
                      text: axcWalletData.wallet.value.swap != null
                          ? StorageService.instance.connectedNetwork?.name
                          : null,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    TextSpan(
                      text: (StorageService.instance.connectedNetwork == null ||
                              axcWalletData.wallet.value.swap == null)
                          ? null
                          : StorageService.instance.connectedNetwork!.isTestNet
                              ? " (Testnet)"
                              : " (Mainnet)",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    WidgetSpan(
                      child: Icon(Icons.keyboard_arrow_right),
                      alignment: PlaceholderAlignment.middle,
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

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
              networkStatus(),
              BalanceCard(),
              SizedBox(height: 8),
              AddressCard(),
              SizedBox(height: 8),
              // PluginWidgets.indexTitle(
              //     "You can earn more AXC by staking your existing tokens."),
              // PluginWidgets.earntiles(
              //     "Validate",
              //     "You have an Avalanche node that you want to stake with.",
              //     Icons.people,
              //     () => null),
              // SizedBox(height: 8),
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
                  "Nominate",
                  "You do not own a node, but you want to stake using another node.",
                  Icons.shield,
                  () => pushNewScreen(context, screen: DelegatePage())),
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
