// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonWidgets {
  CommonWidgets._();

  static snackBar(String text, {bool copyMode = false, int duration = 2}) =>
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
