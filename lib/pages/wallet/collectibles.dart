import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/receive.dart';
import 'package:wallet/pages/webview.dart';
import 'package:wallet/widgets/home_widgets.dart';

class CollectiblesPage extends StatefulWidget {
  const CollectiblesPage({Key? key}) : super(key: key);

  @override
  _CollectiblesPageState createState() => _CollectiblesPageState();
}

class _CollectiblesPageState extends State<CollectiblesPage> with AutomaticKeepAliveClientMixin{
  bool keepAlive = true;
  @override
  bool get wantKeepAlive => keepAlive;

  final TokenData list = Get.find();
  late CoinData ethCoin;
  bool isLoading = true;
  bool isRefreshing = false;
  List data = [];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      ethCoin = list.data[0];
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Widget emptyList() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: Get.width * 0.25,
            width: Get.width * 0.25,
            child: FittedBox(

                child: FlutterLogo()
            ),
          ),
          SizedBox(height: 16,),
          HomeWidgets.emptyListText("Collectibles will appear here"),
          // SizedBox(height: 8,),
          TextButton(onPressed: () async {
            Get.to(() => ReceivePage(coinData: ethCoin));
          }, child: Text("Receive")),
          TextButton(onPressed: () async {
            Get.to(() => WebViewPage(url: "https://www.google.com/"));
          }, child: Text("Open on OpenSea.io"))
        ],
      ),
    );
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
        child: Center(
          child: isLoading ? Center(child: CircularProgressIndicator.adaptive()) : emptyList(),
        ),
      ),
    );
  }
}
