import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wallet/Crypto_Models/unspent_model.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
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
    coinType: isTestNet ? 1 : 0,
    rate: 1.23,
    change: "1",
    selected: true,
  );

  @override
  CryptoWallet getWallet() {
    HDWallet hdWallet = services.hdWallet!;
    hdWallet.network = isTestNet ? testnet : bitcoin;
    var wallet = hdWallet.derivePath("m/44'/${coinData.coinType}'/0'/0/0");
    ECPair keyPair = ECPair.fromWIF(wallet.wif.toString());
    keyPair.network = isTestNet ? testnet : bitcoin;
    print("Bitcoin Address:${wallet.address}");
    print(wallet.privKey);
    print(wallet.pubKey);
    print(keyPair);
    return CryptoWallet(
      address: wallet.address!,
      privKey: wallet.privKey!,
      pubKey: wallet.pubKey!,
      keyPair: keyPair,
    );
  }

  @override
  getBalance(List<String> address) async {
    var response = await http.get(
      Uri.parse(
          "$ipAddress/address/balance?network=$network&addresses=$address&currency=${coinData.unit}"),
      headers: {
        'Authorization': 'Bearer ' + StorageService.instance.authToken!
      },
    );
    print(response.body);
    var amount = jsonDecode(response.body);
    print(amount["data"]);
    var data = amount["data"];
    var bal = data[0];
    var b = bal["confirmed"];
    print(b);
    return b;
  }

  @override
  getTransactions(String address) async {
    try {
      String url = ipAddress +
          'address/$address/transactions?network=$network&currency=${coinData.unit}&offset=0&limit=10&sort=asc';
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ' + StorageService.instance.authToken!
        },
      );
      if (response.statusCode == 200) {
        print("success");
        Map val = jsonDecode(response.body);
        print("result: $val");
        return val.values;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices()
              .getAuthToken(sessionId: sessionID, deviceId: deviceID);
          if (result["success"]) {
            String authToken = result["data"]["authToken"];
            StorageService.instance.updateAuthToken(authToken);
            return getTransactions(address);
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

  @override
  importWallet() {
    throw UnimplementedError();
  }

  Future sendTransaction(double amount, String recieveraddress) async {
    CryptoWallet wallet = getWallet();
    String address = wallet.address;
    ECPair keypairtemp = wallet.keyPair!;
    try {
      print("Start");
      final txb =
          new TransactionBuilder(network: isTestNet ? testnet : bitcoin);
      BTCglobalList unspent = await getunspentamount(amount, address);
      print("Unspent is=$unspent");
      print("got unspent");
      var availBal = await getBalance([address]);
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
        txb.addOutput(recieveraddress, (amount.toInt() - estimated));
      } else {
        txb.addOutput(recieveraddress, (amount.toInt()));
      }
      if ((unspent.amount! - amount) != 0 && amount != availBal) {
        txb.addOutput(
            address, ((unspent.amount! - amount)).toInt() - estimated);
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
      // Map format = {
      //   "network": "TESTNET",
      //   "currency": "BTC",
      //   "fromAddress": address,
      //   "toAddress": recieveraddress,
      //   "amount": amount,
      //   "signedRawTransaction": hexbuild
      // };
      // var formatbody = json.encode(format);
      // var response = await http.post(
      //     Uri.parse("http://13.235.53.197:3000/transaction/send"),
      //     headers: {
      //       'Authorization': 'Bearer ' + StorageService.instance.authToken!
      //       'Content-Type': 'application/json'
      //     },
      //     body: formatbody);
      // if (response.statusCode == 200) {
      //   print("success");
      //   Map val = jsonDecode(response.body);
      //   print("result: $val");
      //   return val;
      // } else {
      //   print("unsuccessful");
      //   Map val = jsonDecode(response.body);
      //   print("error: $val");
      //   if (val.toString().contains("Auth Token is invalid")) {
      //     String sessionID = StorageService.instance.sessionID!;
      //     String deviceID = StorageService.instance.deviceID!;
      //     var result = await APIServices()
      //         .getAuthToken(sessionId: sessionID, deviceId: deviceID);
      //     if (result["success"]) {
      //       String authToken = result["data"]["authToken"];
      //       StorageService.instance.updateAuthToken(authToken);
      //       return sendTransaction(
      //           amount, keypairtemp, address, recieveraddress);
      //     }
      //     return;
      //   }
      //   CommonWidgets.snackBar(val["errors"].toString(), duration: 5);
      //   return val;
      // }
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
        Uri.parse(
            "$ipAddress$walletAddress/unspents?currency=${coinData.unit}&network=$network"),
        headers: {
          'Authorization': 'Bearer ' + StorageService.instance.authToken!
        },
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
              BTCglobalList sxn = BTCglobalList(
                  amount: val.data!.list![i].value!.toDouble(),
                  list: val.data!.list! as List<ListElement>);
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
          } else if ((txn.amount == amount) &&
              (val.data!.list!.length - 1 == i)) {
            return txn;
          }
        }
        return txn;
      } else {
        print("unsuccessful");
        Map val = jsonDecode(response.body);
        print("error: $val");
        if (val.toString().contains("Auth Token is invalid")) {
          String sessionID = StorageService.instance.sessionID!;
          String deviceID = StorageService.instance.deviceID!;
          var result = await APIServices()
              .getAuthToken(sessionId: sessionID, deviceId: deviceID);
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
