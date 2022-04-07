import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wallet/code/constants.dart';
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
  int selectedIndex = 0;
  List<String> titles = [
    "History",
    "New DApps",
    "DeFi",
    "Popular",
    "Smart Chain",
    "Yield Farming",
    "Games",
    "Exchanges",
    "Marketplaces"
  ];

  Future refreshData() async {
    if (isLoading || isRefreshing) {
      await 1.delay();
      titles.forEach((element) {
        List<DAppsTile> items = [];
        var rand = Random().nextInt(15);
        for (var i = 0; i < rand + 4; i++) {
          items.add(DAppsTile(
              "Title",
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sed.",
              FlutterLogo(),
              "https://www.google.com/"));
        }
        data[element] = items;
      });

      List<DAppsTile> items = [];
      items.add(DAppsTile(
          "AXIA Swap",
          "Enjoy latest news on premium experience...",
          Image.asset("assets/icons/axia_swap.png"),
          "https://www.google.com/"));
      items.add(DAppsTile(
          "AXclusive",
          "Enjoy latest news on premium experience...",
          Image.asset("assets/icons/axclusive.png"),
          "https://www.google.com/"));
      items.add(DAppsTile(
          "AXelerator",
          "Discover latest info on real-time exchange",
          Image.asset("assets/icons/axelerator.png"),
          "https://www.google.com/"));
      items.add(DAppsTile(
          "AXplorer",
          "Reduced gas fees are here! Read more below",
          Image.asset("assets/icons/axplorer.png"),
          "https://www.google.com/"));
      data["History"] = items;
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
    Widget searchbar() => Container(
          // height: kToolbarHeight * 0.8,
          // width: Get.width * 0.8,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x4040401A),
                spreadRadius: 0,
                blurRadius: 16,
              ),
            ],
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black12,
                ),
                hintText: "Search",
                hintStyle: TextStyle(
                  color: Colors.black12,
                )),
          ),
        );
    AppBar appBar() => AppBar(
          title: Text("DApps"),
          centerTitle: true,
        );

    Widget banner() => Container(
          width: Get.width,
          height: Get.height * 0.15,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            gradient: LinearGradient(
                colors: [appColor[600]!, appColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Discover New Tokens",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "See the latest trends in the\ncryptocurrency world",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 24,
              )
            ],
          ),
        );

    Widget titlesWidget() => Container(
          height: 50,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Color(0x2424240F),
                offset: Offset(0, 4),
                spreadRadius: 0,
                blurRadius: 16,
              ),
            ],
          ),
          child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              scrollDirection: Axis.horizontal,
              itemCount: titles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: HomeWidgets.dAppsTitle(
                      title: titles[index], selected: index == selectedIndex),
                );
              }),
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: appBar(),
        body: Container(
          child: isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : RefreshIndicator(
                  onRefresh: () async {
                    isRefreshing = true;
                    await refreshData();
                  },
                  child: ListView(
                    children: [
                      searchbar(),
                      banner(),
                      titlesWidget(),
                      Container(
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          color: Colors.grey[50],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: data[titles[selectedIndex]]!.length,
                          itemBuilder: (context, index) {
                            // return listItem(data[titles[selectedIndex]]![index]);
                            return HomeWidgets.dAppsList(context,
                                data: data[titles[selectedIndex]]![index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
