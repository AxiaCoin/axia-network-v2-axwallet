import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class QRCreationPage extends StatelessWidget {
  final String qrData;
  const QRCreationPage({Key? key, required this.qrData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("QR Code"),),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: EdgeInsets.only(top: Get.width * 0.15),
              child: OnboardWidgets.title("QR Code")),
          // Spacer(),
          Container(
            padding: EdgeInsets.only(left: Get.width * 0.15, right: Get.width * 0.15, top: Get.width * 0.1),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 4,
              // margin: EdgeInsets.all(Get.width * 0.05),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImage(
                      data: qrData,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "This QR code contains your recovery phrase",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.all(32),
              child: OnboardWidgets.neverShare()),
          // Spacer(),
        ],
      ),
    );
  }
}
