import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/buy.dart';
import 'package:wallet/pages/receive.dart';
import 'package:wallet/pages/send.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';

class CoinPage extends StatefulWidget {
  final Currency currency;
  final double balance;
  const CoinPage({Key? key, required this.currency, required this.balance})
      : super(key: key);

  @override
  _CoinPageState createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  late Currency currency;
  late double balance;
  bool isLoading = true;
  bool isRefreshing = false;
  List data = [];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  copyAddress() {
    String address = currency.getWallet().address;
    Clipboard.setData(ClipboardData(text: address));
    CommonWidgets.snackBar(address, copyMode: true);
  }

  @override
  void initState() {
    super.initState();
    currency = widget.currency;
    balance = widget.balance;
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    double height = Get.height;
    double width = Get.width;
    AppBar appBar() => AppBar(
          // //brightness: Brightness.dark,
          title: Text("Token Details"),
          centerTitle: true,
          elevation: 0,
          leading: CommonWidgets.backButton(context),
          actions: [
            // TextButton(
            //     onPressed: () => Get.to(() => BuyPage(
            //           currency: currency,
            //           minimum: 50,
            //         )),
            //     child: Text(
            //       "BUY",
            //       style: TextStyle(color: Colors.white),
            //     )),
            IconButton(onPressed: () {}, icon: Icon(Icons.search))
          ],
        );

    Widget header() {
      return Container(
        // padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // HomeWidgets.coinPageHeaderText("COIN"),
            // Spacer(),
            HomeWidgets.coinPageHeaderText("\$${currency.coinData.rate} "),
            HomeWidgets.coinPageHeaderText("${currency.coinData.change}",
                isTicker: true)
          ],
        ),
      );
    }

    Widget dash() => Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: height * 0.15,
              width: width,
              color: appColor[600],
            ),
            CommonWidgets.elevatedContainer(
              child: Column(
                children: [
                  // header(),
                  // SizedBox(
                  //   height: 4,
                  // ),
                  SizedBox(
                      width: Get.width * 0.15,
                      height: Get.width * 0.15,
                      child: Image.asset(
                          "assets/currencies/${currency.coinData.unit}.png")),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    currency.coinData.name,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  header(),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Text(
                    "$balance ${currency.coinData.unit}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Portfolio Worth: \$${(balance * currency.coinData.rate).toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: copyAddress,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          FormatText.address(currency.getWallet().address),
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              color: Colors.grey[100]),
                          child: Text(
                            "COPY",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: HomeWidgets.quickAction(
                            icon: "assets/icons/deposit.svg",
                            text: "Deposit",
                            onPressed: () =>
                                Get.to(() => ReceivePage(currency: currency)),
                            whiteBG: true),
                      ),
                      Expanded(
                        child: HomeWidgets.quickAction(
                            icon: "assets/icons/buy.svg",
                            text: "Buy",
                            onPressed: () => Get.to(
                                () => BuyPage(currency: currency, minimum: 50)),
                            whiteBG: true),
                      ),
                      Expanded(
                        child: HomeWidgets.quickAction(
                            icon: "assets/icons/send.svg",
                            text: "Send",
                            onPressed: () => Get.to(() =>
                                SendPage(currency: currency, balance: balance)),
                            whiteBG: true),
                      ),
                      Expanded(
                        child: HomeWidgets.quickAction(
                            icon: "assets/icons/swap.svg",
                            text: "Swap",
                            onPressed: copyAddress,
                            whiteBG: true),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ],
        );

    Widget emptyList() {
      return Padding(
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
              HomeWidgets.emptyListText("You Have No Transaction History Yet"),
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
      );
    }

    return Scaffold(
        appBar: appBar(),
        body: Container(
          child: ListView(
            children: [
              dash(),
              ListView.builder(
                  itemCount: data.isEmpty ? 1 : data.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    // if (index == 0) return dash();
                    if (isLoading) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    } else if (data.isEmpty) return emptyList();
                    return ListTile(
                      title: Text("Transaction #$index"),
                    );
                  }),
            ],
          ),
        ));
  }
}
