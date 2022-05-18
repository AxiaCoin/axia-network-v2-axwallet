import 'package:flutter/material.dart';

import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';

class NetworkSwitcher extends StatefulWidget {
  final Function(bool) onChanged;
  const NetworkSwitcher({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NetworkSwitcher> createState() => _NetworkSwitcherState();
}

class _NetworkSwitcherState extends State<NetworkSwitcher> {
  void toggleNetworkType(bool value) async {
    // print("restart");
    // StorageService.instance.networkclearTokens();
    // setState(() {
    StorageService.instance.updateNetworkType(value);
    network = value ? "TESTNET" : "MAINNET";
    // });
    // print("center");
    // CommonWidgets.waitDialog(text: "Network Switching");
    // Future.delayed(Duration(seconds: 3), () => Restart.restartApp());
    services.updateBalances();
    // print("end");
    widget.onChanged(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        toggleNetworkType(!StorageService.instance.isTestNet);
      },
      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            child: Container(
              width: 20,
              height: 20,
              margin: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: StorageService.instance.isTestNet ? Colors.amber : tickerGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Text(
            StorageService.instance.isTestNet ? "TestNet" : "MainNet",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
