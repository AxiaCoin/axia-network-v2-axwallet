import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/currencies/ethereum.dart';
import 'package:wallet/pages/device_auth.dart';
import 'package:wallet/widgets/address_textfield.dart';
import 'package:wallet/widgets/amount_suffix.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/plugin_widgets.dart';
import 'package:wallet/widgets/spinner.dart';

class SameChainTransfer extends StatefulWidget {
  const SameChainTransfer({Key? key}) : super(key: key);

  @override
  State<SameChainTransfer> createState() => _SameChainTransferState();
}

class _SameChainTransferState extends State<SameChainTransfer> {
  final formKey = GlobalKey<FormState>();
  var api = services.axSDK.api!;
  int slidingIndex = 0;
  TextEditingController amountController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController memoController = new TextEditingController();
  late Currency currency;
  FocusNode amountFocus = new FocusNode();
  bool autoValidate = false;
  final AXCWalletData axcWalletData = Get.find();
  // String sourceController = "X Chain";
  // String destController = "P Chain";
  Chain source = Chain.Swap;
  double cFee = 0.001;
  int gasPrice = 25;
  int gasLimit = 21000;
  late Map<Chain, double> fees;
  late Map<Chain, String?> balances;
  List<DropdownMenuItem<Chain>> get dropdownItems {
    List<DropdownMenuItem<Chain>> menuItems = [
      DropdownMenuItem(child: Text("Swap-Chain"), value: Chain.Swap),
      DropdownMenuItem(child: Text("AX-Chain"), value: Chain.AX),
    ];
    return menuItems;
  }

  getFees() async {
    var data = await api.transfer.getAdjustedGasPrice();
    if (data != null) {
      double gWei = double.parse(data) * pow(10, denomination);
      fees[Chain.AX] = (gWei * gasLimit) / pow(10, denomination);
      if (mounted) setState(() => gasPrice = gWei.toInt());
    }
  }

  double? calculateMax() {
    double? bal = getSourceBalance();
    if (bal == null) return null;
    return bal - fees[source]!;
  }

  double? getSourceBalance() {
    var balances = axcWalletData.balance.value;
    if (balances.swap == null) return null;
    double bal = double.parse(source == Chain.Swap
        ? balances.swap!
        : source == Chain.Core
            ? balances.core!
            : balances.ax!);
    return bal;
  }

  transfer() async {
    if (formKey.currentState!.validate()) {
      bool isValid =
          await Utils.validateAddress(source, addressController.text);
      if (!isValid) {
        CommonWidgets.snackBar(
            "Please check if the chain and address are correct for the network!");
        return;
      }
      var data = await Get.to(() => DeviceAuthPage());
      if (data != null && data == true) {
        CommonWidgets.waitDialog(text: "Transferring tokens");
        await Future.delayed(Duration(milliseconds: 200));
        try {
          print("Transfer started");
          // BigInt amount = BigInt.from(double.parse(amountController.text) *
          //     pow(10, source == Chain.Swap ? denomination : 18));
          print("sending amount = ${amountController.text}");
          var response = await api.transfer.sameChain(
            chain: source.name,
            to: addressController.text.trim(),
            amount: amountController.text,
            memo: memoController.text,
          );
          print("Send response:$response");
          await Future.delayed(Duration(milliseconds: 200));
          if (response != null && response is Map && response["txID"] != null) {
            print("success");
            Get.back();
            services.getAXCWalletDetails();
            setState(() {
              amountController.clear();
              addressController.clear();
              memoController.clear();
              autoValidate = false;
            });
            CommonWidgets.snackBar("The transfer was successfull", duration: 5);
          } else {
            Get.back();
            CommonWidgets.snackBar(response, duration: 5);
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
  void initState() {
    super.initState();
    fees = {
      Chain.Swap: 0.001,
      Chain.Core: 0.001,
      Chain.AX: (gasPrice * gasLimit) / pow(10, denomination),
    };
    getFees();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Send AXC"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );

    Widget sourceWidget() => CupertinoSlidingSegmentedControl<int>(
          children: {
            0: HomeWidgets.segmentedText("Swap-Chain"),
            1: HomeWidgets.segmentedText("AX-Chain"),
          },
          groupValue: slidingIndex,
          onValueChanged: (int? val) {
            if (val == null) return;
            setState(() {
              source = val == 0 ? Chain.Swap : Chain.AX;
              slidingIndex = val;
            });
            double max = calculateMax() ?? 0;
            if (amountController.text != "" &&
                double.parse(amountController.text) > max) {
              amountController.text = max.toString();
            }
          },
          backgroundColor: Colors.black.withOpacity(0.2),
          thumbColor: appColor,
        );

    Widget feeWidget() => Container(
          padding: EdgeInsets.all(8),
          width: Get.width,
          // height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            // border: Border.all(color: Colors.grey.withOpacity(0.7)),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              // Expanded(
              //   child: Row(
              //     children: [
              //       Text(
              //         "Fee",
              //         style:
              //             TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              //       )
              //     ],
              //   ),
              // ),
              source == Chain.AX
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Estimated Gas Price",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "$gasPrice GWEI",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    )
                  : Container(),
              source == Chain.AX
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Gas Limit",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "$gasLimit",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    )
                  : SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transaction Fee",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "${fees[source]} AXC",
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Total",
              //       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              //     ),
              //     Text(
              //       "${FormatText.roundOff(totalFees(), maxDecimals: 12)} AXC",
              //       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              //     )
              //   ],
              // ),
            ],
          ),
        );

    Widget memoWidget() {
      return Container(
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Memo (optional)",
                  style: Theme.of(context).textTheme.subtitle2,
                )),
            SizedBox(height: 8),
            TextFormField(
              controller: memoController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Memo",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
              minLines: 3,
              maxLines: 6,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Form(
        key: formKey,
        child: Scaffold(
          appBar: appBar(),
          // floatingActionButton: kDebugMode
          //     ? FloatingActionButton(
          //         child: Icon(Icons.add),
          //         onPressed: () async {
          //           bool isValid = await api.utils
          //               .checkAddrValidity(address: addressController.text);
          //           print(isValid ? "is valid" : "is not valid");
          //         },
          //       )
          //     : null,
          body: Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: ListView(
              children: [
                PluginWidgets.indexTitle(
                    "Transfer tokens to other wallets in Swap and AX chains."),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Source Chain",
                      style: Theme.of(context).textTheme.subtitle2,
                    )),
                SizedBox(height: 8),
                sourceWidget(),
                SizedBox(height: 8),
                // Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text("Destination Chain")),
                // SizedBox(height: 8),
                // destWidget(),
                // SizedBox(height: 8),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Transfer Amount",
                      style: Theme.of(context).textTheme.subtitle2,
                    )),
                SizedBox(height: 8),
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
                        // errorMaxLines: 2,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ),
                      validator: (val) => val != null &&
                              val.isNotEmpty &&
                              val != "." &&
                              double.parse(val) != 0 &&
                              (getSourceBalance() == null ||
                                  double.parse(val) <= calculateMax()!)
                          ? null
                          : "Amount should be lower than the balance (including fees) and not zero",
                      autovalidateMode: autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (_) {
                        setState(() => autoValidate = true);
                      },
                      onTap: () {
                        if (getSourceBalance() == null) {
                          CommonWidgets.snackBar(
                              "Wait for the wallet/balances to load before proceeding");
                          return;
                        }
                      },
                    ),
                    AmountSuffix(
                      controller: amountController,
                      maxAmount: calculateMax(),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 4),
                    child: Obx(
                      () => axcWalletData.balance.value.core == null
                          ? Row(
                              children: [
                                Text(
                                  "Balance: ",
                                  style: context.textTheme.caption,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(
                                  // width: 20,
                                  // height: 20,
                                  child: Spinner(
                                    alt: true,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Balance: ${getSourceBalance()} AXC",
                              style: context.textTheme.caption,
                              textAlign: TextAlign.start,
                            ),
                    )),
                SizedBox(height: 8),
                // Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       "Destination Address",
                //       style: Theme.of(context).textTheme.subtitle2,
                //     )),
                // SizedBox(height: 8),
                AddressTextField(
                  controller: addressController,
                  amountController: amountController,
                  title: "Destination Address",
                  autoValidate: autoValidate,
                ),
                SizedBox(height: 8),
                source == Chain.Swap ? memoWidget() : Container(),
                SizedBox(height: 8),
                feeWidget(),
                SizedBox(height: 8),
                SizedBox(
                  width: Get.width,
                  child: TextButton(
                      style: MyButtonStyles.onboardStyle,
                      onPressed: () {
                        transfer();
                      },
                      child: Text(
                        "Transfer",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
