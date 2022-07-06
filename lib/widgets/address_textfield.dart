import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/qr_scan.dart';

class AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController? amountController;
  final String? title;
  const AddressTextField({
    Key? key,
    required this.controller,
    this.amountController,
    this.title,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    Widget recipientSuffixWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  Get.to(() => QRScanPage())!.then((value) {
                    if (value != null && amountController != null) {
                      updateFields(value);
                    }
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
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title ?? "Recipient Address",
              style: Theme.of(context).textTheme.subtitle2,
            )),
        SizedBox(
          height: 8,
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: controller,
              textInputAction: TextInputAction.next,
              // onFieldSubmitted: (val) {
              //   amountFocus.requestFocus();
              // },
              decoration: InputDecoration(
                hintText: "Enter an address",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                contentPadding:
                    EdgeInsets.fromLTRB(18, 18, Get.width * 0.25, 18),
              ),

              validator: (val) => val != null && val.isNotEmpty
                  ? null
                  : "Please enter an address",
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            recipientSuffixWidget(),
          ],
        ),
      ],
    );
  }
}
