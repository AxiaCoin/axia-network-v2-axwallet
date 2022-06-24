import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/currencies/axiacoin.dart';
import 'package:wallet/widgets/number_keyboard.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class CrossChainPage extends StatefulWidget {
  const CrossChainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CrossChainPage> createState() => _CrossChainPageState();
}

class _CrossChainPageState extends State<CrossChainPage> {
  TextEditingController amountController = new TextEditingController();
  late Currency currency;
  FocusNode amountFocus = new FocusNode();
  bool numPadVisibility = false;
  final BalanceData balanceData = Get.find();
  String sourceController = "X Chain";
  String destController = "P Chain";
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("X Chain"), value: "X Chain"),
      DropdownMenuItem(child: Text("P Chain"), value: "P Chain"),
      DropdownMenuItem(child: Text("C Chain"), value: "C Chain"),
    ];
    return menuItems;
  }

  @override
  void initState() {
    super.initState();
    currency = AXIACoin();
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
                amountController.text =
                    FormatText.roundOff((balanceData.data![currency])!);
              },
              child: Text("MAX"),
            ),
          ],
        );

    Widget sourceWidget() => DropdownButtonFormField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          filled: false,
        ),
        value: sourceController,
        onChanged: (String? newValue) {
          setState(() {
            sourceController = newValue!;
          });
        },
        items: dropdownItems);

    Widget destWidget() => DropdownButtonFormField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          filled: false,
        ),
        value: destController,
        onChanged: (String? newValue) {
          setState(() {
            destController = newValue!;
          });
        },
        items: dropdownItems);

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
                    "0.001 AXC",
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
                    "0.001 AXC",
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
                    "0.002 AXC",
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
                            child: Text(sourceController.split(' ')[0],
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w400)),
                          ),
                          Text(
                              sourceController.split(' ')[0] == 'X'
                                  ? "Exchange Chain"
                                  : sourceController.split(' ')[0] == 'P'
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
                        Text("0"),
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
                            child: Text(destController.split(' ')[0],
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w400)),
                          ),
                          Text(
                              destController.split(' ')[0] == 'X'
                                  ? "Exchange Chain"
                                  : destController.split(' ')[0] == 'P'
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
                        Text("0"),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          numPadVisibility = false;
        }
      },
      child: Scaffold(
        appBar: appBar(),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              ListView(
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
                                double.parse(val) < balanceData.data![currency]!
                            ? null
                            : "Amount should be lower than the balance (including fees)\nand not zero",
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  SizedBox(height: 8),
                  feeWidget(),
                  SizedBox(height: 8),
                  sourceDestContainer(),
                  SizedBox(height: 16),
                  SizedBox(
                    width: Get.width,
                    child: TextButton(
                        style: MyButtonStyles.onboardStyle,
                        onPressed: () {},
                        child: Text(
                          "Transfer",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ],
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
    );
  }
}
