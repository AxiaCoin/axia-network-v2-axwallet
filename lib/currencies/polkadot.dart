import 'dart:math';
import 'package:substrate_sdk/substrate_sdk.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';

class Polkadot implements Currency {
  String oldAddress = "abcdf";

  @override
  CoinData coinData = CoinData(
    name: "Polkadot",
    unit: "DOT",
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
      try {
        substrateApi.basic
            .getWallet(mnemonic: StorageService.instance.readMnemonic()!)
            .then((value) {
          print("get wallet is ");
          print(value);
          var data = CryptoWallet.fromMap(value);
          StorageService.instance.updateSubstrateWallets(coinData.unit, data);
          oldAddress = value["address"];
        });
      } catch (e) {
        print("error:$e");
      }
    }
    // print(
    //     "dot: ${StorageService.instance.getSubstrateWallet(coinData.unit).address}");
    return StorageService.instance.getSubstrateWallet(coinData.unit);
  }

  @override
  Future<double> getBalance(List<String> address) async {
    var amount =
        await APIServices().getBalance([getWallet().address], coinData.unit);
    var balance = amount["data"].first["confirmed"];
    return balance.toDouble();
    // return 1.23;
  }

  @override
  Future<TransactionListModel> getTransactions(
      {required int offset, required int limit}) async {
    var response = await APIServices().getPlatformTransactions(
      getWallet().address,
      coinData.unit,
      offset: offset,
      limit: limit,
    );
    // print(response);
    var data = response["data"]["list"];
    int total = response["data"]["total"];
    List<TransactionItem> transactions = [];
    // print("data is $data");
    data.forEach((e) {
      transactions.add(
        TransactionItem(
          from: e["fromAddress"],
          to: e["toAddress"],
          amount: ((double.parse(e["amount"])) / coinData.smallestUnit),
          time: DateTime.parse(e["createdAt"]),
          hash: e["txnHash"],
          // fee: e["fee"] / coinData.smallestUnit,
          fee: 0.01,
        ),
      );
    });
    return TransactionListModel(total: total, transactionList: transactions);
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
    var hex = submit ? res["txHash"] : res["signedTX"];
    print(hex);
    Map body = {
      "network": network,
      "currency": coinData.unit,
      "fromAddress": getWallet().address,
      "toAddress": receiveraddress,
      "amount": amount,
      "signedRawTransaction": hex
    };
    try {
      var response = await APIServices().sendTransaction(body);
      print(response.toJson());
      return response;
    } catch (e) {
      print(e);
    }
  }
}
