import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/currencies/axiacoin.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/number_keyboard.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({Key? key}) : super(key: key);

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  TextEditingController amountController = new TextEditingController();
  TextEditingController nodeIdController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController feeController = new TextEditingController(text: "2.0");
  TextEditingController addressController = new TextEditingController();
  final BalanceData balanceData = Get.find();
  FocusNode amountFocus = new FocusNode();
  bool numPadVisibility = false;
  late Currency currency;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    currency = AXIACoin();
    addressController.text = currency.getWallet().address;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Validate"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );

    Widget amountWidget() => Stack(
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
                hintText: "0.1",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    amountController.text =
                        FormatText.roundOff((balanceData.data?[currency])!);
                  },
                  child: Text("MAX"),
                ),
              ],
            ),
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
              ListView(children: [
                Text("Node ID",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextFormField(
                  controller: nodeIdController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Node ID",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 8),
                Text("Staking End Date",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("Your AXC tokens will be locked until this date."),
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
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 8),
                Text("Stake Amount",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("The amount of AXC to lock for staking."),
                SizedBox(height: 8),
                amountWidget(),
                SizedBox(height: 8),
                Text("Delegation Fee",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(
                    "You will claim this % of the rewards from the delegators on your node."),
                SizedBox(height: 8),
                TextFormField(
                  controller: feeController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Fee",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 8),
                Text("Reward Address",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("Where to send the staking rewards."),
                SizedBox(height: 8),
                TextFormField(
                  controller: addressController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Reward Address",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 8),
                OnboardWidgets.neverShare(
                    text:
                        "If it is your first time staking, start small. Staked tokens are locked until the end of the staking period."),
                SizedBox(
                  width: Get.width,
                  child: TextButton(
                      style: MyButtonStyles.onboardStyle,
                      onPressed: () {},
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ]),
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
