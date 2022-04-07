import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:share_plus/share_plus.dart';

class ReceivePage extends StatefulWidget {
  final Currency currency;
  const ReceivePage({Key? key, required this.currency}) : super(key: key);

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  late Currency currency;
  late String shareableAddress;
  late CryptoWallet wallet;

  copyAddress() {
    Clipboard.setData(ClipboardData(text: wallet.address));
    CommonWidgets.snackBar(wallet.address, copyMode: true);
  }

  setAmount() {}

  shareAddress() {
    String message =
        "Hello, you can send me ${currency.coinData.name} at my wallet address- $shareableAddress}";
    Share.share(message);
  }

  getWallet() {
    wallet = currency.getWallet();
  }

  @override
  void initState() {
    super.initState();
    currency = widget.currency;
    getWallet();
    shareableAddress = wallet.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receive ${currency.coinData.name}"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Container(padding: EdgeInsets.only(top: Get.width * 0.15), child: OnboardWidgets.title("QR Code")),
          // Spacer(),
          Container(
            padding: EdgeInsets.only(
                left: Get.width * 0.15,
                right: Get.width * 0.15,
                top: Get.width * 0.1),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 4,
              // margin: EdgeInsets.all(Get.width * 0.05),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImage(
                      data: wallet.address,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      wallet.address,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
          // Spacer(),
          Text.rich(
            TextSpan(text: "Send only ", children: [
              TextSpan(
                  text: "${currency.coinData.name} ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      "to this address.\nSending any other coins may result in permanent loss")
            ]),
            style: TextStyle(color: Colors.black54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeWidgets.quickAction(
                  icon: Icon(Icons.copy),
                  text: "Copy",
                  onPressed: copyAddress,
                  whiteBG: true),
              HomeWidgets.quickAction(
                  icon: Icon(Icons.local_offer_outlined),
                  text: "Set Amount",
                  onPressed: () {},
                  whiteBG: true),
              HomeWidgets.quickAction(
                  icon: Icon(Icons.adaptive.share),
                  text: "Share",
                  onPressed: shareAddress,
                  whiteBG: true)
            ],
          )
        ],
      ),
    );
  }
}
