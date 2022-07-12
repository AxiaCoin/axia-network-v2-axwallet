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
import 'package:wallet/widgets/address_textfield.dart';
import 'package:wallet/widgets/amount_suffix.dart';
import 'package:wallet/widgets/common.dart';
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
  final BalanceData balanceData = Get.find();
  double fees = 0.0;

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

  getFees() async {
    fees = await currency.getEstimatedFees();
    if (mounted) setState(() {});
  }

  double? calculateMax() {
    if (balanceData.data != null && (balanceData.data![currency]) != null) {
      return (balanceData.data![currency])! - fees;
    }
    return null;
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
          if (response == null) return;
          if (response != null && response["success"] == true) {
            print("success");
            Navigator.pop(context);
            Get.back(result: true);
          }
          if (response["success"] == false) {
            print("failure");
            Navigator.pop(context);
            CommonWidgets.snackBar(response["errors"].toString(), duration: 5);
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
    getFees();
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

    Widget feesWidget() => Text(
          "Estimated Fees: ${fees == 0.0 ? "~" : fees}",
          style: Theme.of(context).textTheme.subtitle1,
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
                      if ((balanceData.data![currency])! - fees <= 0) {
                        return CommonWidgets.snackBar(
                            "Balance too low (after fees) to transfer");
                      }
                      amountController.text =
                          ((balanceData.data![currency])! - fees).toString();
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
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: appBar(),
          body: Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AddressTextField(
                    controller: recipientController,
                    amountController: amountController,
                  ),
                  // Stack(
                  //   alignment: Alignment.centerRight,
                  //   children: [
                  //     TextFormField(
                  //       controller: recipientController,
                  //       textInputAction: TextInputAction.next,
                  //       onFieldSubmitted: (val) {
                  //         amountFocus.requestFocus();
                  //       },
                  //       decoration: InputDecoration(
                  //           hintText: FormatText.address(
                  //               currency.getWallet().address,
                  //               pad: 6),
                  //           border: OutlineInputBorder(
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(15))),
                  //           contentPadding: EdgeInsets.fromLTRB(
                  //               18, 18, Get.width * 0.25, 18)),
                  //       validator: (val) => val != null && val.isNotEmpty
                  //           ? null
                  //           : "Please enter an address",
                  //       autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     ),
                  //     recipientSuffixWidget()
                  //   ],
                  // ),
                  SizedBox(
                    height: 16,
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Amount " +
                            "(" +
                            (isCurrencyMode ? "USD" : currency.coinData.unit) +
                            ")",
                        style: Theme.of(context).textTheme.subtitle2,
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      TextFormField(
                        controller: amountController,
                        focusNode: amountFocus,
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
                                val != "." &&
                                double.parse(val) != 0 &&
                                double.parse(val) <=
                                    balanceData.data![currency]! - fees
                            ? null
                            : "Amount should be lower than the balance (including fees) and not zero",
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      AmountSuffix(
                        controller: amountController,
                        maxAmount: calculateMax(),
                      )
                    ],
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 4),
                      child: Obx(
                        () => Text(
                          "Balance: ${FormatText.roundOff((balanceData.data![currency])!, maxDecimals: 0)} ${currency.coinData.unit}",
                          style: context.textTheme.caption,
                          textAlign: TextAlign.start,
                        ),
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  feesWidget(),
                  SizedBox(
                    height: 16,
                  ),
                  OnboardWidgets.neverShare(
                      text:
                          "Make sure that you are sending to the correct address otherwise you may lose your funds"),
                  // substrateNetworks.contains(currency.coinData.unit)
                  //     ? OnboardWidgets.neverShare(
                  //         text:
                  //             "Ensure the recipient has an existential deposit of at least ${currency.coinData.existential} ${currency.coinData.unit} for a successful transaction")
                  //     : Container(),
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
        ),
      ),
    );
  }
}
