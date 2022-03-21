import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceAlertsPage extends StatefulWidget {
  const PriceAlertsPage({Key? key}) : super(key: key);

  @override
  _PriceAlertsPageState createState() => _PriceAlertsPageState();
}

class _PriceAlertsPageState extends State<PriceAlertsPage> {
  @override
  Widget build(BuildContext context) {
    bool priceAlert = true;

    return Scaffold(
      appBar: AppBar(
        title: Text("Price Alerts"),
      ),
      body: Container(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              title: Text("Price Alerts"),
              value: priceAlert,
              onChanged: (val) {
                setState(
                  () {
                    priceAlert = val;
                  },
                );
              },
            ),
            Text(
              "Get alerts for significant price changes of your favorite cryptocurrencies",
              style: context.textTheme.caption,
            )
          ],
        ),
      ),
    );
  }
}
