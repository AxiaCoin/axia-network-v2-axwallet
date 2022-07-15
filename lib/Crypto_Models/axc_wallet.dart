import 'dart:convert';

import 'package:wallet/currencies/axiacoin.dart';

enum Chain {
  Swap, // X
  Core, // P
  AX, // C
}

class AXCWallet {
  String? swap;
  String? core;
  String? ax;
  List<String>? allSwap;
  List<String>? allCore;
  AXCWallet({
    this.swap,
    this.core,
    this.ax,
    this.allSwap,
    this.allCore,
  });

  Map<String, dynamic> toMap() {
    return {
      'swap': swap,
      'core': core,
      'ax': ax,
      'allSwap': allSwap,
      'allCore': allCore,
    };
  }

  factory AXCWallet.fromMap(Map<String, dynamic> map) {
    return AXCWallet(
      swap: map['swap'],
      core: map['core'],
      ax: map['ax'],
      allSwap: List<String>.from(map['allSwap']),
      allCore: List<String>.from(map['allCore']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AXCWallet.fromJson(String source) =>
      AXCWallet.fromMap(json.decode(source));
}

class AXCBalance {
  String? swap;
  String? core;
  String? ax;
  String? staked;
  AXCBalance({
    this.swap,
    this.core,
    this.ax,
    this.staked,
  });

  Map<String, dynamic> toMap() {
    return {
      'swap': swap,
      'core': core,
      'ax': ax,
      'staked': staked,
    };
  }

  factory AXCBalance.fromMap(Map<String, dynamic> map) {
    return AXCBalance(
      swap: map['swap'].replaceAll(",", ""),
      core: map['core'].replaceAll(",", ""),
      ax: map['ax'].replaceAll(",", ""),
      staked: map['staked'].replaceAll(",", ""),
    );
  }

  String toJson() => json.encode(toMap());

  factory AXCBalance.fromJson(String source) =>
      AXCBalance.fromMap(json.decode(source));

  getTotalBalance({bool inUSD = true}) {
    List chains = [swap, core, ax, staked];
    double total = 0.0;
    chains.forEach((e) {
      total += double.parse(e ?? "0");
    });
    return total * (inUSD ? AXIACoin().coinData.rate : 1);
  }
}
