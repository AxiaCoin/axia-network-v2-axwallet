import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/pages/earn/confirm_nominate.dart';

class ValidatorTile extends StatelessWidget {
  final ValidatorItem validator;
  const ValidatorTile({
    Key? key,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget infoItem(String title, String value) => Text.rich(
          TextSpan(
            style: TextStyle(color: appColor, fontWeight: FontWeight.bold),
            text: "$title: ",
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        );

    Widget iconItem(IconData icon, String value) => Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 20),
            text: value + " ",
            children: [
              WidgetSpan(child: Icon(icon, color: appColor)),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Ink(
        decoration: BoxDecoration(
          color: appGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: appColor[100],
          onTap: () {
            FocusScope.of(context).unfocus();
            Get.to(() => ValidatePage(
                  validator: validator,
                ));
          },
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                FittedBox(
                    child: Text(
                  validator.nodeID,
                  style: Theme.of(context).textTheme.headline4,
                  maxLines: 1,
                )),
                Row(
                  children: [
                    infoItem(
                        "Stake", FormatText.stakeAmount(validator.stakeAmount)),
                    Spacer(),
                    iconItem(
                        Icons.groups, validator.nominators.length.toString()),
                  ],
                ),
                Row(
                  children: [
                    infoItem(
                        "Fee",
                        FormatText.roundOff(
                                double.parse(validator.nominationFee)) +
                            "%"),
                    Spacer(),
                    iconItem(
                        Icons.access_time_filled,
                        FormatText.remainingTime(
                            int.parse(validator.endTime) * 1000)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
