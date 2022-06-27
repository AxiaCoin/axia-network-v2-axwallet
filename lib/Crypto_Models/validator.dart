import 'dart:convert';

import 'package:flutter/foundation.dart';

class ValidatorItem {
  String txID;
  String nodeID;
  String startTime;
  String endTime;
  String stakeAmount;
  String delegationFee;
  List delegators;
  ValidatorItem({
    required this.txID,
    required this.nodeID,
    required this.startTime,
    required this.endTime,
    required this.stakeAmount,
    required this.delegationFee,
    required this.delegators,
  });

  ValidatorItem copyWith({
    String? txID,
    String? nodeID,
    String? startTime,
    String? endTime,
    String? stakeAmount,
    String? delegationFee,
    List? delegators,
  }) {
    return ValidatorItem(
      txID: txID ?? this.txID,
      nodeID: nodeID ?? this.nodeID,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stakeAmount: stakeAmount ?? this.stakeAmount,
      delegationFee: delegationFee ?? this.delegationFee,
      delegators: delegators ?? this.delegators,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'txID': txID,
      'nodeID': nodeID,
      'startTime': startTime,
      'endTime': endTime,
      'stakeAmount': stakeAmount,
      'delegationFee': delegationFee,
      'delegators': delegators,
    };
  }

  factory ValidatorItem.fromMap(Map<String, dynamic> map) {
    return ValidatorItem(
      txID: map['txID'] ?? '',
      nodeID: map['nodeID'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      stakeAmount: map['stakeAmount'] ?? '',
      delegationFee: map['delegationFee'] ?? '',
      delegators: map['delegators'] != null ? List.from(map['delegators']) : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ValidatorItem.fromJson(String source) =>
      ValidatorItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ValidatorItem(txID: $txID, nodeID: $nodeID, startTime: $startTime, endTime: $endTime, stakeAmount: $stakeAmount, delegationFee: $delegationFee, delegators: $delegators)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValidatorItem &&
        other.txID == txID &&
        other.nodeID == nodeID &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.stakeAmount == stakeAmount &&
        other.delegationFee == delegationFee &&
        other.delegators == delegators;
  }

  @override
  int get hashCode {
    return txID.hashCode ^
        nodeID.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        stakeAmount.hashCode ^
        delegationFee.hashCode ^
        delegators.hashCode;
  }
}
