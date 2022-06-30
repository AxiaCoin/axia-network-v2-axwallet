import 'dart:convert';

enum Chain {
  Swap, // X
  Core, // P
  AX, // C
}

class AXCWallet {
  String? X;
  String? P;
  String? C;
  List<String>? allX;
  List<String>? allP;
  AXCWallet({
    this.X,
    this.P,
    this.C,
    this.allX,
    this.allP,
  });

  Map<String, dynamic> toMap() {
    return {
      'X': X,
      'P': P,
      'C': C,
      'allX': allX,
      'allP': allP,
    };
  }

  factory AXCWallet.fromMap(Map<String, dynamic> map) {
    return AXCWallet(
      X: map['X'],
      P: map['P'],
      C: map['C'],
      allX: List<String>.from(map['allX']),
      allP: List<String>.from(map['allP']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AXCWallet.fromJson(String source) =>
      AXCWallet.fromMap(json.decode(source));
}

class AXCBalance {
  String? X;
  String? P;
  String? C;
  String? staked;
  AXCBalance({
    this.X,
    this.P,
    this.C,
    this.staked,
  });

  Map<String, dynamic> toMap() {
    return {
      'X': X,
      'P': P,
      'C': C,
      'staked': staked,
    };
  }

  factory AXCBalance.fromMap(Map<String, dynamic> map) {
    return AXCBalance(
      X: map['X'],
      P: map['P'],
      C: map['C'],
      staked: map['staked'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AXCBalance.fromJson(String source) =>
      AXCBalance.fromMap(json.decode(source));
}
