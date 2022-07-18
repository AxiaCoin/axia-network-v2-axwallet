import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:time_picker_widget/time_picker_widget.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';

import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/currencies/axiacoin.dart';
import 'package:wallet/pages/device_auth.dart';
import 'package:wallet/widgets/address_textfield.dart';
import 'package:wallet/widgets/amount_suffix.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/spinner.dart';

class AddValidatorPage extends StatefulWidget {
  const AddValidatorPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AddValidatorPage> createState() => _AddValidatorPageState();
}

class _AddValidatorPageState extends State<AddValidatorPage> {
  final formKey = GlobalKey<FormState>();
  var api = services.axSDK.api!;
  TextEditingController amountController = new TextEditingController();
  TextEditingController nodeIdController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController feeController = new TextEditingController(text: "2.0");
  TextEditingController addressController = new TextEditingController();
  final BalanceData balanceData = Get.find();
  final AXCWalletData axcWalletData = Get.find();
  FocusNode amountFocus = new FocusNode();
  late Currency currency;
  late DateTime selectedDate;
  late DateTime minStartDate;
  late DateTime endDate;
  String reward = "this";
  bool isCustomVisible = false;
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("This wallet"), value: "this"),
      DropdownMenuItem(child: Text("Custom Address"), value: "custom"),
    ];
    return menuItems;
  }

  Timer? timer;

  double? getPBalance() {
    var balances = axcWalletData.balance.value;
    return double.tryParse(balances.core ?? "asd");
  }

  incrementMinStartTime() {
    Duration inc = Duration(seconds: 10);
    timer = Timer.periodic(inc, (timer) {
      minStartDate = minStartDate.add(inc);
      endDate = minStartDate.add(Duration(days: 365 - minStakeDays));
      if (dateController.text.isNotEmpty) {
        dateController.text = FormatText.readableDate(selectedDate);
        setState(() {});
      }
    });
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      if (isCustomVisible) {
        bool isValid =
            await Utils.validateAddress(Chain.Core, addressController.text);
        if (!isValid) {
          CommonWidgets.snackBar(
              "Please check if the address is correct for the network (Core)!");
          return;
        }
      }
      var data = await Get.to(() => DeviceAuthPage());
      if (data != null && data == true) {
        CommonWidgets.waitDialog(text: "Adding Validator");
        await Future.delayed(Duration(milliseconds: 200));
        try {
          print("Add Validator started");
          // int amount =
          //     (double.parse(amountController.text) * pow(10, denomination))
          //         .toInt();
          print(amountController.text);
          var response = await api.nomination.addValidator(
            nodeID: nodeIdController.text.trim(),
            amount: amountController.text.trim(),
            end: selectedDate.millisecondsSinceEpoch,
            fee: int.parse(feeController.text),
            rewardAddress:
                addressController.text.isEmpty ? null : addressController.text,
          );
          print("Nomination response: $response");
          print(response.runtimeType);
          await Future.delayed(Duration(milliseconds: 200));
          if (response != null && response is Map && response["txID"] != null) {
            print("success");
            Get.back();
            Get.back();
            services.getAXCWalletDetails();
            CommonWidgets.snackBar(
                "The node was successfully Nominated, check rewards page!",
                duration: 7);
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
    currency = AXIACoin();
    selectedDate =
        DateTime.now().add(Duration(days: minStakeDays, minutes: 15));
    minStartDate = selectedDate;
    endDate = minStartDate.add(Duration(days: 365 - minStakeDays));
    incrementMinStartTime();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: minStartDate,
        lastDate: endDate);
    if (date != null) {
      bool isEndDay = endDate.year == date.year &&
          endDate.month == date.month &&
          endDate.day == date.day;
      bool isMinStartDay = minStartDate.year == date.year &&
          minStartDate.month == date.month &&
          minStartDate.day == date.day;
      TimeOfDay? time = await showCustomTimePicker(
        context: context,
        initialTime: isEndDay
            ? TimeOfDay(hour: 0, minute: 0)
            : isMinStartDay
                ? TimeOfDay(
                    hour: max(minStartDate.hour, selectedDate.hour),
                    minute: max(minStartDate.minute, selectedDate.hour))
                : TimeOfDay.fromDateTime(selectedDate),
        onFailValidation: (context) =>
            CommonWidgets.snackBar("Please choose a time within the range"),
        selectableTimePredicate: (time) =>
            time != null &&
            // In case of the day selected == end day,
            // allow all minutes when hour < end hour
            // disallow minutes past end time when hour == end
            (!isEndDay ||
                (time.hour < endDate.hour ||
                    (time.hour == endDate.hour &&
                        time.minute <= endDate.minute))) &&
            // In case of the day selected == min stake period day,
            // allow all minutes when hour > min hour
            // disallow minutes before min time when hour == min
            (!isMinStartDay ||
                (time.hour > minStartDate.hour ||
                    (time.hour == minStartDate.hour &&
                        time.minute >= minStartDate.minute))),
      );
      if (time != null) {
        date = date.add(Duration(hours: time.hour, minutes: time.minute));
        setState(() {
          selectedDate = date!;
          dateController.text = FormatText.readableDate(selectedDate);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Add Validator"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );

    Widget amountWidget() => Stack(
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
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
              validator: (val) => val != null &&
                      val.isNotEmpty &&
                      val != "." &&
                      double.parse(val) != 0 &&
                      (getPBalance() == null ||
                          double.parse(val) <= getPBalance()!)
                  ? double.parse(val) < minAddValidatorStake
                      ? "Minimum stake amount is $minAddValidatorStake ${currency.coinData.unit}"
                      : null
                  : "Amount should be lower than the balance and not zero",
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onTap: () {
                if (getPBalance() == null) {
                  CommonWidgets.snackBar(
                      "Wait for the wallet/balances to load before proceeding");
                  return;
                }
              },
            ),
            AmountSuffix(
              controller: amountController,
              maxAmount: getPBalance(),
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     TextButton(
            //       onPressed: () {
            //         double? bal = getPBalance();
            //         if (bal == null) return;
            //         amountController.text = bal.toString();
            //       },
            //       child: Text("MAX"),
            //     ),
            //   ],
            // ),
          ],
        );

    Widget rewardAddress() => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          filled: false,
        ),
        value: reward,
        onChanged: (String? newValue) {
          if (newValue != null) {
            if (newValue == "this") addressController.clear();
            setState(() {
              reward = newValue;
              isCustomVisible = newValue == "custom";
            });
          }
        },
        items: dropdownItems);

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
          // floatingActionButton: FloatingActionButton(
          //   child: Icon(Icons.add),
          //   onPressed: () async {
          //     print(addressController.text.isEmpty);
          //   },
          // ),
          body: Container(
            padding: EdgeInsets.all(16),
            child: ListView(children: [
              OnboardWidgets.neverShare(
                  text:
                      "If it is your first time staking, start small. Staked tokens are locked until the end of the staking period."),

              Text("Node ID",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              TextFormField(
                controller: nodeIdController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "NodeID-",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) => val != null && val.isNotEmpty
                    ? null
                    : "Please enter a node ID",
              ),
              SizedBox(height: 8),
              Text("Fee in percentage",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              // Text(
              //     "You will claim this % of the rewards from the Nominators on your node."),
              SizedBox(height: 8),
              TextFormField(
                controller: feeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Fee%",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                inputFormatters: InputFormatters.amountFilter(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) => val != null && val.isNotEmpty
                    ? null
                    : "Please enter a fee percentage",
              ),
              SizedBox(height: 8),
              Text("Staking End Date",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text("Your AXC tokens will be locked until this date."),
              Text(
                "(Start date will be 15 minutes from when you submit this form)",
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Staking End Date",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) => val != null && val.isNotEmpty
                    ? null
                    : "Please choose a staking end date",
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 8),
              Text("Stake Amount",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text("The amount of AXC to lock for staking."),
              SizedBox(height: 8),
              amountWidget(),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4),
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
                                width: 20,
                                height: 20,
                                child: Spinner(
                                  alt: true,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "Balance: ${getPBalance()} ${currency.coinData.unit}",
                            style: context.textTheme.caption,
                            textAlign: TextAlign.start,
                          ),
                  )),
              SizedBox(height: 8),
              Text("Reward Address",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text("Where to send the staking rewards."),
              SizedBox(height: 8),
              rewardAddress(),
              SizedBox(height: isCustomVisible ? 8 : 0),
              isCustomVisible
                  ? AddressTextField(
                      controller: addressController,
                      title: "Custom Address (Core)",
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 8),
              SizedBox(
                width: Get.width,
                child: TextButton(
                    style: MyButtonStyles.onboardStyle,
                    onPressed: onSubmit,
                    child: Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
