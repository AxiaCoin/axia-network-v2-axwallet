// ignore_for_file: dead_code

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/constants.dart';
import 'package:intl/intl.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';

class Utils {
  Utils._();

  static List<ValidatorItem> filterValidators(List<ValidatorItem> data) {
    data.removeWhere((element) =>
        DateTime.fromMillisecondsSinceEpoch(int.parse(element.endTime) * 1000)
            .difference(DateTime.now())
            .inDays <
        minStakeDays);
    return data;
  }

  static double getStakingProgress(int start, int end, {double min = 0.01}) {
    int now = DateTime.now().millisecondsSinceEpoch;
    return max(min, ((now - start) / (end - start)));
  }

  static Future<bool> validateAddress(Chain source, String address) async {
    if (source == Chain.Swap || source == Chain.Core) {
      String chain = address.split('-').first;
      if (chain != source.name) {
        return false;
      }
    } else {
      if (address.substring(0, 2) != "0x") {
        return false;
      }
    }
    bool isValid =
        await services.axSDK.api!.utils.checkAddrValidity(address: address);
    return isValid;
  }
}

class FormatText {
  FormatText._();

  static String wordList(List<String> words) {
    String formatted = "";
    for (var i = 0; i < words.length; i++) {
      formatted += words[i] + (i != words.length - 1 ? " " : "");
    }
    return formatted;
  }

  static String roundOff(double input, {int maxDecimals = 9}) {
    var regex = RegExp(r"([.]*0+)(?!.*\d)");
    String text = input.toString();
    if (maxDecimals != 0) text = input.toStringAsFixed(maxDecimals);
    return text.toString().replaceAll(regex, "");
  }

  // static String temp(String input, double value) {
  //   double oneCurrencyUnit = 1/value;
  //   return roundOff(double.parse(input == "" ? "0" : input) * oneCurrencyUnit);
  // }

  static String exchangeValue(double from, double to, String input) {
    input = input == "" ? "0" : input;
    double exchangeValue = (to / from) * double.parse(input);
    return roundOff(exchangeValue);
    int decimalPlaces = 8;
    double formatted = ((exchangeValue * pow(10, decimalPlaces)).toInt()) /
        pow(10, decimalPlaces);
    bool isDecimalZero = formatted.toInt() * pow(10, decimalPlaces) ==
        (formatted * pow(10, decimalPlaces)).toInt();
    return isDecimalZero ? formatted.toStringAsFixed(0) : formatted.toString();
  }

  static String address(String input, {int pad = 6, bool hideLast = false}) {
    if (input.length < pad * 2) {
      return input;
    }
    if (hideLast) {
      return input.substring(0, pad * 2) + "...";
    }
    return input.substring(0, pad) +
        '...' +
        input.substring(input.length - pad);
  }

  static String commaNumber(String value) {
    var data = value.split(".");
    bool isTrailing = data.length != 1 && double.parse(data.last) != 0;
    if (isTrailing) value = data.first;
    var f = NumberFormat("###,###.###", "en_US");
    return f.format(double.parse(value)) + (isTrailing ? ".${data.last}" : "");
  }

  static String stakeAmount(String value) {
    double div = (int.parse(value) / pow(10, denomination));
    return commaNumber(roundOff(div, maxDecimals: 0));
  }

  static String remainingTime(int time) {
    // String formatSingle(int value) =>

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    DateTime now = DateTime.now();
    Duration remaining = dateTime.difference(now);
    int years = (remaining.inDays / 365).floor();
    int months = (remaining.inDays / 30).floor();
    int days = remaining.inDays;
    if (years > 0) {
      return "in ${years == 1 ? "a year" : "$years years"}";
    } else if (months > 0) {
      return "in ${months == 1 ? "a month" : "$months months"}";
    } else if (days > 0) {
      return "in ${days == 1 ? "a day" : "$days days"}";
    } else {
      return "in a day";
    }
    // if (remaining.inDays > 365) {
    //   return "in ${remaining.inDays} year(s)";
    // } else if (remaining.inDays > 365)
  }

  static String elapsedTime(int time) {
    // String formatSingle(int value) =>

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    DateTime now = DateTime.now();
    Duration elapsed = now.difference(dateTime);
    int years = (elapsed.inDays / 365).floor();
    int months = (elapsed.inDays / 30).floor();
    int days = elapsed.inDays;
    int hours = elapsed.inHours;
    int minutes = elapsed.inMinutes;
    if (years > 0) {
      return "${years == 1 ? "a year" : "$years years"} ago";
    } else if (months > 0) {
      return "${months == 1 ? "a month" : "$months months"} ago";
    } else if (days > 0) {
      return "${days == 1 ? "a day" : "$days days"} ago";
    } else if (hours > 0) {
      return "${hours == 1 ? "an hour" : "$hours hours"} ago";
    } else if (minutes > 0) {
      return "${minutes == 1 ? "a minute" : "$minutes minutes"} ago";
    } else {
      return "a few seconds ago";
    }
  }

  static String readableDate(DateTime time) {
    return DateFormat.yMMMMd().addPattern(",", "").add_jm().format(time);
  }
}

class InputFormatters {
  InputFormatters._();

  static List<TextInputFormatter> amountFilter() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
      TextInputFormatter.withFunction((oldValue, newValue) {
        try {
          final text = newValue.text;
          print(text);
          if (text.isNotEmpty && text != ".") double.parse(text);
          return newValue;
        } catch (e) {}
        print("error is $e");
        return oldValue;
      }),
    ];
  }

  static List<TextInputFormatter> wordsAndSpacesFilter() {
    return [
      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
    ];
  }
}
