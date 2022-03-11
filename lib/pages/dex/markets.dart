import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/utils.dart';

class MarketsPage extends StatefulWidget {
  const MarketsPage({Key? key}) : super(key: key);

  @override
  _MarketsPageState createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage> {
  final TokenData tokenData = Get.find();

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: TextField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
                hintText: "Search Markets",
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none),
          ),
        );

    Widget trailingWidget(double rand) {
      bool isRed = rand < 0.5;
      Color color = isRed ? tickerRed : tickerGreen;
      String text = isRed
          ? "-${FormatText.roundOff(rand * 10 + 5, maxDecimals: 2)}%"
          : "+${FormatText.roundOff(rand * 20 + 7, maxDecimals: 2)}%";
      return Container(
        width: Get.width * 0.15,
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: color.withOpacity(0.2)),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scaffold(
      appBar: appBar(),
      body: Container(
        padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 12),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: 20,
          itemBuilder: (context, index) {
            if (index == 0) return Text("XCN0");
            var rand = Random().nextDouble();
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FlutterLogo(),
                      Text("XCN$index / XCN0"),
                    ],
                  ),
                  Text(FormatText.roundOff(rand, maxDecimals: 8)),
                  trailingWidget(rand)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
