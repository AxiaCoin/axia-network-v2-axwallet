import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/qr_scan.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/onboard_widgets.dart';

class ImportWalletPage extends StatefulWidget {
  const ImportWalletPage({Key? key}) : super(key: key);

  @override
  _ImportWalletPageState createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {
  var nameController = new TextEditingController(text: "Wallet 1");
  var phraseController = new TextEditingController();
  var isValid = false;

  updateFields(String? value) {
    if (value != null) {
      setState(() {
        phraseController.text = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isValid = phraseController.text != "" && nameController.text != "";
    return Scaffold(
      appBar: AppBar(
        //brightness: Brightness.dark,
        title: Text("Import Wallet"),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Get.to(() => QRScanPage())!.then((value) => updateFields(value));
            },
          )
        ],
      ),
      body: new GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          padding: EdgeInsets.all(8),
          height: Get.height,
          width: Get.width,
          color: Colors.transparent,
          child: Stack(
            // alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextFormField(
                      controller: nameController,
                      validator: (val) => val == ""
                          ? "Please enter a name for the wallet"
                          : null,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: InputDecoration(
                          labelText: "Name", border: OutlineInputBorder()),
                      onChanged: (val) => setState(() {}),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: phraseController,
                      decoration: InputDecoration(
                        labelText: "Phrase",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() {}),
                      minLines: 4,
                      maxLines: null,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        child: Text("Paste"),
                        onPressed: () async {
                          ClipboardData? data =
                              await Clipboard.getData('text/plain');
                          setState(
                            () {
                              phraseController.text = data!.text!;
                            },
                          );
                        },
                      ),
                    ),
                    OnboardWidgets.subtitle(
                        "Typically 12 (sometimes 24) words separated by single spaces"),
                    // Spacer(),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: Get.width,
                  // alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                      // style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
                      style: MyButtonStyles.statefulStyle(isValid),
                      onPressed: onsubmit,
                      child: Text("IMPORT")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phraseController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void onsubmit() {
    if (isValid) {
      StorageService.instance.storeMnemonic(phraseController.text);
      services.initWallet(phraseController.text);
      Get.offAll(() => HomePage());
    } else
      CommonWidgets.snackBar("Error while importing");
  }
}
