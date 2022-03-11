import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/number_keyboard.dart';

class BuyPage extends StatefulWidget {
  final CoinData coinData;
  final double minimum;
  const BuyPage({Key? key, required this.coinData, required this.minimum})
      : super(key: key);

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  late CoinData coinData;
  late double minimum;
  late TextEditingController controller;
  bool isValid = true;
  bool isLower = false;
  bool isHigher = false;
  List providers = ["MoonPay", "Simplex"];
  int providerIndex = 0;

  @override
  void initState() {
    super.initState();
    coinData = widget.coinData;
    minimum = widget.minimum;
    controller = new TextEditingController(text: minimum.toStringAsFixed(0));
    controller.addListener(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String exchangeRate =
        FormatText.exchangeValue(coinData.value, 1, controller.text);
    double currentInput =
        double.parse(controller.text == "" ? "0" : controller.text);
    if (currentInput < minimum) {
      isLower = true;
      isHigher = false;
      isValid = false;
    } else if (currentInput > 20000) {
      isHigher = true;
      isLower = false;
      isValid = false;
    } else {
      isValid = true;
      isLower = false;
      isHigher = false;
    }

    AppBar appBar() => AppBar(
          //brightness: Brightness.dark,
          title: Text("Buy ${coinData.unit}"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.info_outline))
          ],
        );

    Widget provider() {
      Widget bestRate() => Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.green.withOpacity(0.2)),
          child: Text(
            "Best rate",
            style:
                context.textTheme.caption!.copyWith(color: Colors.green[900]),
          ));

      showProviders() {
        Get.bottomSheet(
          Container(
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(providers[index]),
                  leading: FlutterLogo(),
                  trailing: Container(
                    constraints: BoxConstraints(maxWidth: Get.width * 0.2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("0.123"),
                        index == 0 ? bestRate() : Container()
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      providerIndex = index;
                    });
                    Get.back();
                  },
                );
              },
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          title: Text(providers[providerIndex]),
          subtitle: Text("Third Party Provider"),
          leading: FlutterLogo(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              bestRate(),
              Icon(Icons.navigate_next),
            ],
          ),
          onTap: showProviders,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              side: BorderSide(width: 1, color: Colors.black45)),
        ),
      );
    }

    return Scaffold(
      appBar: appBar(),
      body: Container(
        child: Column(
          children: [
            Spacer(),
            Text(
              "\$${controller.text == "" ? "0" : controller.text}",
              style: context.textTheme.headline2,
              textAlign: TextAlign.center,
            ),
            Text(
              isLower
                  ? "\$$minimum Minimum Purchase"
                  : isHigher
                      ? "\$20000 Maximum Purchase"
                      : "~$exchangeRate ${coinData.unit}",
              style:
                  context.textTheme.subtitle2!.copyWith(color: Colors.black45),
            ),
            // TextField(
            //   controller: controller,
            //   autofocus: true,
            //   readOnly: true,
            //   textAlign: TextAlign.center,
            //   decoration: InputDecoration(
            //     border: InputBorder.none,
            //     prefix: Text("\$")
            //   ),
            // ),
            Spacer(),
            provider(),
            SizedBox(
              height: 8,
            ),
            NumberKeyboard(
              controller: controller,
              backgroundOpacity: 0,
            ),
            SizedBox(
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("NEXT"),
                  style: MyButtonStyles.statefulStyle(isValid),
                ))
          ],
        ),
      ),
    );
  }
}
