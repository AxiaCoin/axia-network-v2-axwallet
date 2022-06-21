import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/widgets/common.dart';

class WalletNameUpdate extends StatefulWidget {
  String wname;
  WalletNameUpdate({
    Key? key,
    required this.wname,
  }) : super(key: key);

  @override
  State<WalletNameUpdate> createState() => _WalletNameUpdateState();
}

class _WalletNameUpdateState extends State<WalletNameUpdate> {
  final formKey = GlobalKey<FormState>();
  TextEditingController wnameController = TextEditingController();
  bool isvalid = false;
  @override
  void initState() {
    super.initState();
    wnameController.text = widget.wname;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  "Wallet Name Update",
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
              height: 16,
            ),
            TextFormField(
              controller: wnameController,
              validator: (val) =>
                  val == "" ? "Please enter a new name for the wallet" : null,
              maxLength: 20,
              autovalidateMode: AutovalidateMode.always,
              decoration: InputDecoration(
                labelText: "Wallet Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
              onChanged: (val) => setState(() {
                isvalid = true;
              }),
            ),
            Container(
              width: Get.width,
              padding: EdgeInsets.only(top: 16),
              child: ElevatedButton(
                  style: MyButtonStyles.statefulStyle(isvalid),
                  onPressed: onupdate,
                  child: Text("UPDATE")),
            ),
          ],
        ),
      ),
    );
  }

  void onupdate() async {
    if (formKey.currentState!.validate()) {
      StorageService.instance.updateWalletName(wnameController.text);
      setState(() {});
      Get.back();
      CommonWidgets.snackBar("Wallet Name Successfully Updated!");
    }
  }
}
