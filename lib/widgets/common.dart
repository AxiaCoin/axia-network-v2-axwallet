// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';

class CommonWidgets {
  CommonWidgets._();

  static snackBar(String text, {bool copyMode = false, int duration = 2}) {
    Get.closeCurrentSnackbar();
    Get.showSnackbar(GetSnackBar(
      message: "${copyMode ? "Copied: " : ""}$text",
      backgroundColor: Colors.black.withOpacity(0.7),
      maxWidth: Get.width * 0.85,
      margin: EdgeInsets.only(bottom: Get.height * 0.15),
      borderRadius: 10,
      duration: Duration(seconds: duration),
      animationDuration: Duration(milliseconds: 200),
      // snackPosition: SnackPosition.TOP,
    ));
  }

  static waitDialog({String text = "Accessing Wallet"}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CircularProgressIndicator.adaptive(), Text(text)],
          ),
        ),
      ),
      // barrierDismissible: false,
    );
  }

  static bottomSheet(Widget bottomsheet) async {
    await Get.bottomSheet(bottomsheet);
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
      Row(
        // crossAxisAlignment: CrossAxisAlignment.end,
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
}
