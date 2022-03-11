import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/dapps/see_all.dart';
import 'package:wallet/pages/wallet/coin_page.dart';
import 'package:wallet/pages/wallet/finance.dart';
import 'package:wallet/pages/webview.dart';

class HomeWidgets {
  HomeWidgets._();

  static Widget segmentedText(String text) => Text(
        text,
        style: TextStyle(fontSize: 13),
        maxLines: 1,
      );

  static Widget emptyListText(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black54),
        maxLines: 1,
      );

  static Widget coinPageHeaderText(String text, {bool isTicker = false}) {
    bool? isGreen;
    if (isTicker) {
      double change = double.parse(text);
      isGreen = change > 0;
      text = isGreen ? "+$change" : "-$change";
    }
    return Text(
      text,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: !isTicker
              ? Colors.black
              : isGreen!
                  ? Colors.green[900]
                  : Colors.red[800]),
      maxLines: 1,
    );
  }

  static Widget quickAction(
          {required Widget icon,
          required String text,
          required void Function()? onPressed,
          bool whiteBG = false}) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteBG
                    ? appColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.2)),
            child: IconButton(
              onPressed: onPressed,
              icon: icon,
              iconSize: 28,
              color: whiteBG ? appColor : Colors.white,
            ),
          ),
          Text(
            text,
            style: TextStyle(
                color: whiteBG ? appColor : Colors.white, fontSize: 13),
          )
        ],
      );

  static Widget dAppsCarousel(BuildContext context,
      {required String title, required List<DAppsTile> data}) {
    List<Widget> widgets = [];

    Widget listItem(DAppsTile item) => ListTile(
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          leading: item.image,
          onTap: () {
            Get.to(() => WebViewPage(url: item.url));
          },
        );

    for (var i = 0; i < data.length; i = i + 3) {
      widgets.add(
        SizedBox(
          width: Get.width * 0.85,
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemExtent: Get.height * 0.08,
            children: [
              listItem(data[i]),
              i + 1 >= data.length ? Container() : listItem(data[i + 1]),
              i + 2 >= data.length ? Container() : listItem(data[i + 2]),
            ],
          ),
        ),
      );
    }

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 21),
                ),
                TextButton(
                    onPressed: () {
                      pushNewScreen(context,
                          screen: SeeAllPage(title: title, data: data));
                    },
                    child: Text("See All"))
              ],
            ),
          ),
          SizedBox(
            height: Get.height * 0.08 * 3,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widgets,
            ),
          )
        ],
      ),
    );
  }

  static Widget financeList(BuildContext context,
      {required String title, required List<CoinData> data}) {
    List<Widget> widgets = [];
    final BalanceData balanceData = Get.find();
    final balanceInfo = balanceData.getData();

    Widget listItem(CoinData item) => ListTile(
          title: Text("${item.name} (${item.unit})"),
          leading: FlutterLogo(),
          onTap: () {
            Get.to(() => CoinPage(coinData: item, balance: balanceInfo[item]!));
          },
        );

    for (var i = 0; i < (data.length > 3 ? 3 : data.length); i++) {
      widgets.add(
        SizedBox(
          // width: Get.width * 0.85,
          child: listItem(data[i]),
        ),
      );
    }

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                    onPressed: () {
                      pushNewScreen(context,
                          screen: MorePage(title: title, data: data));
                    },
                    child: Text("MORE"))
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: widgets,
          )
        ],
      ),
    );
  }

  static Widget settingsTileIcon({required Widget icon, required Color color}) {
    return Theme(
      data: Get.theme.copyWith(iconTheme: IconThemeData(color: Colors.white)),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: color,
        ),
        child: icon,
      ),
    );
  }
}
