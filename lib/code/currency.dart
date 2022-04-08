import 'package:wallet/code/models.dart';

abstract class Currency {
  CoinData coinData = CoinData.dummyCoin(0);

  CryptoWallet getWallet() => CryptoWallet.dummyWallet();

  getBalance(List<String> address) => null;

  sendTransaction(double amount, String receiveraddress) async => null;

  getTransactions({required int offset, required int limit}) => null;
}
