import 'package:axwallet_sdk/models/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/webview.dart';
import 'package:wallet/widgets/common.dart';

class AXCTxnTile extends StatelessWidget {
  final AXCTransaction transaction;
  const AXCTxnTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String id = transaction.id!;
    String fee = transaction.fee!;
    String amount =
        transaction.amount != null ? transaction.amount! + " AXC" : "";
    String time = FormatText.elapsedTime(transaction.timestamp!);

    Widget importExport() {
      bool isImport = transaction.type == "import";
      String chain = isImport ? transaction.destination! : transaction.source!;
      return ListTile(
        title: Text(time),
        subtitle: Text(isImport ? "Import ($chain)" : "Export ($chain)"),
        trailing: Text(
          (isImport ? "" : "-") + amount,
          style: TextStyle(color: !isImport ? tickerRed : tickerGreen),
        ),
      );
    }

    Widget addNominatorValidator() {
      DateTime startDate = DateTime.parse(transaction.stakeStart!).toLocal();
      DateTime endDate = DateTime.parse(transaction.stakeEnd!).toLocal();
      int start = startDate.millisecondsSinceEpoch;
      int end = endDate.millisecondsSinceEpoch;
      bool isStarted = startDate.compareTo(DateTime.now()).isNegative;
      bool isNominator = transaction.type == "add_nominator";
      return Column(
        children: [
          ListTile(
            title: Text(time),
            subtitle: LinearProgressIndicator(
              value: Utils.getStakingProgress(start, end),
              color: tickerGreen.withOpacity(0.6),
              backgroundColor: Colors.black12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStarted ? "End Date" : "Start Date",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(FormatText.readableDate(isStarted ? endDate : startDate))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isNominator ? "Add Nominator" : "Add Validator",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  amount,
                  style: TextStyle(color: appColor),
                )
              ],
            ),
          ),
          // ListTile(
          //   subtitle: Text("Add Nominator"),
          //   trailing: Text(amount),
          // ),
          SizedBox(
            height: 8,
          )
        ],
      );
    }

    Widget baseTxn() {
      double total = 0;
      List<String> addr = [];
      transaction.tokens!.forEach((e) {
        total += double.parse(e.amountDisplayValue!.replaceAll(",", ""));
        addr.addAll(e.addresses!);
      });
      bool isSent = total <= 0;
      String txnAmount = FormatText.commaNumber(total.toString()) + " AXC";
      String addresses = addr
          .map((e) => "Swap-" + FormatText.address(e, hideLast: true))
          .toList()
          .join(", ");
      if (total == 0) {
        txnAmount = "-" + fee + " AXC";
        addresses = "self";
      }
      return ListTile(
        isThreeLine: true,
        title: Text(time),
        subtitle: Text(
          "${isSent ? "Sent\nto $addresses" : "Received\nfrom $addresses"}",
          // (isSent ? "to $addresses" : "from $addresses"),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          txnAmount,
          style: TextStyle(color: isSent ? tickerRed : tickerGreen),
        ),
      );
    }

// "import" | "export" | "transaction" | "transaction_evm" | "add_nominator" |
// "add_validator" | "nomination_fee" | "validation_fee" | "not_supported"
    Widget child() {
      switch (transaction.type!) {
        case "export":
        case "import":
          return importExport();
        case "transaction":
        case "transaction_evm":
          return baseTxn();
        case "add_validator":
        case "add_nominator":
          return addNominatorValidator();
        //   return addValidator();
        default:
          return Container(
            child: Text(transaction.type!),
          );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Ink(
        decoration: BoxDecoration(
          color: appGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: appColor[100],
          onTap: () {
            NetworkConfig network = StorageService.instance.connectedNetwork!;
            String url = network.explorerTxnURL + "/tx/$id";
            CommonWidgets.launchWebView(url);
          },
          child: Container(
            // padding: EdgeInsets.all(8),
            child: child(),
          ),
        ),
      ),
    );
  }
}
