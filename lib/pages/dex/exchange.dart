import 'dart:math';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:get/get.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/dex/all_open_orders.dart';
import 'package:wallet/pages/dex/markets.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({Key? key}) : super(key: key);

  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  bool buyMode = true;

  @override
  Widget build(BuildContext context) {
    Widget proportion(int value) => Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: appColor.withOpacity(0.2),
              ),
              child: Text(
                "$value%",
                style: context.textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );

    Widget tickerItem(double price, double amount, double max, Color color) =>
        Container(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width: (Get.width / 2 - 12) * (amount / max),
                height: 24,
                color: color.withOpacity(0.2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FormatText.roundOff(price, maxDecimals: 4),
                    style: TextStyle(fontSize: 16, color: color),
                  ),
                  Text(
                    FormatText.roundOff(amount, maxDecimals: 2),
                    style: TextStyle(color: color),
                  )
                ],
              ),
            ],
          ),
        );

    Widget left() => Container(
          padding: EdgeInsets.only(left: 8, right: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                // leading: FlutterLogo(),
                title: Row(
                  children: [
                    FlutterLogo(),
                    Text("BTC / BUSD"),
                  ],
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  pushNewScreen(context, screen: MarketsPage());
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            buyMode = true;
                          });
                        },
                        child: Text(
                          "Buy",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: buyMode
                                ? tickerGreen
                                : Colors.blueGrey.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(5),
                                    right: Radius.circular(0)))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            buyMode = false;
                          });
                        },
                        child: Text(
                          "Sell",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: !buyMode
                                ? tickerRed
                                : Colors.blueGrey.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(0),
                                    right: Radius.circular(5)))),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Price BUSD", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 32,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Amount DOT", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    proportion(25),
                    SizedBox(
                      width: 4,
                    ),
                    proportion(50),
                    SizedBox(
                      width: 4,
                    ),
                    proportion(75),
                    SizedBox(
                      width: 4,
                    ),
                    proportion(100)
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Balance"),
                    Text("0 BUSD"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total"),
                    Text("0"),
                  ],
                ),
              ),
              Container(
                width: Get.width,
                padding: EdgeInsets.only(top: 4),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    buyMode ? "Buy DOT" : "Sell DOT",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor: buyMode ? tickerGreen : tickerRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(5),
                              right: Radius.circular(5)))),
                ),
              )
            ],
          ),
        );

    Widget right() => Container(
          padding: EdgeInsets.only(left: 4, right: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                dense: true,
                title: Text("Price BUSD"),
                trailing: Text("Amount"),
              ),
              ListView.builder(
                  itemCount: 6,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var rand = Random().nextDouble();
                    double price = 44.353 + index * rand;
                    double max = 210.7;
                    double amount = index == 5 ? max : 10 + index * rand;
                    return tickerItem(price, amount, max, tickerRed);
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "49.134",
                      style: TextStyle(color: tickerRed),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(
                      Icons.arrow_downward,
                      color: tickerRed,
                    )
                  ],
                ),
              ),
              ListView.builder(
                itemCount: 6,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var rand = Random().nextDouble();
                  double price = 44.353 + index * rand;
                  double max = 210.7;
                  double amount = index == 0 ? max : 10 + index * rand;
                  return tickerItem(price, amount, max, tickerGreen);
                },
              ),
            ],
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
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: left(),
                    ),
                    Expanded(
                      flex: 1,
                      child: right(),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Open Orders",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          pushNewScreen(context, screen: AllOpenOrdersPage());
                        },
                        child: Text("All", style: TextStyle(fontSize: 16)),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                          child: Text(
                        "Open Orders will appear here",
                        style:
                            context.textTheme.caption!.copyWith(fontSize: 14),
                      )),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
