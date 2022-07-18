import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/pages/qr_creation.dart';
import 'package:wallet/pages/receive.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/spinner.dart';

class AddressCard extends StatefulWidget {
  const AddressCard({Key? key}) : super(key: key);

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  AXCWalletData axcWalletData = Get.find();
  double totalBalance = 0;
  int slidingIndex = 0;
  Chain chain = Chain.Swap;

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
    Widget chainWidget() => CupertinoSlidingSegmentedControl<int>(
          children: {
            0: HomeWidgets.segmentedText("Swap-Chain"),
            1: HomeWidgets.segmentedText("Core-Chain"),
            2: HomeWidgets.segmentedText("AX-Chain"),
          },
          groupValue: slidingIndex,
          onValueChanged: (int? val) {
            if (val == null) return;
            setState(() {
              chain = val == 0
                  ? Chain.Swap
                  : val == 1
                      ? Chain.Core
                      : Chain.AX;
              slidingIndex = val;
            });
          },
          backgroundColor: Colors.black.withOpacity(0.2),
          thumbColor: appColor,
        );

    Widget addressItem(Chain chain) {
      double width = Get.width * 0.25;
      var wallet = axcWalletData.wallet.value;
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (axcWalletData.wallet.value.swap == null) return;
                  Get.to(() => ReceivePage(
                        chain: chain,
                      ));
                  // Get.to(() => QRCreationPage(
                  //       qrData: axcWalletData.mappedWallet[chain]!,
                  //       isRecovery: false,
                  //     ));
                },
                child: SizedBox(
                  height: width,
                  width: width,
                  child: Obx(
                    () => axcWalletData.mappedWallet[chain] == null
                        ? Spinner(
                            alt: true,
                            color: Colors.white,
                          )
                        : QrImage(
                            data: axcWalletData.mappedWallet[chain]!,
                            foregroundColor: Colors.white,
                          ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    axcWalletData.mappedWallet[chain] ?? "Fetching wallet",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          IconButton(
            onPressed: () {
              if (axcWalletData.wallet.value.swap == null) {
                CommonWidgets.snackBar("Wait for the wallet to load");
                return;
              }
              Clipboard.setData(
                  ClipboardData(text: axcWalletData.mappedWallet[chain]));
              CommonWidgets.snackBar(axcWalletData.mappedWallet[chain]!,
                  copyMode: true);
            },
            icon: Icon(Icons.copy),
            color: Colors.white,
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(8),
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
          SizedBox(width: Get.width, child: chainWidget()),
          SizedBox(
            height: 8,
          ),
          addressItem(chain),
        ],
      ),
    );
  }
}
