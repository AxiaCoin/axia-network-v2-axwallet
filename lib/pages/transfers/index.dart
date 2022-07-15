import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/pages/earn/nominate.dart';
import 'package:wallet/pages/earn/rewards.dart';
import 'package:wallet/pages/transfers/cross_chain.dart';
import 'package:wallet/pages/transfers/same_chain.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/plugin_widgets.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Transfer"),
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
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              PluginWidgets.indexTitle(
                  "Transfer your coins between chains and other wallets"),
              // PluginWidgets.earntiles(
              //     "Validate",
              //     "You have an Axia node that you want to stake with.",
              //     Icons.people,
              //     () => null),
              // SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Same Chain",
                  "Send coins to other wallets in the Swap-Chain or AX-Chain",
                  Icons.double_arrow,
                  () => pushNewScreen(context, screen: SameChainTransfer())),
              SizedBox(height: 8),
              PluginWidgets.earntiles(
                  "Cross Chain",
                  "Exchange coins from one chain to another within your own wallet",
                  Icons.swap_horiz,
                  () => pushNewScreen(context, screen: CrossChainPage())),
            ],
          ),
        ),
      ),
    );
  }
}
