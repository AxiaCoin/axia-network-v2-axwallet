import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/dex/confirmation.dart';
import 'package:wallet/pages/search.dart';
import 'package:wallet/widgets/number_keyboard.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({Key? key}) : super(key: key);

  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  TextEditingController payController = TextEditingController();
  TextEditingController getController = TextEditingController();
  final TokenData tokenData = Get.find();
  final BalanceData balanceData = Get.find();
  Map<Currency, double> balanceInfo = {};
  late CoinData payToken;
  late CoinData getToken;
  bool isValid = false;
  FocusMode focusMode = FocusMode.none;
  bool numPadVisibility = false;

  @override
  void initState() {
    super.initState();
    payToken = tokenData.data[0].coinData;
    getToken = tokenData.data[1].coinData;
    balanceInfo = balanceData.getData();
    payController.addListener(() {
      if (payController.text != "" && focusMode == FocusMode.pay) {
        double payValue = payToken.rate;
        double getValue = getToken.rate;
        // double exchangeValue = (getValue / payValue) * double.parse(payController.text);
        String exchangeValue =
            FormatText.exchangeValue(payValue, getValue, payController.text);
        setState(() {
          getController.text = exchangeValue == "0" ? "" : exchangeValue;
        });
      } else if (focusMode == FocusMode.get) {
        setState(() {});
      } else {
        setState(() {
          getController.text = "";
        });
      }
    });
    getController.addListener(() {
      if (getController.text != "" && focusMode == FocusMode.get) {
        double payValue = payToken.rate;
        double getValue = getToken.rate;
        // double exchangeValue = (getValue / payValue) * double.parse(payController.text);
        String exchangeValue =
            FormatText.exchangeValue(getValue, payValue, getController.text);
        setState(() {
          payController.text = exchangeValue == "0" ? "" : exchangeValue;
        });
      } else if (focusMode == FocusMode.pay) {
        setState(() {});
      } else {
        setState(() {
          payController.text = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("building");
    TextStyle caption = context.textTheme.caption!;
    isValid = payController.text != "" && getController.text != "";
    numPadVisibility = focusMode != FocusMode.none;

    Widget proportion(int value) => Expanded(
          child: GestureDetector(
            onTap: () {
              focusMode = FocusMode.pay;
              payController.text =
                  FormatText.roundOff(((value / 100) * balanceInfo[payToken]!));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: appColor.withOpacity(0.2),
              ),
              child: Text(
                "$value%",
                style: context.textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );

    Widget suffix(CoinData coinData) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(),
            Text(coinData.name),
            Icon(Icons.navigate_next)
          ],
        );

    Widget formField({required bool payMode}) {
      CoinData token = payMode ? payToken : getToken;
      return Container(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: payMode ? 16 : 8,
            bottom: payMode ? 8 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You ${payMode ? "Pay" : "Get"}",
              style: caption,
            ),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                SizedBox(
                  height: kTextTabBarHeight * 0.8,
                  child: TextField(
                    controller: payMode ? payController : getController,
                    showCursor: true,
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "0"),
                    style: TextStyle(fontSize: 24),
                    onTap: () {
                      setState(() {
                        focusMode = payMode ? FocusMode.pay : FocusMode.get;
                      });
                    },
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      Get.to(() => SearchPage(searchMode: SearchMode.swap))!
                          .then((value) => setState(() {
                                if (payMode) {
                                  payToken = value.coinData;
                                } else {
                                  getToken = value.coinData;
                                }
                              }));
                    },
                    child: suffix(token))
              ],
            ),
            Text(
              "Balance: ${balanceInfo[(token)]} ${token.unit}",
              style: caption,
            ),
          ],
        ),
      );
    }

    Widget topCard() => Container(
          // padding: EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Card(
                // margin: EdgeInsets.all(8),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      formField(payMode: true),
                      Divider(),
                      formField(payMode: false),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  CoinData temp = getToken;
                  payController.clear();
                  getController.clear();
                  setState(() {
                    getToken = payToken;
                    payToken = temp;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Container(
                    // height: 50,
                    // width: 50,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: context.theme.dividerColor),
                        color: Colors.white),
                    child: Icon(Icons.swap_vert_outlined),
                  ),
                ),
              )
            ],
          ),
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          setState(() {
            focusMode = FocusMode.none;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  topCard(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        proportion(25),
                        SizedBox(
                          width: 8,
                        ),
                        proportion(50),
                        SizedBox(
                          width: 8,
                        ),
                        proportion(75),
                        SizedBox(
                          width: 8,
                        ),
                        proportion(100)
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: Get.width,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => ConfirmationPage(
                                from: payToken,
                                to: getToken,
                                fromValue: double.parse(payController.text),
                                toValue: double.parse(getController.text)))!
                            .then((value) {
                          if (value) {
                            getController.clear();
                            payController.clear();
                            setState(() {
                              focusMode = FocusMode.none;
                            });
                          }
                        });
                      },
                      child: Text("SWAP"),
                      style: MyButtonStyles.statefulStyle(isValid),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: numPadVisibility,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: NumberKeyboard(
                    controller: focusMode == FocusMode.pay
                        ? payController
                        : getController,
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    payController.dispose();
    getController.dispose();
    super.dispose();
  }
}

enum FocusMode { none, pay, get }
