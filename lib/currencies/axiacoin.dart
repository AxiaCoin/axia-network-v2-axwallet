import 'dart:math';

import 'package:substrate_sdk/substrate_sdk.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';

class AXIACoin implements Currency {
  String oldAddress = "";

  @override
  CoinData coinData = CoinData(
    name: "AXIA Coin",
    unit: "AXC",
    prefix: "",
    smallestUnit: pow(10, 10).toInt(), //10000000000 pico (i guess)
    coinType: 1,
    rate: 1.23,
    change: "1",
    selected: true,
  );

  @override
  CryptoWallet getWallet() {
    SubstrateApi substrateApi = services.substrateSDK.api!;
    if (oldAddress !=
        StorageService.instance.getSubstrateWallet(coinData.unit).address) {
      substrateApi.basic
          .getWallet(mnemonic: StorageService.instance.readMnemonic()!)
          .then((value) {
        print("get wallet is ");
        print(value);
        var data = CryptoWallet.fromMap(value);
        StorageService.instance.updateSubstrateWallets(coinData.unit, data);
        oldAddress = value["address"];
      });
    }
    return StorageService.instance.getSubstrateWallet(coinData.unit);
  }

  @override
  Future<double> getBalance(List<String> address) async {
    // var amount =
    //     await APIServices().getBalance([getWallet().address], coinData.unit);
    // double balance = amount["data"].first["confirmed"];
    // return balance;
    return 1.23;
  }

  @override
  Future<TransactionListModel> getTransactions(
      {required int offset, required int limit}) async {
    await Future.delayed(Duration(seconds: 1));
    return TransactionListModel(
      total: 1,
      transactionList: [
        TransactionItem(
            amount: 0.123,
            from: "asdf",
            to: "fdsa",
            hash: "0x1234567890",
            fee: 0.00000123,
            time: DateTime.now())
      ],
    );
  }

  @override
  Future sendTransaction(double amount, String receiveraddress) async {
    amount = amount * coinData.smallestUnit;
    SubstrateApi substrateApi = services.substrateSDK.api!;
    bool submit = false;
    var res = await substrateApi.basic.signTransaction(
      mnemonic: StorageService.instance.readMnemonic()!,
      dest: receiveraddress,
      amount: amount,
      submit: submit,
      unit: coinData.unit,
    );
    var data = submit ? res["txHash"] : res["signedTX"];
    print(data);
  }
}
