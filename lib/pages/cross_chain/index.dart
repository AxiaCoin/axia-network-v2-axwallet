import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/currencies/axiacoin.dart';
import 'package:wallet/pages/device_auth.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/number_keyboard.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/spinner.dart';

class CrossChainPage extends StatefulWidget {
  const CrossChainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CrossChainPage> createState() => _CrossChainPageState();
}

enum Chain {
  X,
  P,
  C,
}

class _CrossChainPageState extends State<CrossChainPage> {
  final formKey = GlobalKey<FormState>();
  var api = services.axSDK.api!;
  TextEditingController amountController = new TextEditingController();
  late Currency currency;
  FocusNode amountFocus = new FocusNode();
  bool numPadVisibility = false;
  bool autoValidate = false;
  final BalanceData balanceData = Get.find();
  final AXCWalletData axcWalletData = Get.find();
  // String sourceController = "X Chain";
  // String destController = "P Chain";
  Chain source = Chain.X;
  Chain dest = Chain.P;
  double cExFee = 0.001;
  double cImFee = 0.001;
  late Map<Chain, double> exportFees;
  late Map<Chain, double> importFees;
  late Map<Chain, String?> balances;
  List<DropdownMenuItem<Chain>> get dropdownItems {
    List<DropdownMenuItem<Chain>> menuItems = [
      DropdownMenuItem(child: Text("X Chain"), value: Chain.X),
      DropdownMenuItem(child: Text("P Chain"), value: Chain.P),
      DropdownMenuItem(child: Text("C Chain"), value: Chain.C),
    ];
    return menuItems;
  }

  double? calculateMax() {
    double? bal = getSourceBalance();
    if (bal == null) return null;
    return bal - totalFees();
  }

  totalFees() {
    return exportFees[source]! + importFees[dest]!;
  }

  double? getSourceBalance() {
    var balances = axcWalletData.balance.value;
    if (balances.X == null) return null;
    double bal = double.parse(source == Chain.X
        ? balances.X!
        : source == Chain.P
            ? balances.P!
            : balances.C!);
    return bal;
  }

  transfer() async {
    if (formKey.currentState!.validate()) {
      var data = await Get.to(() => DeviceAuthPage());
      if (data != null && data == true) {
        CommonWidgets.waitDialog(text: "Transferring tokens");
        await Future.delayed(Duration(milliseconds: 200));
        try {
          print("Transfer started");
          // add import fees for destination chain
          int amount =
              ((double.parse(amountController.text) + importFees[dest]!) *
                      pow(10, denomination))
                  .toInt();
          print(amount);
          var response = await api.transfer.crossChain(
            from: source.name,
            to: dest.name,
            amount: amount.toString(),
          );
          print("Send response:$response");
          await Future.delayed(Duration(milliseconds: 200));
          if (response != null && response["exportID"] != null) {
            print("success");
            Get.back();
            services.getAXCWalletDetails();
            amountController.clear();
            autoValidate = false;
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

  updateFees() async {
    var data = await Future.wait([
      api.transfer.getFee(chainID: "C", isExport: true),
      api.transfer.getFee(chainID: "C", isExport: false)
    ]);
    print(data);
    print(data[0]);
    print(data[0].runtimeType);
    cExFee = double.parse(data[0]);
    cImFee = double.parse(data[1]);
    exportFees = {Chain.X: 0.001, Chain.P: 0.001, Chain.C: cExFee};
    importFees = {Chain.X: 0.001, Chain.P: 0.001, Chain.C: cImFee};
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    currency = AXIACoin();
    exportFees = {Chain.X: 0.001, Chain.P: 0.001, Chain.C: cExFee};
    importFees = {Chain.X: 0.001, Chain.P: 0.001, Chain.C: cImFee};
    var bal = axcWalletData.balance.value;
    balances = {Chain.X: bal.X, Chain.P: bal.P, Chain.C: bal.C};
    updateFees();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Cross Chain"),
          centerTitle: true,
        );

    Widget amountSuffixWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // amountController.text =
                //     FormatText.roundOff((balanceData.data![currency])!);
                amountController.text = calculateMax().toString();
              },
              child: Text("MAX"),
            ),
          ],
        );

    Widget sourceWidget() => DropdownButtonFormField<Chain>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          filled: false,
        ),
        value: source,
        onChanged: (Chain? newValue) {
          if (newValue == dest) {
            var eligible = dropdownItems
                .where((element) => element.value != newValue)
                .toList();
            dest = eligible.first.value!;
          }
          setState(() {
            source = newValue!;
          });
          double max = calculateMax() ?? 0;
          if (amountController.text != "" &&
              double.parse(amountController.text) > max) {
            amountController.text = max.toString();
          }
        },
        items: dropdownItems);

    Widget destWidget() => DropdownButtonFormField<Chain>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          filled: false,
        ),
        value: dest,
        onChanged: (Chain? newValue) {
          setState(() {
            dest = newValue!;
          });
          double max = calculateMax() ?? 0;
          if (amountController.text != "" &&
              double.parse(amountController.text) > max) {
            amountController.text = max.toString();
          }
        },
        items:
            dropdownItems.where((element) => element.value != source).toList());

    Widget feeWidget() => Container(
          padding: EdgeInsets.all(8),
          width: Get.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            // border: Border.all(color: Colors.grey.withOpacity(0.7)),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "Fee",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Export Fee",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "${exportFees[source]} AXC",
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Import Fee",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "${importFees[dest]} AXC",
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${FormatText.roundOff(totalFees(), maxDecimals: 12)} AXC",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ],
          ),
        );

    Widget sourceDestContainer() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: Get.width * 0.4,
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: Colors.grey[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Source",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(source.name,
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w400)),
                          ),
                          Text(
                              source == Chain.X
                                  ? "Exchange Chain"
                                  : source == Chain.P
                                      ? "Platform Chain"
                                      : "Contract Chain",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("Balance",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        Obx(
                          () => axcWalletData.balance.value.X == null
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Spinner(
                                    alt: true,
                                  ),
                                )
                              : Text((source == Chain.X
                                      ? axcWalletData.balance.value.X
                                      : source == Chain.P
                                          ? axcWalletData.balance.value.P
                                          : axcWalletData.balance.value.C) ??
                                  "~"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                width: Get.width * 0.4,
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  color: Colors.grey[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Destination",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(dest.name,
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w400)),
                          ),
                          Text(
                              dest == Chain.X
                                  ? "Exchange Chain"
                                  : dest == Chain.P
                                      ? "Platform Chain"
                                      : "Contract Chain",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("Balance",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        Obx(
                          () => axcWalletData.balance.value.X == null
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Spinner(
                                    alt: true,
                                  ),
                                )
                              : Text((dest == Chain.X
                                      ? axcWalletData.balance.value.X
                                      : dest == Chain.P
                                          ? axcWalletData.balance.value.P
                                          : axcWalletData.balance.value.C) ??
                                  "~"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        );

    return WillPopScope(
      onWillPop: () async {
        if (numPadVisibility) {
          setState(() {
            numPadVisibility = false;
          });
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            numPadVisibility = false;
          }
        },
        child: Form(
          key: formKey,
          child: Scaffold(
            appBar: appBar(),
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.add),
            //   onPressed: () async {
            //     services.test();
            //   },
            // ),
            body: Container(
              padding: EdgeInsets.all(16),
              child: Stack(
                children: [
                  SizedBox(
                    height:
                        numPadVisibility ? Get.height * 0.5 : Get.height * 1,
                    child: ListView(
                      children: [
                        OnboardWidgets.neverShare(
                            text:
                                "Transfer tokens between Exchange (X) , Platform (P) and Contract (C) chains."),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Source Chain")),
                        SizedBox(height: 8),
                        sourceWidget(),
                        SizedBox(height: 8),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Destination Chain")),
                        SizedBox(height: 8),
                        destWidget(),
                        SizedBox(height: 8),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Transfer Amount")),
                        SizedBox(height: 8),
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
                                      (getSourceBalance() == null ||
                                          double.parse(val) <
                                              getSourceBalance()!)
                                  ? null
                                  : "Amount should be lower than the balance (including fees)\nand not zero",
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
                        SizedBox(height: 8),
                        feeWidget(),
                        SizedBox(height: 8),
                        sourceDestContainer(),
                        SizedBox(height: 16),
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
                  Align(
                    alignment: Alignment.bottomCenter,
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
        ),
      ),
    );
  }
}
