import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/pages/new_user/create_wallet/onboard.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/walletname_update.dart';

class AccountSwitcher extends StatefulWidget {
  const AccountSwitcher({Key? key}) : super(key: key);

  @override
  State<AccountSwitcher> createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  final WalletData walletData = Get.find();
  @override
  Widget build(BuildContext context) {
    var list = services.hdWallets.entries.map((e) => e.value).toList();

    Widget button(IconData icon, Function() onPressed) {
      return SizedBox(
        height: 28,
        width: 28,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 18,
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   "Wallets",
          //   style: Theme.of(context).textTheme.headline6,
          // ),
          SizedBox(
            height: 8,
          ),
          CommonWidgets.handleBar(),
          SizedBox(
            height: 8,
          ),
          ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: list.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: ((context, index) {
                HDWalletInfo info = list[index];
                bool isActive =
                    info.hdWallet!.pubKey == walletData.hdWallet!.value.pubKey;
                return ListTile(
                  dense: true,
                  title: Text(
                    info.name,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      button(
                        Icons.edit,
                        () async {
                          await Get.bottomSheet(
                            WalletNameUpdate(
                              wname: info.name,
                              pubKey: info.hdWallet!.pubKey!,
                            ),
                            isScrollControlled: true,
                          );
                          setState(() {});
                        },
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      button(
                        Icons.delete,
                        () async {
                          Widget dialog = AlertDialog(
                            title: Text("Do you want to delete this wallet?"),
                            content: Text(
                                "This will remove the wallet you have created and you will need to re-import them with the secret phrase"),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: Text("Delete"),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text("Cancel"),
                              ),
                            ],
                          );
                          bool isConfirmed = await Get.dialog(dialog) ?? false;
                          if (isConfirmed) {
                            // if (isActive) {
                            //   CommonWidgets.waitDialog(
                            //       text:
                            //           "Switching to a different wallet. Please wait");
                            // }
                            await services.deleteWallet(
                                context, info.hdWallet!.pubKey!);
                            if (isActive && services.hdWallets.isNotEmpty) {
                              Get.back();
                            }
                          }
                          setState(() {});
                        },
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.delete),
                      // ),
                    ],
                  ),
                  leading: HomeWidgets.addressIdenticon(info.hdWallet!.pubKey!),
                  trailing: isActive
                      ? Icon(
                          Icons.check_circle,
                          color: tickerGreen,
                        )
                      : Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    if (isActive) return;
                    CommonWidgets.waitDialog(text: "Changing Wallet");
                    await services.initMCWallet(info.hdWallet!.pubKey);
                    Get.back();
                    Get.back();
                    setState(() {});
                  },
                );
              })),
          Divider(),
          ListTile(
            title: Text(
              "Add new account",
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
            onTap: () async {
              Get.to(() => OnboardPage(
                    showBack: true,
                  ));
            },
          ),
        ],
      ),
    );
  }
}
