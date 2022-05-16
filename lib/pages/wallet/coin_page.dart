import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/receive.dart';
import 'package:wallet/pages/send.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:intl/intl.dart';
import 'package:wallet/widgets/transactions.dart';

class CoinPage extends StatefulWidget {
  final Currency currency;
  const CoinPage({Key? key, required this.currency}) : super(key: key);

  @override
  _CoinPageState createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  late Currency currency;
  bool isLoading = true;
  bool isRefreshing = false;
  int total = 0;
  int offset = 0;
  List<TransactionItem> transactions = [];
  final BalanceData balanceData = Get.find();
  final ScrollController scrollController = ScrollController();

  Future refreshData() async {
    print("fetching");
    if (isLoading || isRefreshing) {
      // await 1.delay();
      TransactionListModel data = await currency.getTransactions(
        offset: isRefreshing ? 0 : offset,
        limit: 10,
      );
      if (isRefreshing) {
        offset = 0;
        transactions = data.transactionList;
      } else {
        transactions.addAll(data.transactionList);
      }
      total = data.total;
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
      print(total);
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
    scrollController.addListener(
      () {
        if (scrollController.offset >
                scrollController.position.maxScrollExtent - 50 &&
            transactions.isNotEmpty &&
            transactions.length < total &&
            !isLoading &&
            !isRefreshing) {
          isLoading = true;
          offset += 10;
          refreshData();
        }
      },
    );
    refreshData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
              child: Obx(
                () => Column(
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
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                    header(),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Text(
                      FormatText.roundOff((balanceData.data![currency])!,
                              maxDecimals: 8) +
                          " ${currency.coinData.unit}",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Portfolio Worth: \$${(balanceData.data![currency]! * currency.coinData.rate).toStringAsFixed(2)}",
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
                        // Expanded(
                        //   child: HomeWidgets.quickAction(
                        //       icon: "assets/icons/buy.svg",
                        //       text: "Buy",
                        //       onPressed: () => Get.to(() =>
                        //           BuyPage(currency: currency, minimum: 50)),
                        //       whiteBG: true),
                        // ),
                        Expanded(
                          child: HomeWidgets.quickAction(
                              icon: "assets/icons/send.svg",
                              text: "Send",
                              onPressed: () async {
                                bool? success = await Get.to(() => SendPage(
                                      currency: currency,
                                    ));
                                if (success ?? false) {
                                  isRefreshing = true;
                                  refreshData();
                                }
                              },
                              whiteBG: true),
                        ),
                        // Expanded(
                        //   child: HomeWidgets.quickAction(
                        //       icon: "assets/icons/swap.svg",
                        //       text: "Swap",
                        //       onPressed: () {},
                        //       whiteBG: true),
                        // ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
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
          child: RefreshIndicator(
            onRefresh: () async {
              isRefreshing = true;
              await refreshData();
            },
            child: ListView(
              controller: scrollController,
              children: [
                dash(),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                    color: Colors.grey[50],
                  ),
                  child: ListView.builder(
                      itemCount: transactions.isEmpty
                          ? 1
                          : total != transactions.length
                              ? transactions.length + 1
                              : transactions.length,
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
                        } else if (transactions.isEmpty) return emptyList();
                        if (index == transactions.length &&
                            transactions.isNotEmpty &&
                            total != transactions.length) {
                          return Center(
                              child: CircularProgressIndicator.adaptive());
                        }
                        TransactionItem item = transactions[index];
                        bool isReceived = item.to.toLowerCase() ==
                            currency.getWallet().address.toLowerCase();
                        return ListTile(
                          title: Text(
                              "${isReceived ? "Received from" : "Sent to"}: ${FormatText.address(isReceived ? item.from : item.to)}"),
                          subtitle: Text(
                              DateFormat.yMMMd().format(item.time.toLocal()) +
                                  " at " +
                                  DateFormat.jm().format(item.time.toLocal())),
                          trailing: Text(
                            FormatText.roundOff(item.amount) +
                                " ${currency.coinData.unit}",
                            style: TextStyle(
                                color: isReceived ? tickerGreen : tickerRed),
                          ),
                          leading: SvgPicture.asset(
                            "assets/icons/${isReceived ? "receive" : "send"}_dash.svg",
                            color: appColor,
                            height: 35,
                          ),
                          onTap: () {
                            CommonWidgets.bottomSheet(TransactionsPage(
                              transaction: item,
                              coinData: currency.coinData,
                              isReceived: isReceived,
                            ));
                          },
                        );
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
