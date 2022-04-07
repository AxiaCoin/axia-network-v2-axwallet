import 'package:wallet/code/models.dart';

abstract class Currency {
  CoinData coinData = CoinData.dummyCoin(0);

  CryptoWallet getWallet() => CryptoWallet.dummyWallet();

  importWallet() => null;

  getBalance(List<String> address) => null;

  getTransactions(String address) => null;
}
