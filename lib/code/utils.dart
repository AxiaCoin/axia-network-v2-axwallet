// ignore_for_file: dead_code

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:wallet/code/constants.dart';
import 'package:intl/intl.dart';

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

  static String address(String input, {int pad = 6}) {
    if (input.length < pad * 2) {
      return input;
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
