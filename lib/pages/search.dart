import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List<CoinData> searchList = [];
  List<CoinData> validSendingList = [];
  bool searchFailed = false;
  late bool isSendMode;

  List<CoinData> getValidTokensForSending() {
    if (validSendingList.isEmpty)
      balanceCont.getData().forEach((key, value) {
        if (value != 0.0) validSendingList.add(key);
      });
    return validSendingList;
  }

  searchString(String query) {
    List<CoinData> data = isSendMode ? validSendingList : list.data;
    searchList.clear();
    bool found = false;
    searchFailed = false;
    data.forEach((e) {
      if (query != "") {
        if (e.name.toLowerCase().contains(query.toLowerCase()) || e.unit.toLowerCase().contains(query.toLowerCase())) {
          print("found ${e.name}");
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
      decoration: InputDecoration(hintText: "Search Tokens", hintStyle: TextStyle(color: Colors.white), border: InputBorder.none),
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

  Widget listTile(CoinData item, int index) {
    Map<CoinData, double> balanceData = balanceCont.getData();
    switch (widget.searchMode) {
      case SearchMode.customize:
        return SwitchListTile(
          value: item.selected,
          // onChanged: (val) => setState(() => item.selected = val),
          onChanged: (val) {
            list.changeSelection(index, val);
            setState(() {});
          },
          title: Text(item.name),
          subtitle: Text(item.unit),
          secondary: FlutterLogo(),
        );
      case SearchMode.buy:
        return ListTile(
          onTap: () {
            Get.bottomSheet(
                BuyPage(coinData: item, minimum: 50,),
              isScrollControlled: true
            );
          },
          title: Text(item.name),
          subtitle: Text(item.unit),
          leading: FlutterLogo(),
          trailing: Text("${balanceData[item]} ${item.unit}"),
        );
      case SearchMode.send:
        return ListTile(
          onTap: (){
            Get.to(() => SendPage(coinData: item, balance: balanceData[item]!,));
          },
          title: Text(item.name),
          subtitle: Text(item.unit),
          leading: FlutterLogo(),
          trailing: Text("${balanceData[item]} ${item.unit}"),
        );
      case SearchMode.receive:
        return ListTile(
          onTap: () {
            Get.to(ReceivePage(coinData: item,));
          },
          title: Text(item.name),
          subtitle: Text(item.unit),
          leading: FlutterLogo(),
          trailing: Text("${balanceData[item]} ${item.unit}"),
        );
      case SearchMode.swap:
        return ListTile(
          onTap: () {
            print("back");
            Get.back(result: item);
          },
          title: Text(item.name),
          subtitle: Text(item.unit),
          leading: FlutterLogo(),
          trailing: Text("${balanceData[item]} ${item.unit}"),
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
                    itemCount: searchList.isNotEmpty ? searchList.length : isSendMode ? validSendingList.length : list.data.length,
                    itemBuilder: (context, index) {
                      // CoinData item = coinData![index];
                      CoinData item = searchList.isNotEmpty ? searchList[index] : isSendMode ? validSendingList[index] : list.data[index];
                      return listTile(item, index);
                    }),
        ));
  }
}
