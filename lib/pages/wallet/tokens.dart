import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/search.dart';
import 'package:wallet/pages/wallet/coin_page.dart';
import 'package:wallet/widgets/home_widgets.dart';

final tokensKey = new GlobalKey<_TokensPageState>();

class TokensPage extends StatefulWidget {
  TokensPage({Key? key}) : super(key: tokensKey);

  @override
  _TokensPageState createState() => _TokensPageState();
}

class _TokensPageState extends State<TokensPage>
    with AutomaticKeepAliveClientMixin {
  bool keepAlive = true;
  @override
  bool get wantKeepAlive => keepAlive;

  bool isLoading = true;
  bool isRefreshing = false;
  List<CoinData> data = [];
  Map<CoinData, double> balanceInfo = {};
  final TokenData list = Get.find();
  final BalanceData balanceData = Get.find();

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      data = list.data;
      balanceInfo = balanceData.getData();
      if (list.selected == null) list.defaultSelection();
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = Get.width;
    double height = Get.height;
    List tickerColor = [Colors.green[900], Colors.red[800]];

    Widget dash() {
      double totalBalance = 0.0;
      if (balanceInfo.isNotEmpty) {
        balanceInfo.forEach((key, value) {
          if (key.selected) totalBalance += value * key.value;
        });
      }
      return Container(
          // height: Get.height * 0.25,
          width: width,
          constraints: BoxConstraints(maxHeight: height * 0.50),
          color: appColor,
          child: Container(
              padding: EdgeInsets.only(top: width * 0.05, bottom: width * 0.03),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\$${totalBalance.toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.white, fontSize: 48),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Wallet 1",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HomeWidgets.quickAction(
                          icon: Icon(Icons.upload_outlined),
                          text: "Send",
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen: SearchPage(searchMode: SearchMode.send),
                            );
                          }),
                      HomeWidgets.quickAction(
                          icon: Icon(Icons.download_outlined),
                          text: "Receive",
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen:
                                  SearchPage(searchMode: SearchMode.receive),
                            );
                          }),
                      HomeWidgets.quickAction(
                          icon: Icon(Icons.local_offer_outlined),
                          text: "Buy",
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen: SearchPage(searchMode: SearchMode.buy),
                            );
                          })
                    ],
                  )
                ],
              )));
    }

    return RefreshIndicator(
      onRefresh: () async {
        isRefreshing = true;
        await refreshData();
      },
      child: ListView.builder(
        itemCount: isLoading ? 2 : list.selected.length + 1,
        itemBuilder: (context, index) {
          if (isLoading || index == 0) {
            if (index == 0) return dash();
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator.adaptive(),
            ));
          }
          CoinData item = list.selected[index - 1];
          String name = item.name;
          String unit = item.unit;
          String value = "\$${item.value} ";
          String change = item.change;
          String balance = "${balanceInfo[item]} $unit";
          var rand = Random().nextInt(2);
          String ticker = "-$change%";
          if (rand == 0) {
            ticker = "+$change%";
          }
          return ListTile(
            leading: FlutterLogo(),
            trailing: Text(balance),
            title: Text(name),
            subtitle: Text.rich(
              TextSpan(text: value, children: [
                TextSpan(
                    text: ticker, style: TextStyle(color: tickerColor[rand]))
              ]),
            ),
            onTap: () => pushNewScreen(
              context,
              screen: CoinPage(
                coinData: item,
                balance: balanceInfo[item]!,
              ),
            ),
          );
        },
        // children: [
        //   dash(),
        // ],
      ),
    );
  }
}
