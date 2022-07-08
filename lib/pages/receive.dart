import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';

class ReceivePage extends StatefulWidget {
  final Currency? currency;
  final Chain? chain;
  const ReceivePage({
    Key? key,
    this.currency,
    this.chain,
  }) : super(key: key);

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  AXCWalletData axcWalletData = Get.find();
  final formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  String amount = "";
  Currency? currency;
  late Chain chain;
  Map<Chain, String> axWallet = {};
  late String shareableAddress;
  CryptoWallet? wallet;
  late String qrData;
  late String qrPrefix;
  int slidingIndex = 0;

  copyAddress() {
    Clipboard.setData(ClipboardData(text: shareableAddress));
    CommonWidgets.snackBar(shareableAddress, copyMode: true);
  }

  setAmount(String value) {
    amount = FormatText.roundOff(double.parse(value));
    if (double.parse(value) != 0) {
      qrData = qrPrefix + shareableAddress + "?amount=$value";
    } else {
      amount = "0";
      qrData = qrPrefix + shareableAddress;
    }
    setState(() {});
  }

  shareAddress() {
    String message =
        "Hello, you can send me ${currency == null ? "AXC" : currency!.coinData.name} at my wallet address- $shareableAddress}";
    Share.share(message);
  }

  getWallet() {
    var walletData = axcWalletData.wallet.value;
    if (currency == null) {
      axWallet = {
        Chain.Swap: walletData.swap!,
        Chain.Core: walletData.core!,
        Chain.AX: walletData.ax!,
      };
      slidingIndex = chain == Chain.Swap
          ? 0
          : chain == Chain.Core
              ? 1
              : 2;
      qrPrefix = "AMW:AXC-${chain.name}/";
      qrData =
          qrPrefix + axWallet[chain]! + (amount != "" ? "?amount=$amount" : "");
      shareableAddress = axWallet[chain]!;
      return;
    }
    wallet = currency!.getWallet();
    qrPrefix = "AMW:${currency!.coinData.unit}/";
    qrData = qrPrefix + wallet!.address;
    shareableAddress = wallet!.address;
  }

  @override
  void initState() {
    super.initState();
    currency = widget.currency;
    chain = widget.chain ?? Chain.Swap;
    getWallet();
  }

  @override
  Widget build(BuildContext context) {
    Widget chainWidget() => Container(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            children: {
              0: HomeWidgets.segmentedText("Swap-Chain"),
              1: HomeWidgets.segmentedText("Core-Chain"),
              2: HomeWidgets.segmentedText("AX-Chain"),
            },
            groupValue: slidingIndex,
            onValueChanged: (int? val) {
              if (val == null) return;
              setState(() {
                chain = val == 0
                    ? Chain.Swap
                    : val == 1
                        ? Chain.Core
                        : Chain.AX;
                slidingIndex = val;
              });
              getWallet();
            },
            backgroundColor: Colors.black.withOpacity(0.2),
            thumbColor: appColor,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Receive ${currency == null ? "AXC" : currency!.coinData.name}"),
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
            currency == null ? chainWidget() : Container(),
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
                        shareableAddress,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      amount == "0" || amount == ""
                          ? Container()
                          : Text(
                              amount +
                                  " ${currency == null ? "AXC" : currency!.coinData.name}",
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
                    text:
                        "${currency == null ? "AXIA" : currency!.coinData.name} ",
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
                              validator: (val) =>
                                  val != null && val.isNotEmpty && val != "."
                                      ? null
                                      : "Amount should be a valid number",
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
