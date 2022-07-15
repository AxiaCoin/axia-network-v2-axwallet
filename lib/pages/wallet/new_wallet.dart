import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/network_switch.dart';
import 'package:wallet/widgets/address_card.dart';
import 'package:wallet/widgets/balance_card.dart';
import 'package:wallet/widgets/spinner.dart';

class NewWalletDashboard extends StatefulWidget {
  const NewWalletDashboard({Key? key}) : super(key: key);

  @override
  State<NewWalletDashboard> createState() => _NewWalletDashboardState();
}

class _NewWalletDashboardState extends State<NewWalletDashboard> {
  AXCWalletData axcWalletData = Get.find();
  bool isRefreshing = false;

  Future<void> onRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    // await Future.delayed(Duration(milliseconds: 1000));
    await services.getAXCWalletDetails();
    setState(() {
      isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget networkStatus() {
      return Obx(
        () => Center(
          child: GestureDetector(
            onTap: () async {
              await Get.to(() => NetworkSwitchPage());
              setState(() {});
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
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Column(
          children: [
            networkStatus(),
            Stack(
              alignment: Alignment(0.9, 1),
              children: [
                BalanceCard(),
                IconButton(
                  onPressed: () async {
                    onRefresh();
                  },
                  icon: isRefreshing
                      ? Spinner(
                          alt: true,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
            SizedBox(height: 8),
            AddressCard(),
            SizedBox(height: 8),
            // PluginWidgets.indexTitle(
            //     "You can earn more AXC by staking your existing tokens."),
            // PluginWidgets.earntiles(
            //     "Validate",
            //     "You have an Axia node that you want to stake with.",
            //     Icons.people,
            //     () => null),
            // SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
