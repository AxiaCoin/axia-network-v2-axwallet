import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/device_auth.dart';
import 'package:wallet/pages/qr_scan.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/number_keyboard.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class SendPage extends StatefulWidget {
  final Currency currency;
  const SendPage({Key? key, required this.currency}) : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final formKey = GlobalKey<FormState>();
  late Currency currency;
  TextEditingController recipientController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();
  bool isCurrencyMode = false;
  FocusNode amountFocus = new FocusNode();
  bool numPadVisibility = false;
  final BalanceData balanceData = Get.find();

  updateFields(String result) {
    String? address;
    String? amount;
    if (result.contains(":")) {
      var data = result.split("/").last.split("?amount=");
      address = data.first;
      amount = data.length > 1 ? data.last : null;
      recipientController.text = address;
      if (amount != null) amountController.text = amount;
    } else {
      recipientController.text = result;
    }
  }

  onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      var data = await Get.to(() => DeviceAuthPage());
      if (data != null && data == true) {
        CommonWidgets.waitDialog(text: "Sending tokens");
        await Future.delayed(Duration(milliseconds: 200));
        try {
          print("Transaction started");
          var response = await currency.sendTransaction(
              double.parse(amountController.text),
              recipientController.text.trim());
          print("Send response:$response");
          await Future.delayed(Duration(milliseconds: 200));
          if (response != null && response["success"] == true) {
            print("success");
            Navigator.pop(context);
            Get.back(result: true);
          }
          if (response["success"] == false) {
            print("failure");
            Navigator.pop(context);
            CommonWidgets.snackBar(response["errors"], duration: 5);
          }
        } catch (e) {
          print("caugt error");
          Get.back();
          print(e);
          CommonWidgets.snackBar(e.toString(), duration: 5);
        }
      } else {
        CommonWidgets.snackBar("Failed to authenticate transaction, try again",
            duration: 5);
      }
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
          leading: CommonWidgets.backButton(context),
          // actions: [
          //   TextButton(
          //       onPressed: onSubmit,
          //       child: Text(
          //         "CONTINUE",
          //         style: TextStyle(color: Colors.white),
          //       ))
          // ],
        );

    Widget recipientSuffixWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  Get.to(() => QRScanPage())!.then((value) {
                    if (value != null) updateFields(value);
                  });
                },
                icon: SvgPicture.asset(
                  "assets/icons/qr.svg",
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
                      amountController.text =
                          FormatText.roundOff((balanceData.data![currency])!);
                    },
                    child: Text("MAX"),
                  ),
            // TextButton(
            //     onPressed: () {
            //       amountController.clear();
            //       setState(
            //         () {
            //           isCurrencyMode = !isCurrencyMode;
            //         },
            //       );
            //     },
            //     child: Text(isCurrencyMode ? "USD" : currency.coinData.unit))
          ],
        );

    return Form(
      key: formKey,
      child: GestureDetector(
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
          body: Column(
            children: [
              Container(
                height: numPadVisibility
                    ? (Get.height * 0.6 - 10)
                    : Get.height - 90,
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Recipient Address")),
                      SizedBox(
                        height: 8,
                      ),
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
                                hintText: FormatText.address(
                                    currency.getWallet().address,
                                    pad: 6),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                contentPadding: EdgeInsets.fromLTRB(
                                    18, 18, Get.width * 0.25, 18)),
                            validator: (val) => val != null && val.isNotEmpty
                                ? null
                                : "Please enter an address",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Amount " +
                              "(" +
                              (isCurrencyMode
                                  ? "USD"
                                  : currency.coinData.unit) +
                              ")")),
                      SizedBox(
                        height: 8,
                      ),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: amountController,
                            focusNode: amountFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*$'))
                            ],
                            readOnly: true,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: "0.1",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            ),
                            validator: (val) => val != null &&
                                    val.isNotEmpty &&
                                    val != "." &&
                                    double.parse(val) != 0 &&
                                    double.parse(val) <
                                        balanceData.data![currency]!
                                ? null
                                : "Amount should be lower than the balance (including fees)\nand not zero",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                          child: Obx(
                            () => Text(
                              "Balance: ${FormatText.roundOff((balanceData.data![currency])!)} ${currency.coinData.unit}",
                              style: context.textTheme.caption,
                              textAlign: TextAlign.start,
                            ),
                          )),
                      SizedBox(
                        height: 16,
                      ),
                      OnboardWidgets.neverShare(
                          text:
                              "Make sure that you are sending to the correct address otherwise you may lose your funds"),
                      substrateNetworks.contains(currency.coinData.unit)
                          ? OnboardWidgets.neverShare(
                              text:
                                  "Ensure the recipient has an existential deposit of at least ${currency.coinData.existential} ${currency.coinData.unit} for a successful transaction")
                          : Container(),
                      // SizedBox(
                      //   height: 16,
                      // ),
                      SizedBox(
                        width: Get.width,
                        child: TextButton(
                            style: MyButtonStyles.onboardStyle,
                            onPressed: () => onSubmit(context),
                            child: Text(
                              "SEND",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      // Spacer(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Visibility(
                  visible: numPadVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: NumberKeyboard(controller: amountController),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
