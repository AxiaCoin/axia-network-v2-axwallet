import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/buy.dart';
import 'package:wallet/pages/receive.dart';
import 'package:wallet/pages/send.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';

class CoinPage extends StatefulWidget {
  final CoinData coinData;
  final double balance;
  const CoinPage({Key? key, required this.coinData, required this.balance})
      : super(key: key);

  @override
  _CoinPageState createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  late CoinData coinData;
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
    Clipboard.setData(ClipboardData(text: dummyAddress));
    CommonWidgets.snackBar(dummyAddress, copyMode: true);
  }

  @override
  void initState() {
    super.initState();
    coinData = widget.coinData;
    balance = widget.balance;
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          // //brightness: Brightness.dark,
          title: Text("${coinData.name} (${coinData.unit})"),
          actions: [
            TextButton(
                onPressed: () => Get.to(() => BuyPage(
                      coinData: coinData,
                      minimum: 50,
                    )),
                child: Text(
                  "BUY",
                  style: TextStyle(color: Colors.white),
                )),
            IconButton(onPressed: () {}, icon: Icon(Icons.show_chart_outlined))
          ],
        );

    Widget header() {
      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            HomeWidgets.coinPageHeaderText("COIN"),
            Spacer(),
            HomeWidgets.coinPageHeaderText("\$${coinData.value} "),
            HomeWidgets.coinPageHeaderText(coinData.change, isTicker: true)
          ],
        ),
      );
    }

    Widget dash() => Column(
          children: [
            header(),
            SizedBox(
                width: Get.width * 0.15,
                height: Get.width * 0.15,
                child: FlutterLogo()),
            SizedBox(
              height: 8,
            ),
            Text("$balance ${coinData.unit}"),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HomeWidgets.quickAction(
                    icon: Icon(Icons.upload_outlined),
                    text: "Send",
                    onPressed: () =>
                        Get.to(SendPage(coinData: coinData, balance: balance)),
                    whiteBG: true),
                HomeWidgets.quickAction(
                    icon: Icon(Icons.download_outlined),
                    text: "Receive",
                    onPressed: () => Get.to(ReceivePage(coinData: coinData)),
                    whiteBG: true),
                HomeWidgets.quickAction(
                    icon: Icon(Icons.copy),
                    text: "Copy",
                    onPressed: copyAddress,
                    whiteBG: true),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Divider(),
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
                child: FittedBox(child: FlutterLogo()),
              ),
              SizedBox(
                height: 16,
              ),
              HomeWidgets.emptyListText("Transactions will appear here"),
              // SizedBox(height: 8,),
              TextButton(
                  onPressed: () => Get.to(() => BuyPage(
                        coinData: coinData,
                        minimum: 50,
                      )),
                  child: Text("Buy ${coinData.name}"))
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: appBar(),
        body: Container(
          child: ListView.builder(
              itemCount: data.isEmpty ? 2 : data.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return dash();
                if (isLoading)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                else if (data.isEmpty) return emptyList();
                return ListTile(
                  title: Text("Transaction #$index"),
                );
              }),
        ));
  }
}
