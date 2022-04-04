import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/pages/qr_scan.dart';
import 'package:wallet/widgets/number_keyboard.dart';

class SendPage extends StatefulWidget {
  final Currency currency;
  final double balance;
  const SendPage({Key? key, required this.currency, required this.balance})
      : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  late Currency currency;
  TextEditingController recipientController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();
  bool isCurrencyMode = false;
  FocusNode amountFocus = new FocusNode();
  bool numPadVisibility = false;

  updateFields(String result) {
    String? address;
    String? amount;
    if (result.contains(":")) {
      var data = result.split(":").last.split("?amount=");
      address = data.first;
      amount = data.last;
      recipientController.text = address;
      amountController.text = amount;
    } else {
      recipientController.text = result;
    }
  }

  @override
  void dispose() {
    amountFocus.dispose();
    recipientController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currency = widget.currency;
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          //brightness: Brightness.dark,
          title: Text("Send ${currency.coinData.name}"),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () {},
                child: Text(
                  "CONTINUE",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        );

    Widget recipientSuffixWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  Get.to(() => QRScanPage())!
                      .then((value) => updateFields(value));
                },
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: appColor,
                )),
            TextButton(
                onPressed: () async {
                  ClipboardData? data = await Clipboard.getData('text/plain');
                  setState(
                    () {
                      recipientController.text = data!.text!;
                    },
                  );
                },
                child: Text("PASTE"))
          ],
        );

    Widget amountSuffixWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isCurrencyMode
                ? Container()
                : TextButton(
                    onPressed: () {
                      amountController.text = widget.balance.toString();
                    },
                    child: Text("MAX"),
                  ),
            TextButton(
                onPressed: () {
                  amountController.clear();
                  setState(
                    () {
                      isCurrencyMode = !isCurrencyMode;
                    },
                  );
                },
                child: Text(isCurrencyMode ? "USD" : currency.coinData.unit))
          ],
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        if (numPadVisibility)
          setState(
            () {
              numPadVisibility = false;
            },
          );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        body: Container(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    controller: recipientController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (val) {
                      amountFocus.requestFocus();
                    },
                    decoration: InputDecoration(
                        labelText: "Recipient Address",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.fromLTRB(18, 18, Get.width * 0.25, 18)),
                    onTap: () {
                      if (numPadVisibility)
                        setState(
                          () {
                            numPadVisibility = false;
                          },
                        );
                    },
                  ),
                  recipientSuffixWidget()
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    controller: amountController,
                    focusNode: amountFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                    ],
                    readOnly: true,
                    showCursor: true,
                    decoration: InputDecoration(
                      labelText: "Amount " +
                          "(" +
                          (isCurrencyMode ? "USD" : currency.coinData.unit) +
                          ")",
                      border: OutlineInputBorder(),
                    ),
                    onTap: () {
                      if (!numPadVisibility)
                        setState(
                          () {
                            numPadVisibility = true;
                          },
                        );
                    },
                  ),
                  amountSuffixWidget()
                ],
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "Balance: ${widget.balance} ${currency.coinData.unit}",
                    style: context.textTheme.caption,
                    textAlign: TextAlign.start,
                  )),
              Spacer(),
              Visibility(
                visible: numPadVisibility,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: NumberKeyboard(controller: amountController),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
