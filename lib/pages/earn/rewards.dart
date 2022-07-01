import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/cache.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/reward_item.dart';
import 'package:wallet/widgets/spinner.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  AXCWalletData axcWalletData = Get.find();
  List<ValidatorItem> validators = [];
  List<Nominator> rewards = [];
  bool isLoading = false;
  int totalR = 0;

  getValidators() async {
    setState(() => isLoading = true);
    var response = (await services.axSDK.api!.nomination
        .getValidators())["validators"] as List;
    validators = response.map((e) => ValidatorItem.fromMap(e)).toList();
    validators
        .sort((a, b) => b.nominators.length.compareTo(a.nominators.length));
    CustomCacheManager.instance.cacheValidators(validators);
    if (mounted) setState(() => isLoading = false);
  }

  getRewards(List<String> pAddresses) {
    rewards.clear();
    totalR = 0;
    validators.forEach((e) {
      if (e.nominators.isEmpty) return;
      var thisRewards = e.nominators.where((del) {
        List<String> rewardAddrs = del.rewardOwner.addresses;
        List filtered = rewardAddrs
            .where((element) => pAddresses.contains(element))
            .toList();
        if (filtered.isNotEmpty) {
          totalR += int.parse(del.potentialReward);
          return true;
        }
        return false;
      }).toList();
      rewards.addAll(thisRewards);
    });
    rewards.sort(((a, b) => a.startTime.compareTo(b.startTime)));
  }

  @override
  void initState() {
    super.initState();
    validators = CustomCacheManager.instance.validatorsFromCache() ?? [];
    getValidators();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Staking Rewards"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );

    Widget empty() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                child: Image.asset(
                  "assets/icons/empty_txn.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              HomeWidgets.emptyListText("You do not have any pending rewards"),
              // SizedBox(
              //   height: 16,
              // ),
            ],
          ),
        );

    Widget totalRewards() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Rewards",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            "${FormatText.roundOff(totalR / pow(10, denomination))} AXC",
            style: Theme.of(context).textTheme.headline4,
          )
        ],
      );
    }

    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() =>
              (axcWalletData.wallet.value.allCore == null || validators.isEmpty)
                  ? Spinner(
                      text: "Getting your rewards",
                    )
                  : FutureBuilder(
                      future: getRewards(axcWalletData.wallet.value.allCore!),
                      builder: ((context, snapshot) {
                        return rewards.isEmpty
                            ? empty()
                            : ListView.builder(
                                itemCount: rewards.length + 1,
                                itemBuilder: (context, index) {
                                  return index == 0
                                      ? totalRewards()
                                      : RewardItem(
                                          delegator: rewards[index - 1],
                                        );
                                });
                      }))),
        ),
      ),
    );
  }
}