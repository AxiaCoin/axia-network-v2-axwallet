import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/pages/dex/exchange.dart';
import 'package:wallet/pages/dex/swap.dart';
import 'package:wallet/widgets/home_widgets.dart';

class DEXPage extends StatefulWidget {
  const DEXPage({Key? key}) : super(key: key);

  @override
  _DEXPageState createState() => _DEXPageState();
}

class _DEXPageState extends State<DEXPage> {
  int slidingIndex = 0;
  PageController pageController = PageController(keepPage: false);
  List<Widget> pages = [SwapPage(), ExchangePage()];

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          centerTitle: true,
          title: SizedBox(
            width: Get.width * 0.8,
            child: CupertinoSlidingSegmentedControl<int>(
              children: {
                0: HomeWidgets.segmentedText("Swap"),
                1: HomeWidgets.segmentedText("Exchange"),
              },
              groupValue: slidingIndex,
              onValueChanged: (int? val) {
                setState(
                  () {
                    slidingIndex = val!;
                    pageController.jumpToPage(val);
                  },
                );
              },
              backgroundColor: Colors.black.withOpacity(0.2),
              thumbColor: appColor,
            ),
          ),
        );

    return Scaffold(
      appBar: appBar(),
      body: PageView(
        controller: pageController,
        children: pages,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
