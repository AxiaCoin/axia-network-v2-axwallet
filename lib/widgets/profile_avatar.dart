import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:wallet/widgets/account_switcher.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/spinner.dart';
import 'package:wallet/widgets/walletname_update.dart';

class ProfileAvatar extends StatefulWidget {
  ProfileAvatar({Key? key}) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  Widget build(BuildContext context) {
    final WalletData walletData = Get.find();

    return GestureDetector(
      onTap: () async {
        await Get.bottomSheet(AccountSwitcher(), isScrollControlled: true);
        setState(() {});
      },
      child: Column(
        children: [
          Obx(
            () => HomeWidgets.addressIdenticon(
                walletData.hdWallet!.value.pubKey ?? "nope"),
          ),
          Obx(
            () => Text(
              walletData.name.value,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
