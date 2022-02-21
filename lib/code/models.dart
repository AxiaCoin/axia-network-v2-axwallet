import 'package:flutter/material.dart';

class OnboardItemData {
  String title;
  String subtitle;
  IconData icon;
  OnboardItemData(this.title, this.subtitle, this.icon);
}

class CoinData {
  String name;
  String unit;
  double value;
  String change;
  bool selected = true;
  String address = "KxQ4qn3TsZ3ZpeAhTa38VovPgYLchxbZfNvs5zioK7zZQYMKnyq5";
  CoinData(this.name, this.unit, this.value, this.change);
}

enum SearchMode {
  customize,
  send,
  receive,
  buy,
  swap
}

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