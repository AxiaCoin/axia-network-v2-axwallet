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

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}

class CoinData {
  String name;
  String unit;
  int coinType;
  double rate;
  String change;
  bool selected;
  CoinData({
    required this.name,
    required this.unit,
    required this.coinType,
    this.rate = 1,
    this.change = "",
    this.selected = false,
  });

  factory CoinData.dummyCoin(int i) {
    return CoinData(
      name: "Coin $i",
      unit: "XCN$i",
      coinType: 1,
      rate: 123.45,
      change: "1.2",
      selected: false,
    );
  }
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
    required this.keyPair,
  });

  factory CryptoWallet.dummyWallet() {
    return CryptoWallet(
      address: "",
      privKey: "",
      pubKey: "",
      keyPair: null,
    );
  }
}

enum SearchMode { customize, send, receive, buy, swap }

class DAppsTile {
  String title;
  String subtitle;
  Widget image;
  String url;

  DAppsTile(this.title, this.subtitle, this.image, this.url);
}

// class RecoveryPhrase {
//   int index;
//   String word;
//   bool selected;
//   RecoveryPhrase(this.index, this.word, {this.selected = true});
// }