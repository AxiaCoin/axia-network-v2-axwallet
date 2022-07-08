import 'package:flutter/material.dart';

import 'package:wallet/widgets/common.dart';

class AmountSuffix extends StatelessWidget {
  final TextEditingController controller;
  final double? maxAmount;
  const AmountSuffix({
    Key? key,
    required this.controller,
    required this.maxAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            if (maxAmount == null) return;
            if (maxAmount! <= 0) {
              return CommonWidgets.snackBar(
                  "Balance too low (after fees) to transfer");
            }
            controller.text = maxAmount.toString();
          },
          child: Text("MAX"),
        ),
      ],
    );
  }
}
