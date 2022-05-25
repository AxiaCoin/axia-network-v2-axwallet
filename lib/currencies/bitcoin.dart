import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/Crypto_Models/unspent_model.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/models.dart';
import 'package:coinslib/coinslib.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/storage.dart';
import 'package:wallet/widgets/common.dart';

class BTCglobalList {
  List<ListElement>? list;
  double? amount = 0;

  BTCglobalList({this.amount, this.list});
  List<ListElement>? get txn {
    return list;
  }
}

class Bitcoin implements Currency {
  @override
  CoinData coinData = CoinData(
    name: "Bitcoin",
    unit: "BTC",
    prefix: "",
    smallestUnit: pow(10, 8).toInt(), //100000000 satoshi
    coinType: StorageService.instance.isTestNet ? 1 : 0,
    rate: 29220.60,
    change: "1",
    selected: true,
  );

  @override
  CryptoWallet getWallet() {
    WalletData walletData = Get.find();
    HDWallet hdWallet = walletData.hdWallet!.value;
    hdWallet.network = StorageService.instance.isTestNet ? testnet : bitcoin;
    var wallet = hdWallet.derivePath("m/44'/${0}'/0'/0/0");
    ECPair keyPair = ECPair.fromWIF(wallet.wif.toString());
    keyPair.network = StorageService.instance.isTestNet ? testnet : bitcoin;
    // print("btc: ${wallet.address}");
    return CryptoWallet(
      address: wallet.address!,
      privKey: wallet.privKey!,
      pubKey: wallet.pubKey!,
      keyPair: keyPair,
    );
  }

  @override
  Future<double> getBalance({String? address}) async {
    var amount = await APIServices().getBalance([address ?? getWallet().address], coinData.unit);
    var bal = amount["data"].first["confirmed"];
    return bal / coinData.smallestUnit;
  }

  @override
  Future<TransactionListModel> getTransactions({required int offset, required int limit}) async {
    var response = await APIServices().getTransactions(
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
      List inputs = e["inputs"];
      List outputs = e["outputs"];
      bool isInput = false;
      inputs.forEach((element) {
        if (element["address"].toString().toLowerCase() == getWallet().address.toLowerCase()) {
          isInput = true;
        }
      });
      String fromAddress = isInput ? getWallet().address : inputs.first["address"];
      String toAddress = isInput ? outputs.first["address"] : getWallet().address;
      transactions.add(
        TransactionItem(
          from: fromAddress,
          fromTotal: inputs.length - 1,
          to: toAddress,
          toTotal: outputs.length - 1,
          amount: (e["outputs"][0]["value"]).toDouble() / coinData.smallestUnit,
          time: DateTime.fromMillisecondsSinceEpoch(e["time"] * 1000),
          hash: e["txid"],
          fee: e["fee"] / coinData.smallestUnit,
        ),
      );
    });
    return TransactionListModel(total: total, transactionList: transactions);
  }

  Future sendTransaction(double amount, String receiverAddress) async {
    CryptoWallet wallet = getWallet();
    String address = wallet.address;
    ECPair keypairtemp = wallet.keyPair!;
    try {
      print(amount);
      amount = amount * coinData.smallestUnit;
      print(amount);
      print("Start");
      final txb = new TransactionBuilder(network: StorageService.instance.isTestNet ? testnet : bitcoin);
      BTCglobalList unspent = await getunspentamount(amount, address);
      print("got unspent");
      var availBal = await getBalance();
      print(availBal);
      txb.setVersion(1);
      for (var i = 0; i < unspent.list!.length; i++) {
        txb.addInput(unspent.list![i].txid!, unspent.list![i].index!);
      }
      var noOutput = 0;
      if (amount == availBal) {
        noOutput = 1;
      } else {
        noOutput = 2;
      }
      var estimated = (180 * unspent.list!.length + noOutput * 34 + 10) * 10;
      print("estiated amount=$estimated");
      if (amount == availBal) {
        txb.addOutput(receiverAddress, (amount.toInt() - estimated));
      } else {
        txb.addOutput(receiverAddress, (amount.toInt()));
      }
      if ((unspent.amount! - amount) != 0 && amount != availBal) {
        txb.addOutput(address, ((unspent.amount! - amount)).toInt() - estimated);
      }
      print("something");
      try {
        for (var i = 0; i < unspent.list!.length; i++) {
          txb.sign(vin: i, keyPair: keypairtemp);
        }
      } catch (e) {
        print(e);
      }
      var hexbuild = txb.build().toHex();
      print("hexbuild: $hexbuild");
      // try {
      //   var response = await http.post(
      //       Uri.parse("https://blockstream.info/testnet/api/tx"),
      //       body: hexbuild);
      //   print(jsonDecode(response.body));
      //   return response;
      // } catch (e) {
      //   print(e);
      // }
      Map body = {
        "network": network,
        "currency": coinData.unit,
        "fromAddress": address,
        "toAddress": receiverAddress,
        "amount": amount,
        "signedRawTransaction": hexbuild
      };
      var response = await APIServices().sendTransaction(body);
      print(response.body);
    } on SocketException {
      return "No internet connection";
    } on HttpException {
      return "Couldn't find post URL";
    } on FormatException {
      return "Bad response format";
    } catch (e) {
      return "Server response:${e.toString()}";
    }
  }

  Future getunspentamount(double amount, String walletAddress) async {
    try {
      print("start");
      var response = await http.get(
        Uri.parse("$ipAddress\address/$walletAddress/unspents?currency=${coinData.unit}&network=$network"),
        headers: {'Authorization': 'Bearer ' + StorageService.instance.authToken!},
      );
      if (response.statusCode == 200) {
        print("success");
        Map res = jsonDecode(response.body);
        print("result: $res");
        var val = Unspent.fromJson(jsonDecode(response.body));
        BTCglobalList txn = BTCglobalList(list: [], amount: 0);
        for (var i = 0; i < val.data!.list!.length; i++) {
          if (val.data!.list![i].value! > amount) {
            try {
              BTCglobalList sxn =
                  BTCglobalList(amount: val.data!.list![i].value!.toDouble(), list: [val.data!.list![i]]);
              // sxn.list!.forEach((element) => print(element.toJson()));
              return sxn;
            } catch (e) {
              print(e);
            }
          } else {
            txn.list!.add(val.data!.list![i]);
            txn.amount = txn.amount! + val.data!.list![i].value!.toDouble();
          }
          if (txn.amount! > amount) {
            return txn;
          } else if ((txn.amount == amount) && (val.data!.list!.length - 1 == i)) {
            return txn;
          }
        }

        return txn;
      } else {
        print("unsuccessful yo");
        print("error: ${response.body}");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices().getAuthToken(sessionId: sessionID, deviceId: deviceID);
          if (result["success"]) {
            String authToken = result["data"]["authToken"];
            StorageService.instance.updateAuthToken(authToken);
            return getunspentamount(amount, walletAddress);
          }
          return;
        }
        CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
        return val;
      }
    } on SocketException {
      return "No internet connection";
    } on HttpException {
      return "Couldn't find URL";
    } on FormatException {
      return "Bad response format";
    } catch (e) {
      return "Server response:${e.toString()}";
    }
  }
}
