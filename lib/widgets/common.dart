// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/qr_scan.dart';
import 'package:wallet/widgets/home_widgets.dart';
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
          // content: Text.rich(
          //   TextSpan(text: "", children: [
          //     WidgetSpan(child: Spinner()),
          //     TextSpan(text: text),
          //   ]),
          // ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Spinner(),
              ),
              Expanded(child: Text(text))
            ],
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
        ? await launchUrl(uri)
        : CommonWidgets.snackBar("Cannot open the link");
  }

  static launchWebView(String url) async {
    ChromeSafariBrowser browser = ChromeSafariBrowser();
    Uri uri = Uri.parse(url);
    (await canLaunchUrl(uri))
        ? await browser.open(
            url: uri,
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(),
                ios: IOSSafariOptions(barCollapsingEnabled: true)))
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

  static Widget handleBar() {
    return Container(
      height: 4,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
      ),
    );
  }

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

  static Widget empty(String text) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: Get.width * 0.25,
              width: Get.width * 0.25,
              child: Image.asset(
                "assets/icons/empty_txn.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            HomeWidgets.emptyListText(text),
            // SizedBox(
            //   height: 16,
            // ),
          ],
        ),
      );
}
