import 'dart:convert';

import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';

class OnboardItemData {
  String title;
  String subtitle;
  IconData icon;
  OnboardItemData(this.title, this.subtitle, this.icon);
}

class UserModel {
  String userId;
  String firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? phoneCode;
  bool verified;
  bool blocked;
  bool userForgetPass;
  String otpId;
  String createdAt;
  String updatedAt;
  UserModel({
    required this.userId,
    required this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.phoneCode,
    required this.verified,
    required this.blocked,
    required this.userForgetPass,
    required this.otpId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.none() {
    return UserModel(
      userId: '',
      firstName: '',
      lastName: null,
      email: null,
      phoneNumber: null,
      phoneCode: null,
      verified: false,
      blocked: false,
      userForgetPass: false,
      otpId: '',
      createdAt: '',
      updatedAt: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'phoneCode': phoneCode,
      'verified': verified,
      'blocked': blocked,
      'userForgetPass': userForgetPass,
      'otpId': otpId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      phoneCode: map['phoneCode'],
      verified: map['verified'] ?? false,
      blocked: map['blocked'] ?? false,
      userForgetPass: map['userForgetPass'] ?? false,
      otpId: map['otpId'] ?? '',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}

class CoinData {
  String name;
  String unit;
  int coinType;
  int smallestUnit;
  double existential;
  String prefix;
  double rate;
  String change;
  bool selected;
  CoinData({
    required this.name,
    required this.unit,
    required this.coinType,
    required this.smallestUnit,
    this.existential = 1,
    required this.prefix,
    this.rate = 1,
    this.change = "",
    this.selected = false,
  });

  factory CoinData.dummyCoin(int i) {
    return CoinData(
      name: "Coin $i",
      unit: "XCN$i",
      prefix: "",
      coinType: 1,
      smallestUnit: 1000,
      existential: 1,
      rate: 123.45,
      change: "1.2",
      selected: false,
    );
  }
}

class HDWalletInfo {
  String seed;
  String name;
  String mnemonic;
  HDWallet? hdWallet;
  HDWalletInfo({
    required this.seed,
    required this.name,
    required this.mnemonic,
    this.hdWallet,
  });

  Map<String, dynamic> toMap() {
    return {
      'seed': seed,
      'name': name,
      'mnemonic': mnemonic,
    };
  }

  factory HDWalletInfo.fromMap(Map<String, dynamic> map) {
    return HDWalletInfo(
      seed: map['seed'] ?? '',
      name: map['name'] ?? '',
      mnemonic: map['mnemonic'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HDWalletInfo.fromJson(String source) => HDWalletInfo.fromMap(json.decode(source));
}

class CryptoWallet {
  String address;
  String privKey;
  String pubKey;
  ECPair? keyPair;
  CryptoWallet({
    required this.address,
    required this.privKey,
    required this.pubKey,
    this.keyPair,
  });

  factory CryptoWallet.dummyWallet() {
    return CryptoWallet(
      address: "",
      privKey: "",
      pubKey: "",
      keyPair: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'privKey': privKey,
      'pubKey': pubKey,
    };
  }

  factory CryptoWallet.fromMap(Map<String, dynamic> map) {
    return CryptoWallet(
      address: map['address'] ?? '',
      privKey: map['privKey'] ?? '',
      pubKey: map['pubKey'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CryptoWallet.fromJson(String source) => CryptoWallet.fromMap(json.decode(source));
}

enum SearchMode { customize, send, receive, buy, swap }

class DAppsTile {
  String title;
  String subtitle;
  Widget? image;
  String url;

  DAppsTile(this.title, this.subtitle, this.image, this.url);
}

// class RecoveryPhrase {
//   int index;
//   String word;
//   bool selected;
//   RecoveryPhrase(this.index, this.word, {this.selected = true});
// }

class TransactionItem {
  String from;
  String to;
  double amount;
  DateTime time;
  String hash;
  double fee;
  TransactionItem({
    required this.from,
    required this.to,
    required this.amount,
    required this.time,
    required this.hash,
    required this.fee,
  });
}

class TransactionListModel {
  int total;
  List<TransactionItem> transactionList;
  TransactionListModel({
    required this.total,
    required this.transactionList,
  });
}

class TransactionRequestParams {
  final int offset;
  final int limit;
  TransactionRequestParams({
    required this.offset,
    required this.limit,
  });
}
