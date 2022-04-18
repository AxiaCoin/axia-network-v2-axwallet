import 'package:wallet/code/models.dart';

abstract class Currency {
  CoinData coinData = CoinData.dummyCoin(0);

  CryptoWallet getWallet() => CryptoWallet.dummyWallet();

  Future<double> getBalance(List<String> address);

  Future sendTransaction(double amount, String receiveraddress);

  Future<TransactionListModel> getTransactions(
      {required int offset, required int limit});
}
