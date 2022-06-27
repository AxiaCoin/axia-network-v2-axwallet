import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/pages/earn/delegate.dart';
import 'package:wallet/pages/earn/rewards.dart';
import 'package:wallet/pages/earn/confirm_delegate.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

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

    Widget earntiles(
            String title, String subtitle, IconData icon, Function() onTap) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Color(0x2424240F),
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                  blurRadius: 16,
                ),
              ],
            ),
            child: Center(
              child: ListTile(
                leading: Icon(icon, size: 35),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
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
              OnboardWidgets.neverShare(
                  text:
                      "You can earn more AXC by staking your existing tokens."),
              earntiles(
                  "Validate",
                  "You have an Avalanche node that you want to stake with.",
                  Icons.people,
                  () => null),
              SizedBox(height: 8),
              earntiles(
                  "Delegate",
                  "You do not own an Avalanche node, but you want to stake using another node.",
                  Icons.shield,
                  () => Get.to(() => DelegatePage())),
              SizedBox(height: 8),
              earntiles(
                  "Estimated Rewards",
                  "View staking rewards you will receive.",
                  Icons.currency_exchange,
                  () => Get.to(() => RewardsPage())),
            ],
          ),
        ),
      ),
    );
  }
}
