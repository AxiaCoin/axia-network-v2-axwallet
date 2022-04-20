import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class TransactionsPage extends StatelessWidget {
  final TransactionItem transaction;
  final CoinData coinData;
  final bool isReceived;
  const TransactionsPage({
    Key? key,
    required this.transaction,
    required this.coinData,
    required this.isReceived,
  }) : super(key: key);

  copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    CommonWidgets.snackBar(address, copyMode: true);
  }

  @override
  Widget build(BuildContext context) {
    amountWidget() {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Image.asset(
                  "assets/currencies/${coinData.unit}.png",
                  width: Get.width * 0.1,
                  height: Get.width * 0.1,
                ),
                SizedBox(
                  height: 4,
                ),
                Icon(
                  Icons.arrow_downward,
                  size: 16,
                )
              ],
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardWidgets.titleAlt(
                    "${FormatText.roundOff(transaction.amount)} ${coinData.unit}"),
                SizedBox(
                  height: 4,
                ),
                OnboardWidgets.subtitle(
                    "Fee: ${FormatText.roundOff(transaction.fee)} ${coinData.unit}"),
              ],
            ),
          ),
        ],
      );
    }

    statusWidget() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Row(
          children: [
            Icon(
              Icons.check,
              color: tickerGreen,
              size: 32,
            ),
            Text(
              "  ${isReceived ? "Received" : "Sent"}",
              style: TextStyle(
                  color: tickerGreen,
                  fontSize: 21,
                  fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Text(DateFormat.yMMMd().format(transaction.time.toLocal()) +
                " at " +
                DateFormat.jm().format(transaction.time.toLocal())),
          ],
        ),
      );
    }

    walletsWidget() {
      return Column(
        children: [
          ListTile(
            title: Text(
              "To",
              style: TextStyle(color: Colors.grey),
            ),
            subtitle: GestureDetector(
              onTap: () => copyAddress(transaction.to),
              child: Text(
                transaction.to,
                style: TextStyle(fontSize: 21, color: Colors.black),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "From",
              style: TextStyle(color: Colors.grey),
            ),
            subtitle: GestureDetector(
              onTap: () => copyAddress(transaction.from),
              child: Text(
                transaction.from,
                style: TextStyle(fontSize: 21, color: Colors.black),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    "Transaction Details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  )),
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 32,
                      )),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              amountWidget(),
              statusWidget(),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.arrow_downward,
                      size: 16,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(),
                  ),
                ],
              ),
              walletsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
