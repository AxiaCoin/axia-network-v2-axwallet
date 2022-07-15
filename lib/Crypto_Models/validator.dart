import 'dart:convert';

import 'package:flutter/foundation.dart';

class ValidatorItem {
  String txID;
  String nodeID;
  String startTime;
  String endTime;
  String stakeAmount;
  String nominationFee;
  List<Nominator> nominators;
  ValidatorItem({
    required this.txID,
    required this.nodeID,
    required this.startTime,
    required this.endTime,
    required this.stakeAmount,
    required this.nominationFee,
    required this.nominators,
  });

  ValidatorItem copyWith({
    String? txID,
    String? nodeID,
    String? startTime,
    String? endTime,
    String? stakeAmount,
    String? nominationFee,
    List<Nominator>? nominators,
  }) {
    return ValidatorItem(
      txID: txID ?? this.txID,
      nodeID: nodeID ?? this.nodeID,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stakeAmount: stakeAmount ?? this.stakeAmount,
      nominationFee: nominationFee ?? this.nominationFee,
      nominators: nominators ?? this.nominators,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'txID': txID,
      'nodeID': nodeID,
      'startTime': startTime,
      'endTime': endTime,
      'stakeAmount': stakeAmount,
      'nominationFee': nominationFee,
      'nominators': nominators.map((x) => x.toMap()).toList(),
    };
  }

  factory ValidatorItem.fromMap(Map<String, dynamic> map) {
    return ValidatorItem(
      txID: map['txID'] ?? '',
      nodeID: map['nodeID'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      stakeAmount: map['stakeAmount'] ?? '',
      nominationFee: map['nominationFee'] ?? '',
      nominators: map['nominators'] != null
          ? List<Nominator>.from(
              map['nominators']?.map((x) => Nominator.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ValidatorItem.fromJson(String source) =>
      ValidatorItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ValidatorItem(txID: $txID, nodeID: $nodeID, startTime: $startTime, endTime: $endTime, stakeAmount: $stakeAmount, nominationFee: $nominationFee, nominators: $nominators)';
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
        other.nominationFee == nominationFee &&
        listEquals(other.nominators, nominators);
  }

  @override
  int get hashCode {
    return txID.hashCode ^
        nodeID.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        stakeAmount.hashCode ^
        nominationFee.hashCode ^
        nominators.hashCode;
  }
}

class Nominator {
  String txID;
  String nodeID;
  String startTime;
  String endTime;
  String stakeAmount;
  String potentialReward;
  RewardOwner rewardOwner;
  Nominator({
    required this.txID,
    required this.nodeID,
    required this.startTime,
    required this.endTime,
    required this.stakeAmount,
    required this.potentialReward,
    required this.rewardOwner,
  });

  Nominator copyWith({
    String? txID,
    String? nodeID,
    String? startTime,
    String? endTime,
    String? stakeAmount,
    String? potentialReward,
    RewardOwner? rewardOwner,
  }) {
    return Nominator(
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

  factory Nominator.fromMap(Map<String, dynamic> map) {
    return Nominator(
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

  factory Nominator.fromJson(String source) =>
      Nominator.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Nominators(txID: $txID, nodeID: $nodeID, startTime: $startTime, endTime: $endTime, stakeAmount: $stakeAmount, potentialReward: $potentialReward, rewardOwner: $rewardOwner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Nominator &&
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
