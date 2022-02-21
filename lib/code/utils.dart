
import 'dart:math';

import 'package:wallet/code/models.dart';

class FormatText {
  FormatText._();

  static String wordList(List<String> words) {
    String formatted = "";
    for (var i = 0; i < words.length; i++) {
      formatted += words[i] + (i != words.length - 1 ? " " : "");
    }
    return formatted;
  }

  static String roundOff(double input, {int maxDecimals = 0}) {
    RegExp regex = RegExp(r"([.]*0)(?!.*\d)");
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
    double formatted = ((exchangeValue * pow(10, decimalPlaces)).toInt()) / pow(10, decimalPlaces);
    bool isDecimalZero = formatted.toInt() * pow(10, decimalPlaces) == (formatted * pow(10, decimalPlaces)).toInt();
    return isDecimalZero ? formatted.toStringAsFixed(0) : formatted.toString();
  }

  static String address(String input, {int pad = 6}) {
    if (input.length < pad * 2) {
      return input;
    }
    return input.substring(0, pad) + '...' + input.substring(input.length - pad);
  }
}