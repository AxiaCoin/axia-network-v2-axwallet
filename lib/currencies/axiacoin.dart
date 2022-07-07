import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:coinslib/coinslib.dart' as coinslib;
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/code/utils.dart';
import 'package:web3dart/web3dart.dart';

class AXIACoin implements Currency {
  final rpcURLTest =
      "https://1.p2p-v2.testnet.axiacoin.network:443/ext/bc/AX/rpc"; // "https://rpc-v2.test.axiacoin.network";
  final rpcURLMain =
      "https://1.p2p-v2.mainnet.axiacoin.network:443/ext/bc/AX/rpc"; // "https://rpc-v2.test.axiacoin.network";
  final maxGas = 21000;

  @override
  CoinData coinData = CoinData(
    name: "AXIA Coin",
    unit: "AXC",
    prefix: "0x",
    smallestUnit: pow(10, 18).toInt(), //1000000000000000000 wei
    coinType: 60,
    rate: 13.43,
    change: "1",
    selected: true,
  );

  @override
  CryptoWallet getWallet() {
    WalletData walletData = Get.find();
    coinslib.HDWallet hdWallet = walletData.hdWallet!.value;
    var wallet = hdWallet.derivePath("m/44'/${60}'/0'/0/0");
    // var asd = walletKey.currentState.appService.store.account.newAccount.;
    // print(asd);
    var ethWallet =
        EthPrivateKey.fromHex("${coinData.prefix}${wallet.privKey}");
    return CryptoWallet(
        address: ethWallet.address.hexEip55,
        privKey: "${coinData.prefix}${wallet.privKey}",
        pubKey: "${coinData.prefix}${wallet.pubKey}",
        keyPair: null);
  }

  @override
  Future<double> getBalance({String? address}) async {
    if (true) return 0;
    var amount = await APIServices()
        .getBalance([address ?? getWallet().address], coinData.unit);
    // print(amount);
    double balance =
        amount["data"].first["confirmed"].toDouble() / coinData.smallestUnit;
    // print(amount);
    // print("balance is ${balance.toStringAsFixed(6)} ${coinData.unit}");
    return balance;
  }

  @override
  Future<TransactionListModel> getTransactions(
      {required int offset, required int limit}) async {
    var response = await APIServices().getTransactions(
      getWallet().address,
      coinData.unit,
      offset: offset,
      limit: limit,
    );
    var data = response["data"]["list"];
    int total = response["data"]["total"];
    print(total);
    List<TransactionItem> transactions = [];
    print("data is $data");

    data.forEach((e) {
      transactions.add(
        TransactionItem(
          from: e["from"],
          to: e["to"],
          amount: e["value"] / coinData.smallestUnit,
          time: DateTime.parse(e["blockTime"]),
          hash: e["txid"],
          fee: (e["fee"]) / coinData.smallestUnit,
        ),
      );
    });
    // print(response);
    return TransactionListModel(total: total, transactionList: transactions);
  }

  @override
  Future sendTransaction(double amount, String receiverAddress) async {
    amount = amount * coinData.smallestUnit;
    var ethWallet = EthPrivateKey.fromHex(getWallet().privKey);
    print("address is ${ethWallet.address.hexEip55}");
    print("amount is $amount");
    var client = Web3Client(
        StorageService.instance.isTestNet ? rpcURLTest : rpcURLMain, Client());
    var gasPrice = await client.getGasPrice();
    var signedData = await client.signTransaction(
      ethWallet,
      Transaction(
        to: EthereumAddress.fromHex(receiverAddress),
        gasPrice: gasPrice,
        maxGas: maxGas,
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.from(amount)),
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );
    var hex = coinData.prefix + HexEncoder().convert(signedData);
    print("signed hex is $hex");
    Map body = {
      "network": network,
      "currency": coinData.unit,
      "fromAddress": getWallet().address,
      "toAddress": receiverAddress,
      "amount": amount,
      "signedRawTransaction": hex,
      // "blockHash": "thisistheblockhash",
    };
    var response = await APIServices().sendTransaction(body);
    print(response);
    return response;
  }

  @override
  Future<double> getEstimatedFees({String? asd}) async {
    var client = Web3Client(
        StorageService.instance.isTestNet ? rpcURLTest : rpcURLMain, Client());
    var gasPrice = await client.getGasPrice();
    print(gasPrice.getInWei);
    var fees = (gasPrice.getInWei * BigInt.from(maxGas)) /
        BigInt.from(coinData.smallestUnit);
    return fees;
  }
}
