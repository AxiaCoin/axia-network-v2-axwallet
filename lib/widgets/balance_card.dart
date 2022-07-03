import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/spinner.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({Key? key}) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  AXCWalletData axcWalletData = Get.find();
  double totalBalance = 0;

  getBalanceFromChain(Chain chain) {
    return double.parse(chain == Chain.Swap
        ? axcWalletData.balance.value.swap!
        : chain == Chain.Core
            ? axcWalletData.balance.value.core!
            : axcWalletData.balance.value.ax!);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget total() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Balance",
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.white),
          ),
          Obx(
            () {
              if (axcWalletData.balance.value.swap == null) {
                return Row(
                  children: [
                    Spinner(
                      alt: true,
                      color: Colors.white,
                    ),
                    Text(
                      "",
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.white),
                    ),
                  ],
                );
              }
              totalBalance =
                  Chain.values.fold(0.0, (p, e) => p + getBalanceFromChain(e));
              totalBalance += double.parse(axcWalletData.balance.value.staked!);
              return AutoSizeText(
                "${FormatText.commaNumber(totalBalance.toString())} AXC",
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: Colors.white),
                maxLines: 1,
              );
            },
          )
        ],
      );
    }

    Widget balanceItem(Chain chain) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 4,
          ),
          Text(
            chain.name,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(color: Colors.white),
          ),
          Obx(
            () => axcWalletData.balance.value.swap == null
                ? Spinner(
                    alt: true,
                    color: Colors.white,
                  )
                : AutoSizeText(
                    FormatText.commaNumber(
                            (getBalanceFromChain(chain) + 0000).toString()) +
                        " AXC",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
          ),
        ],
      );
    }

    Widget staked() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Staked",
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(color: Colors.white),
          ),
          Obx(
            () => axcWalletData.balance.value.staked == null
                ? Spinner(
                    alt: true,
                    color: Colors.white,
                  )
                : AutoSizeText(
                    FormatText.commaNumber(
                            axcWalletData.balance.value.staked!) +
                        " AXC",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        gradient: LinearGradient(
            colors: [appColor[600]!, appColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          total(),
          SizedBox(
            height: 8,
          ),
          ...Chain.values.map((e) => balanceItem(e)).toList(),
          Divider(
            color: Colors.white30,
          ),
          staked(),
        ],
      ),
    );
  }
}
