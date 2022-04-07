import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:coinslib/coinslib.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet/code/services.dart';

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
    var wallet = hdWallet.derivePath("m/44'/${coinData.coinType}'/0'/0/0");
    // coinData.address = wallet.address!;
    // coinData.pubKey = "${wallet.pubKey}";
    // coinData.privKey = "${wallet.privKey}";
    // print(coinData.address);
    // print(coinData.privKey);
    // print(coinData.pubKey);
    return CryptoWallet(
      address: wallet.address!,
      privKey: wallet.privKey!,
      pubKey: wallet.pubKey!,
    );
  }

  @override
  getBalance() {
    // TODO: implement getBalance
    throw UnimplementedError();
  }

  @override
  getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  importWallet() {
    // TODO: implement importWallet
    throw UnimplementedError();
  }

  @override
  sendTransaction() {
    // TODO: implement sendTransaction
    throw UnimplementedError();
  }
}
