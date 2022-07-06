// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/qr_scan.dart';
import 'package:wallet/widgets/spinner.dart';

class CommonWidgets {
  CommonWidgets._();

  static snackBar(String text, {bool copyMode = false, int duration = 2}) {
    // Get.closeCurrentSnackbar();
    Get.showSnackbar(GetBar(
      message: "${copyMode ? "Copied: " : ""}$text",
      backgroundColor: Colors.black.withOpacity(0.7),
      maxWidth: Get.width * 0.85,
      margin: EdgeInsets.only(bottom: 16),
      borderRadius: 10,
      duration: Duration(seconds: duration),
      animationDuration: Duration(milliseconds: 200),
      // snackPosition: SnackPosition.TOP,
    ));
  }

  static waitDialog({String text = "Accessing Wallet"}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => true,
        child: AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Spinner(), Text(text)],
          ),
        ),
      ),
      barrierDismissible: kDebugMode,
    );
  }

  static bottomSheet(Widget bottomsheet) async {
    await Get.bottomSheet(bottomsheet);
  }

  static launch(String url) async {
    Uri uri = Uri.parse(url);
    (await canLaunchUrl(uri))
        ? await launchUrl(uri, mode: LaunchMode.externalApplication)
        : CommonWidgets.snackBar("Cannot open the link");
  }

  static backButton(BuildContext context) => IconButton(
      icon: Icon(
        Icons.keyboard_arrow_left,
        // size: 14,
      ),
      onPressed: () {
        Navigator.pop(context);
      });

  static Widget elevatedContainer({
    required Widget child,
    double margin = 16,
    double padding = 8,
    Color shadowColor = const Color(0x4040401A),
  }) =>
      Container(
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: Offset(0, 4),
              spreadRadius: 0,
              blurRadius: 16,
            ),
          ],
        ),
        child: child,
      );

  static Widget profileItem(
    BuildContext context, {
    required String key,
    required String value,
    Function()? onPressed,
  }) =>
      Wrap(
        // crossAxisAlignment: CrossAxisAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            key,
            style: context.textTheme.caption!.copyWith(fontSize: 16),
          ),
          Text(
            value,
            style: context.textTheme.caption!
                .copyWith(fontSize: 20, color: appColor),
          ),
          onPressed == null
              ? Container()
              : IconButton(onPressed: onPressed, icon: Icon(Icons.edit))
        ],
      );

  static Widget addressTextField(
      TextEditingController controller, Currency currency,
      {Function(String? value)? onQRValue,
      TextEditingController? amountController}) {
    updateFields(String result) {
      String? address;
      String? amount;
      if (result.contains(":")) {
        var data = result.split("/").last.split("?amount=");
        address = data.first;
        amount = data.length > 1 ? data.last : null;
        controller.text = address;
        if (amount != null) amountController!.text = amount;
      } else {
        controller.text = result;
      }
    }

    Widget recipientSuffixWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  Get.to(() => QRScanPage())!.then((value) {
                    if (onQRValue != null) onQRValue(value);
                  });
                },
                icon: SvgPicture.asset(
                  "assets/icons/qr.svg",
                  color: appColor,
                )),
            TextButton(
                onPressed: () async {
                  ClipboardData? data = await Clipboard.getData('text/plain');
                  controller.text = data!.text!;
                },
                child: Text("PASTE"))
          ],
        );
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          // onFieldSubmitted: (val) {
          //   amountFocus.requestFocus();
          // },
          decoration: InputDecoration(
              hintText:
                  FormatText.address(currency.getWallet().address, pad: 6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              contentPadding:
                  EdgeInsets.fromLTRB(18, 18, Get.width * 0.25, 18)),
          validator: (val) =>
              val != null && val.isNotEmpty ? null : "Please enter an address",
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        recipientSuffixWidget()
      ],
    );
  }
}
