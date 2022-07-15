import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/utils.dart';

class RewardItem extends StatelessWidget {
  final Nominator nominator;
  const RewardItem({
    Key? key,
    required this.nominator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int startTime = int.parse(nominator.startTime) * 1000;
    int endTime = int.parse(nominator.endTime) * 1000;
    String stakeAmount = FormatText.roundOff(
        BigInt.from(int.parse(nominator.stakeAmount)) /
            BigInt.from(pow(10, denomination)));
    String nodeID = nominator.nodeID;
    String potentialReward = FormatText.roundOff(
        BigInt.from(int.parse(nominator.potentialReward)) /
            BigInt.from(pow(10, denomination)),
        maxDecimals: 9);
    int now = DateTime.now().millisecondsSinceEpoch;

    Widget infoItem(String title, String value) => Column(
          children: [
            Text(
              title,
              style: TextStyle(color: appColor, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ],
        );

    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: appColor[50],
            boxShadow: [
              BoxShadow(
                offset: Offset(1, 1),
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 0,
              )
            ]),
        padding: const EdgeInsets.only(bottom: 4),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 20,
                    width: width * Utils.getStakingProgress(startTime, endTime),
                    color: tickerGreen.withOpacity(0.6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FormatText.readableDate(
                            DateTime.fromMillisecondsSinceEpoch(startTime)),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        FormatText.readableDate(
                            DateTime.fromMillisecondsSinceEpoch(endTime)),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                nodeID,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  infoItem("Stake", stakeAmount + " AXC"),
                  infoItem("Potential Reward", potentialReward + " AXC"),
                ],
              ),
            ),
            // Text(stakeAmount.toString()),
            // Text(potentialReward.toString()),
          ]),
        ),
      );
    });
  }
}
