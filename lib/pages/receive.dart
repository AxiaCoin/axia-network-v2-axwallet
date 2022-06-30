import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
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
  final formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  String amount = "";
  late Currency currency;
  late String shareableAddress;
  late CryptoWallet wallet;
  late String qrData;
  late String qrPrefix;

  copyAddress() {
    Clipboard.setData(ClipboardData(text: wallet.address));
    CommonWidgets.snackBar(wallet.address, copyMode: true);
  }

  setAmount(String value) {
    amount = FormatText.roundOff(double.parse(value));
    if (double.parse(value) != 0) {
      qrData = qrPrefix + wallet.address + "?amount=$value";
    } else {
      amount = "0";
      qrData = qrPrefix + wallet.address;
    }
    setState(() {});
  }

  shareAddress() {
    String message =
        "Hello, you can send me ${currency.coinData.name} at my wallet address- $shareableAddress}";
    Share.share(message);
  }

  getWallet() {
    wallet = currency.getWallet();
    qrPrefix = "AMW:${currency.coinData.unit}/";
    qrData = qrPrefix + wallet.address;
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
        centerTitle: true,
        leading: CommonWidgets.backButton(context),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        data: qrData,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        wallet.address,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      amount == "0" || amount == ""
                          ? Container()
                          : Text(
                              amount + " ${currency.coinData.unit}",
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
            SizedBox(
              height: 16,
            ),
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
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: HomeWidgets.quickAction(
                      icon: "assets/icons/copy.svg",
                      text: "Copy",
                      onPressed: copyAddress,
                      whiteBG: true),
                ),
                Expanded(
                  child: HomeWidgets.quickAction(
                      icon: "assets/icons/tag.svg",
                      text: "Set Amount",
                      onPressed: () async {
                        Widget dialog = AlertDialog(
                          title: Text("Enter Amount"),
                          content: Form(
                            key: formKey,
                            child: TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: InputFormatters.amountFilter(),
                              decoration: InputDecoration(
                                hintText: "0.1",
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                              ),
                              validator: (val) => val != null &&
                                      val.isNotEmpty &&
                                      val != "."
                                  ? null
                                  : "Amount should be lower than the balance (including fees)",
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pop(
                                        context, amountController.text);
                                  }
                                },
                                child: Text("Set"))
                          ],
                        );
                        var data = await Get.dialog(dialog);
                        if (data != null) {
                          setAmount(amountController.text);
                        }
                      },
                      whiteBG: true),
                ),
                Expanded(
                  child: HomeWidgets.quickAction(
                      icon:
                          "assets/icons/share_${Platform.isAndroid ? "android" : "ios"}.svg",
                      text: "Share",
                      onPressed: shareAddress,
                      whiteBG: true),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
