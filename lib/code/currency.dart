import 'package:flutter/material.dart';

import 'package:wallet/code/models.dart';

abstract class Currency {
  CoinData coinData = CoinData.dummyCoin(0);

  CryptoWallet getWallet() => CryptoWallet.dummyWallet();

  importWallet() => null;

  getBalance() => null;

  getTransactions() => null;

  sendTransaction() async => null;
}
