import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/wallet/coin_page.dart';
import 'package:wallet/pages/wallet/collectibles.dart';
import 'package:wallet/pages/search.dart';
import 'package:wallet/pages/wallet/finance.dart';
import 'package:wallet/pages/wallet/notifications.dart';
import 'package:wallet/pages/wallet/tokens.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/sidebar.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int slidingIndex = 0;
  PageController pageController = PageController(keepPage: false);
  List<Widget> pages = [TokensPage(), FinancePage(), CollectiblesPage()];
  bool isLoading = true;
  bool isRefreshing = false;
  List<Currency> data = [];
  Map<Currency, double> balanceInfo = {};
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
      print("balance is $balanceInfo");
    }
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    double width = Get.width;
    double height = Get.height;
    List tickerColor = [tickerGreen, tickerRed];
    double totalBalance = 0.0;
    if (balanceInfo.isNotEmpty) {
      balanceInfo.forEach((key, value) {
        if (key.coinData.selected) totalBalance += value * key.coinData.rate;
      });
    }

    Widget dash() {
      return Container(
          // height: Get.height * 0.25,
          width: width,
          constraints: BoxConstraints(maxHeight: height * 0.50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            gradient: LinearGradient(
                colors: [appColor[600]!, appColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
          ),
          child: Container(
              padding: EdgeInsets.only(
                top: width * 0.04,
                bottom: width * 0.04,
                left: width * 0.04,
                right: width * 0.03,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                        color: appColor[300]),
                    child: Text(
                      "+2.5%",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Text(
                    "WALLET 1",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "\$${totalBalance.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: "More",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.white,
                                size: 14,
                              ),
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      HomeWidgets.quickAction(
                          icon: "assets/icons/receive_dash.svg",
                          // text: "Receive",
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen:
                                  SearchPage(searchMode: SearchMode.receive),
                            );
                          }),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      HomeWidgets.quickAction(
                          icon: "assets/icons/send_dash.svg",
                          // text: "Send",
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen: SearchPage(searchMode: SearchMode.send),
                            );
                          }),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      // HomeWidgets.quickAction(
                      //     icon: Icon(Icons.local_offer_outlined),
                      //     text: "Buy",
                      //     onPressed: () {
                      //       pushNewScreen(
                      //         context,
                      //         screen: SearchPage(searchMode: SearchMode.buy),
                      //       );
                      //     })
                    ],
                  )
                ],
              )));
    }

    AppBar appBar() => AppBar(
          // actions: [
          //   slidingIndex == 0
          //       ? IconButton(
          //           icon: Icon(Icons.tune_outlined),
          //           onPressed: () {
          //             pushNewScreen(context,
          //                 screen: SearchPage(
          //                   searchMode: SearchMode.customize,
          //                 )).then(
          //               (value) {
          //                 tokensKey.currentState?.setState(() {});
          //               },
          //             );
          //           },
          //         )
          //       : Container()
          // ],
          // leading: slidingIndex == 0
          //     ? IconButton(
          //         icon: Icon(Icons.notifications_none),
          //         onPressed: () => Get.to(() => NotificationsPage()),
          //       )
          //     : Container(),
          elevation: 0,
          title: Text("My AXIA Wallet"),
          centerTitle: true,
          //brightness: Brightness.dark,
        );

    return Scaffold(
      appBar: appBar(),
      drawer: SideBar(
        totalBalance: totalBalance,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          isRefreshing = true;
          await refreshData();
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: dash(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Portfolio",
                    style: TextStyle(fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      pushNewScreen(context,
                          screen: SearchPage(
                            searchMode: SearchMode.customize,
                          )).then(
                        (value) {
                          tokensKey.currentState?.setState(() {});
                        },
                      );
                    },
                    child: Text(
                      "Edit Assets",
                      style: TextStyle(color: appColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
                color: Colors.grey[50],
              ),
              child: ListView.builder(
                itemCount: isLoading ? 1 : list.selected!.length,
                shrinkWrap: true,
                primary: false,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator.adaptive(),
                    ));
                  }
                  Currency currency = list.selected![index];
                  CoinData item = currency.coinData;
                  String name = item.name;
                  String unit = item.unit;
                  String rate = "\$${item.rate} ";
                  String change = item.change;
                  String balance = "${balanceInfo[currency]} $unit";
                  String value = "\$" +
                      (item.rate * balanceInfo[currency]!).toStringAsFixed(2);
                  var rand = Random().nextInt(2);
                  String ticker = "-$change%";
                  if (rand == 0) {
                    ticker = "+$change%";
                  }
                  return HomeWidgets.coinTile(
                    balance: balance,
                    name: name,
                    rate: rate,
                    ticker: ticker,
                    unit: unit,
                    value: value,
                    onTap: () => pushNewScreen(
                      context,
                      screen: CoinPage(
                        currency: currency,
                        balance: balanceInfo[currency]!,
                      ),
                    ),
                  );
                  // return ListTile(
                  //   leading: Image.asset(
                  //     "assets/currencies/$unit.png",
                  //     height: 40,
                  //     width: 40,
                  //     fit: BoxFit.contain,
                  //     filterQuality: FilterQuality.high,
                  //   ),
                  //   trailing: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.end,
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         balance,
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //       Text(
                  //         value,
                  //         style: TextStyle(
                  //           fontSize: 14,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   title: Text(
                  //     name,
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  //   subtitle: Text.rich(
                  //     TextSpan(
                  //       text: rate,
                  //       children: [
                  //         TextSpan(
                  //             text: ticker,
                  //             style: TextStyle(color: tickerColor[rand]))
                  //       ],
                  //     ),
                  //   ),
                  //   onTap: () => pushNewScreen(
                  //     context,
                  //     screen: CoinPage(
                  //       currency: currency,
                  //       balance: balanceInfo[currency]!,
                  //     ),
                  //   ),
                  // );
                },
                // children: [
                //   dash(),
                // ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
