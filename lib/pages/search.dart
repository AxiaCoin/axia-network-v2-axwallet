import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/buy.dart';
import 'package:wallet/pages/receive.dart';
import 'package:wallet/pages/send.dart';
import 'package:wallet/widgets/home_widgets.dart';

class SearchPage extends StatefulWidget {
  final SearchMode searchMode;
  const SearchPage({Key? key, required this.searchMode}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = TextEditingController();
  final TokenData list = Get.find();
  final BalanceData balanceCont = Get.find();
  List<Currency> searchList = [];
  List<Currency> validSendingList = [];
  bool searchFailed = false;
  late bool isSendMode;

  List<Currency> getValidTokensForSending() {
    if (validSendingList.isEmpty)
      balanceCont.getData().forEach((key, value) {
        if (value != 0.0) validSendingList.add(key);
      });
    return validSendingList;
  }

  searchString(String query) {
    List<Currency> data = isSendMode ? validSendingList : list.data;
    searchList.clear();
    bool found = false;
    searchFailed = false;
    data.forEach((e) {
      if (query != "") {
        if (e.coinData.name.toLowerCase().contains(query.toLowerCase()) ||
            e.coinData.unit.toLowerCase().contains(query.toLowerCase())) {
          print("found ${e.coinData.name}");
          found = true;
          searchList.add(e);
        }
      } else {
        searchFailed = false;
        searchList.clear();
      }
    });
    if (!found && query != "") {
      searchFailed = true;
    }
    setState(() {});
  }

  Widget searchField() {
    return TextField(
      controller: textEditingController,
      autofocus: widget.searchMode == SearchMode.customize,
      decoration: InputDecoration(
          hintText: "Search Tokens",
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none),
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.white),
      onChanged: searchString,
    );
  }

  Widget emptyList() {
    return Center(
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
          HomeWidgets.emptyListText("No Assets found"),
          // SizedBox(height: 8,),
        ],
      ),
    );
  }

  Widget listTile(Currency item, int index) {
    Map<Currency, double> balanceData = balanceCont.getData();
    if (widget.searchMode == SearchMode.customize) {
      return SwitchListTile.adaptive(
        value: item.coinData.selected,
        // onChanged: (val) => setState(() => item.selected = val),
        onChanged: (val) {
          list.changeSelection(index, val);
          setState(() {});
        },
        title: Text(
          item.coinData.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(item.coinData.unit),
        secondary: Image.asset(
          "assets/currencies/${item.coinData.unit}.png",
          height: 40,
          width: 40,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      );
    } else {
      return HomeWidgets.coinTile(
        onTap: () {
          switch (widget.searchMode) {
            case SearchMode.customize:
              break;
            case SearchMode.send:
              Get.to(() => SendPage(
                    currency: item,
                    balance: balanceData[item]!,
                  ));
              break;
            case SearchMode.receive:
              Get.to(() => ReceivePage(
                    currency: item,
                  ));
              break;
            case SearchMode.buy:
              Get.bottomSheet(
                  BuyPage(
                    currency: item,
                    minimum: 50,
                  ),
                  isScrollControlled: true);
              break;
            case SearchMode.swap:
              Get.back(result: item);
              break;
          }
        },
        balance: "${balanceData[item]} ${item.coinData.unit}",
        unit: item.coinData.unit,
        name: item.coinData.name,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    isSendMode = widget.searchMode == SearchMode.send;
    getValidTokensForSending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchField(),
        //brightness: Brightness.dark,
      ),
      body: Container(
        child: searchFailed
            ? emptyList()
            : ListView.builder(
                itemCount: searchList.isNotEmpty
                    ? searchList.length
                    : isSendMode
                        ? validSendingList.length
                        : list.data.length,
                itemBuilder: (context, index) {
                  // CoinData item = coinData![index];
                  Currency item = searchList.isNotEmpty
                      ? searchList[index]
                      : isSendMode
                          ? validSendingList[index]
                          : list.data[index];
                  return listTile(item, index);
                },
              ),
      ),
    );
  }
}
