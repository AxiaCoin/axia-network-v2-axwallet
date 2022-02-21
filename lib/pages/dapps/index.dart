import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/widgets/home_widgets.dart';

class DAppsPage extends StatefulWidget {
  const DAppsPage({Key? key}) : super(key: key);

  @override
  _DAppsPageState createState() => _DAppsPageState();
}

class _DAppsPageState extends State<DAppsPage> {
  TextEditingController controller = new TextEditingController();
  bool isLoading = true;
  bool isRefreshing = false;
  Map<String, List<DAppsTile>> data = {};
  List<String> titles = ["New DApps", "DeFi", "Popular", "Smart Chain", "Yield Farming", "Games", "Exchanges", "Marketplaces"];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      titles.forEach((element) {
        List<DAppsTile> items = [];
        var rand = Random().nextInt(15);
        for (var i = 0; i < rand + 4; i++) {
          items.add(DAppsTile("Title", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sed.", FlutterLogo(), "https://www.google.com/"));
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

    AppBar appBar() => AppBar(
      title: Container(
        height: kToolbarHeight * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)
          ),
          color: Colors.white,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.black12,),
            hintText: "Search or enter website url"
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: appBar(),
        body: Container(
          child: isLoading ? Center(child: CircularProgressIndicator()) : RefreshIndicator(
            onRefresh: () async {
              isRefreshing = true;
              await refreshData();
            },
            child: ListView.builder(
              itemCount: titles.length,
              itemBuilder: (context, index) {
                return HomeWidgets.dAppsCarousel(context, title: titles[index], data: data[titles[index]]!);
              },
            ),
          ),
        ),
      ),
    );
  }
}
