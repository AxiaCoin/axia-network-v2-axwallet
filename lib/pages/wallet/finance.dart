import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/pages/wallet/coin_page.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/spinner.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({Key? key}) : super(key: key);

  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with AutomaticKeepAliveClientMixin {
  bool keepAlive = true;
  @override
  bool get wantKeepAlive => keepAlive;

  bool isLoading = true;
  bool isRefreshing = false;
  List<Currency> currencyList = [];
  Map<Currency, double> balanceInfo = {};
  final TokenData list = Get.find();
  final BalanceData balanceData = Get.find();
  Map<String, List<Currency>> data = {};
  List<String> titles = [
    "Staking",
    "DeFi Tokens",
    "Lending / Borrowing",
    "Smart Chain / BSC",
    "DeFi"
  ];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      currencyList = list.data;
      balanceInfo = balanceData.getData();
      titles.forEach((element) {
        List<Currency> items = [];
        var rand = Random().nextInt(7);
        for (var i = 0; i < rand + 1; i++) {
          items.add(currencyList[Random().nextInt(currencyList.length)]);
        }
        data[element] = items;
      });
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
    return Scaffold(
      body: Container(
        child: data.isEmpty
            ? Center(child: Spinner())
            : ListView.builder(
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return HomeWidgets.financeList(context,
                      title: titles[index], data: data[titles[index]]!);
                }),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final String title;
  final List<Currency> data;
  MorePage({Key? key, required this.data, required this.title})
      : super(key: key);

  final BalanceData balanceData = Get.find();

  @override
  Widget build(BuildContext context) {
    final balanceInfo = balanceData.getData();
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
          child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                Currency item = data[index];
                return ListTile(
                  title: Text("${item.coinData.name} (${item.coinData.unit})"),
                  leading: FlutterLogo(),
                  onTap: () {
                    pushNewScreen(context, screen: CoinPage(currency: item));
                  },
                );
              }),
        ));
  }
}
