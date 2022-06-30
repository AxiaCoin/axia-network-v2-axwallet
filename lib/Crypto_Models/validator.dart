import 'dart:convert';

import 'package:flutter/foundation.dart';

class ValidatorItem {
  String txID;
  String nodeID;
  String startTime;
  String endTime;
  String stakeAmount;
  String delegationFee;
  List<Delegator> delegators;
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
    List<Delegator>? delegators,
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
      'delegators': delegators.map((x) => x.toMap()).toList(),
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
      delegators: map['delegators'] != null
          ? List<Delegator>.from(
              map['delegators']?.map((x) => Delegator.fromMap(x)))
          : [],
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
        listEquals(other.delegators, delegators);
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

class Delegator {
  String txID;
  String nodeID;
  String startTime;
  String endTime;
  String stakeAmount;
  String potentialReward;
  RewardOwner rewardOwner;
  Delegator({
    required this.txID,
    required this.nodeID,
    required this.startTime,
    required this.endTime,
    required this.stakeAmount,
    required this.potentialReward,
    required this.rewardOwner,
  });

  Delegator copyWith({
    String? txID,
    String? nodeID,
    String? startTime,
    String? endTime,
    String? stakeAmount,
    String? potentialReward,
    RewardOwner? rewardOwner,
  }) {
    return Delegator(
      txID: txID ?? this.txID,
      nodeID: nodeID ?? this.nodeID,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stakeAmount: stakeAmount ?? this.stakeAmount,
      potentialReward: potentialReward ?? this.potentialReward,
      rewardOwner: rewardOwner ?? this.rewardOwner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'txID': txID,
      'nodeID': nodeID,
      'startTime': startTime,
      'endTime': endTime,
      'stakeAmount': stakeAmount,
      'potentialReward': potentialReward,
      'rewardOwner': rewardOwner.toMap(),
    };
  }

  factory Delegator.fromMap(Map<String, dynamic> map) {
    return Delegator(
      txID: map['txID'] ?? '',
      nodeID: map['nodeID'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      stakeAmount: map['stakeAmount'] ?? '',
      potentialReward: map['potentialReward'] ?? '',
      rewardOwner: RewardOwner.fromMap(map['rewardOwner']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Delegator.fromJson(String source) =>
      Delegator.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Delegators(txID: $txID, nodeID: $nodeID, startTime: $startTime, endTime: $endTime, stakeAmount: $stakeAmount, potentialReward: $potentialReward, rewardOwner: $rewardOwner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Delegator &&
        other.txID == txID &&
        other.nodeID == nodeID &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.stakeAmount == stakeAmount &&
        other.potentialReward == potentialReward &&
        other.rewardOwner == rewardOwner;
  }

  @override
  int get hashCode {
    return txID.hashCode ^
        nodeID.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        stakeAmount.hashCode ^
        potentialReward.hashCode ^
        rewardOwner.hashCode;
  }
}

class RewardOwner {
  String locktime;
  String threshold;
  List<String> addresses;
  String potentialReward;
  RewardOwner({
    required this.locktime,
    required this.threshold,
    required this.addresses,
    required this.potentialReward,
  });

  RewardOwner copyWith({
    String? locktime,
    String? threshold,
    List<String>? addresses,
    String? potentialReward,
  }) {
    return RewardOwner(
      locktime: locktime ?? this.locktime,
      threshold: threshold ?? this.threshold,
      addresses: addresses ?? this.addresses,
      potentialReward: potentialReward ?? this.potentialReward,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locktime': locktime,
      'threshold': threshold,
      'addresses': addresses,
      'potentialReward': potentialReward,
    };
  }

  factory RewardOwner.fromMap(Map<String, dynamic> map) {
    return RewardOwner(
      locktime: map['locktime'] ?? '',
      threshold: map['threshold'] ?? '',
      addresses: List<String>.from(map['addresses']),
      potentialReward: map['potentialReward'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RewardOwner.fromJson(String source) =>
      RewardOwner.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RewardOwner(locktime: $locktime, threshold: $threshold, addresses: $addresses, potentialReward: $potentialReward)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RewardOwner &&
        other.locktime == locktime &&
        other.threshold == threshold &&
        listEquals(other.addresses, addresses) &&
        other.potentialReward == potentialReward;
  }

  @override
  int get hashCode {
    return locktime.hashCode ^
        threshold.hashCode ^
        addresses.hashCode ^
        potentialReward.hashCode;
  }
}
