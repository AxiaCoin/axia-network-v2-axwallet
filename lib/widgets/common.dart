import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonWidgets {
  CommonWidgets._();

  static snackBar(String text, {bool copyMode = true}) =>
      Get.showSnackbar(GetBar(
        message: "${copyMode ? "Copied: " : ""}$text",
        backgroundColor: Colors.black.withOpacity(0.7),
        maxWidth: Get.width * 0.85,
        margin: EdgeInsets.only(bottom: Get.height * 0.15),
        borderRadius: 10,
        duration: Duration(seconds: 2),
        animationDuration: Duration(milliseconds: 200),
        // snackPosition: SnackPosition.TOP,
      ));

}