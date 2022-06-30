import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/pages/earn/delegate.dart';
import 'package:wallet/pages/earn/rewards.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/plugin_widgets.dart';

class EarnPage extends StatefulWidget {
  const EarnPage({Key? key}) : super(key: key);

  @override
  State<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends State<EarnPage> {
  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Earn"),
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
                  "You can earn more AXC by staking your existing tokens."),
              // PluginWidgets.earntiles(
              //     "Validate",
              //     "You have an Avalanche node that you want to stake with.",
              //     Icons.people,
              //     () => null),
              // SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
