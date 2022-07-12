import 'dart:math';
import 'package:axwallet_sdk/axwallet_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/cache.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/wallet/coin_page.dart';
import 'package:wallet/pages/wallet/collectibles.dart';
import 'package:wallet/pages/search.dart';
import 'package:wallet/pages/wallet/finance.dart';
import 'package:wallet/pages/wallet/new_wallet.dart';
import 'package:wallet/pages/wallet/tokens.dart';
import 'package:wallet/widgets/axc_txn_tile.dart';
import 'package:wallet/widgets/balance_card.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/sidebar.dart';
import 'package:wallet/widgets/spinner.dart';
import 'package:wallet/widgets/walletname_update.dart';

class WalletPage extends StatefulWidget {
  WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  int slidingIndex = 0;
  PageController pageController = PageController(keepPage: false);
  List<Widget> pages = [TokensPage(), FinancePage(), CollectiblesPage()];
  bool isLoading = true;
  bool isRefreshing = false;
  List<Currency> data = [];
  Map<Currency, double> balanceInfo = {};
  final TokenData list = Get.find();
  final BalanceData balanceData = Get.find();
  final WalletData walletData = Get.find();
  final AXCWalletData axcWalletData = Get.find();
  List<AXCTransaction> transactions = [];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      getTransactions();
      data = list.data;
      balanceInfo = balanceData.getData();
      if (list.selected == null) list.defaultSelection();
      if (mounted)
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      print("balance is $balanceInfo");
    }
  }

  getTransactions() async {
    // setState(() {
    //   transactions = CustomCacheManager.instance.transactionsFromCache();
    // });
    // transactions = await services.axSDK.api!.transfer.getTransactions();
    // CustomCacheManager.instance.cacheTransactions(transactions);
    // setState(() {});
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
    // currencyList.last.getBalance(["address"]);
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
                  Row(
                    children: [
                      Obx(
                        () => Text(
                          walletData.name.value,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // IconButton(
                      //     onPressed: () async {
                      //       await CommonWidgets.bottomSheet(
                      //           WalletNameUpdate(wname: walletData.name.value));
                      //       setState(() {});
                      //     },
                      //     icon: Icon(
                      //       Icons.edit,
                      //       color: Colors.white,
                      //       size: 18,
                      //     )),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Obx(
                    () => Text(
                      "\$${balanceData.totalBalance.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text.rich(
                      //   TextSpan(
                      //     text: "More",
                      //     style: TextStyle(color: Colors.white, fontSize: 12),
                      //     children: [
                      //       WidgetSpan(
                      //         child: Icon(
                      //           Icons.keyboard_arrow_right,
                      //           color: Colors.white,
                      //           size: 14,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
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
          elevation: 0,
          title: Text("My AXIA Wallet"),
          centerTitle: true,
          //brightness: Brightness.dark,
        );

    Widget multicurrencyModule() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Other Assets",
                  style: TextStyle(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    pushNewScreen(context,
                        screen: SearchPage(
                          searchMode: SearchMode.customize,
                        )).then(
                      (value) {
                        setState(() {});
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
              itemCount: isLoading
                  ? 1
                  : list.selected!.isEmpty
                      ? 1
                      : list.selected!.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, index) {
                if (isLoading) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Spinner(),
                  ));
                }
                if (list.selected!.isEmpty) {
                  return CommonWidgets.empty(
                      "Select at least one more asset to display here");
                }
                Currency currency = list.selected![index];
                CoinData item = currency.coinData;
                String name = item.name;
                String unit = item.unit;
                String rate = "\$${item.rate} ";
                String change = item.change;
                // double balance = balanceInfo[currency]!;
                // String balance = "${balanceInfo[currency]} $unit";
                // String value = "\$" +
                //     (item.rate * balanceInfo[currency]!).toStringAsFixed(2);
                var rand = Random().nextInt(2);
                String ticker = "-$change%";
                if (rand == 0) {
                  ticker = "+$change%";
                }
                return Obx(
                  () => HomeWidgets.coinTile(
                    balance:
                        FormatText.roundOff((balanceData.data![currency]!)) +
                            " $unit",
                    name: name,
                    rate: rate,
                    ticker: ticker,
                    unit: unit,
                    value: "\$" +
                        (item.rate * balanceData.data![currency]!)
                            .toStringAsFixed(2),
                    onTap: () => pushNewScreen(
                      context,
                      screen: CoinPage(
                        currency: currency,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 16)),
        ],
      );
    }

    Widget transactionList() {
      return Column(children: [
        Text(
          "Transaction History",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 8,
        ),
        Obx(
          () => ListView.builder(
              itemCount: axcWalletData.transactions.isEmpty
                  ? 1
                  : axcWalletData.transactions.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: ((context, index) {
                if (axcWalletData.transactions.isEmpty) {
                  return CommonWidgets.empty(
                      "You don't have any transactions in this wallet");
                }
                return AXCTxnTile(
                  transaction: axcWalletData.transactions[index],
                );
              })),
        ),
      ]);
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: appBar(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     var val = currencyList.last.getWallet();
      //     print(val.toJson());
      //     print(val.address);
      //   },
      //   child: Icon(Icons.favorite),
      // ),
      drawer: SideBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          isRefreshing = true;
          await refreshData();
        },
        child: ListView(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: dash(),
            // ),
            NewWalletDashboard(),
            isMulticurrencyEnabled ? multicurrencyModule() : transactionList(),
            SizedBox(
              height: kBottomNavigationBarHeight,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    print("why");
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
