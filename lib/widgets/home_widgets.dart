import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
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
            fontSize: 16, fontWeight: FontWeight.w300, color: appColor),
        maxLines: 1,
      );

  static Widget coinPageHeaderText(String text, {bool isTicker = false}) {
    bool? isGreen;
    if (isTicker) {
      double change = double.parse(text);
      isGreen = change > 0;
      text = isGreen ? "+$change%" : "-$change%";
    }
    return Text(
      text,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: !isTicker
              ? Colors.black
              : isGreen!
                  ? tickerGreen
                  : tickerRed),
      maxLines: 1,
    );
  }

  static Widget quickAction(
          {required String icon,
          String? text,
          required void Function()? onPressed,
          bool whiteBG = false}) =>
      GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: text != null ? EdgeInsets.all(16) : null,
          margin: text != null ? EdgeInsets.all(4) : null,
          decoration: text != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  color: Colors.grey[50],
                )
              : null,
          child: Column(
            children: [
              SvgPicture.asset(
                icon,
                color: whiteBG ? appColor : Colors.white,
                width: 24,
                height: 24,
              ),
              text != null
                  ? Text(
                      text,
                      style: TextStyle(color: appColor),
                    )
                  : Container(),
            ],
          ),
        ),
      );

  static Widget roundedButton({
    required Function() onPressed,
    required Widget icon,
    required String label,
    Color? color,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: color ?? appColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
      onPressed: onPressed,
      icon: icon,
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  static Widget dAppsTitle({required String title, required bool selected}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        color: selected ? appColor : Colors.transparent,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  static Widget dAppsList(BuildContext context, {required DAppsTile data}) {
    // List<Widget> widgets = [];

    Widget listItem(DAppsTile item) => ListTile(
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          leading: item.image ?? FlutterLogo(),
          onTap: () {
            Get.to(() => WebViewPage(url: item.url));
          },
        );
    return listItem(data);
    // for (var i = 0; i < data.length; i = i + 3) {
    //   widgets.add(
    //     SizedBox(
    //       width: Get.width * 0.85,
    //       child: ListView(
    //         shrinkWrap: true,
    //         physics: NeverScrollableScrollPhysics(),
    //         itemExtent: Get.height * 0.08,
    //         children: [
    //           listItem(data[i]),
    //           i + 1 >= data.length ? Container() : listItem(data[i + 1]),
    //           i + 2 >= data.length ? Container() : listItem(data[i + 2]),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // return Container(
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       // Container(
    //       //   padding: const EdgeInsets.all(8.0),
    //       //   child: Row(
    //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       //     children: [
    //       //       Text(
    //       //         title,
    //       //         style: TextStyle(fontSize: 21),
    //       //       ),
    //       //       TextButton(
    //       //           onPressed: () {
    //       //             pushNewScreen(context,
    //       //                 screen: SeeAllPage(title: title, data: data));
    //       //           },
    //       //           child: Text("See All"))
    //       //     ],
    //       //   ),
    //       // ),
    //       SizedBox(
    //         height: Get.height * 0.08 * 3,
    //         child: ListView.builder(
    //           // scrollDirection: Axis.horizontal,
    //           // children: widgets,
    //           itemCount: data.length,
    //           itemBuilder: (context, index) {
    //             return listItem(data[index]);
    //           },
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  static Widget financeList(BuildContext context,
      {required String title, required List<Currency> data}) {
    List<Widget> widgets = [];
    final BalanceData balanceData = Get.find();
    final balanceInfo = balanceData.getData();

    Widget listItem(Currency item) => ListTile(
          title: Text("${item.coinData.name} (${item.coinData.unit})"),
          leading: FlutterLogo(),
          onTap: () {
            Get.to(() => CoinPage(currency: item, balance: balanceInfo[item]!));
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

  static Widget coinTile({
    required String unit,
    required String balance,
    required String name,
    String? value,
    String? rate,
    String? ticker,
    required Function() onTap,
  }) {
    List tickerColor = [Color(0xff35B994), Color(0xffF12F2F)];
    var rand = Random().nextInt(2);
    return ListTile(
      leading: Image.asset(
        "assets/currencies/$unit.png",
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            balance,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value ?? "",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: rate != null
          ? Text.rich(
              TextSpan(
                text: rate,
                children: [
                  TextSpan(
                      text: ticker, style: TextStyle(color: tickerColor[rand]))
                ],
              ),
            )
          : Text(unit),
      onTap: onTap,
    );
  }
}
