import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/widgets/common.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: appColor,
              borderWidth: 8,
              borderRadius: 10,
              borderLength: 30,
              cutOutSize: Get.width * 0.6,
            ),
          ),
          Align(
            alignment: Alignment(-0.9, -0.9),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4040401A),
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                    blurRadius: 32,
                  ),
                ],
              ),
              child: CommonWidgets.backButton(context),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) {
        if (result == null) {
          setState(
            () {
              result = scanData;
              Get.back(result: result!.code);
              controller.dispose();
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
