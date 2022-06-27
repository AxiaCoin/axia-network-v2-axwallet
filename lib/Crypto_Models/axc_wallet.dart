import 'dart:convert';

class AXCWallet {
  String? X;
  String? P;
  String? C;
  AXCWallet({
    this.X,
    this.P,
    this.C,
  });

  Map<String, dynamic> toMap() {
    return {
      'X': X,
      'P': P,
      'C': C,
    };
  }

  factory AXCWallet.fromMap(Map<String, dynamic> map) {
    return AXCWallet(
      X: map['X'],
      P: map['P'],
      C: map['C'],
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
  AXCBalance({
    this.X,
    this.P,
    this.C,
  });

  Map<String, dynamic> toMap() {
    return {
      'X': X,
      'P': P,
      'C': C,
    };
  }

  factory AXCBalance.fromMap(Map<String, dynamic> map) {
    return AXCBalance(
      X: map['X'],
      P: map['P'],
      C: map['C'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AXCBalance.fromJson(String source) =>
      AXCBalance.fromMap(json.decode(source));
}
