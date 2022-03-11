import 'dart:math';

import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';

class TokenData extends GetxController {
  var data = List.generate(20, (i) => CoinData("Coin $i", "XCN$i", 123.45, "1.2")).obs;
  var selected;
  changeSelection(int index, bool value) {
    data[index].selected = value;
    selected = data.where((element) => element.selected).toList();
  }
  defaultSelection() => selected = data;
}

class BalanceData extends GetxController {
  final TokenData tokenData = Get.put(TokenData());
  Map<CoinData, double>? data;
  Map<CoinData, double> getData() => data ??= {
    for (var item in tokenData.data)
      if(Random().nextInt(100) < 50) item : (((Random().nextDouble() * 10000).toInt())/100) else item : 0.0
  };
}

class SettingsState extends GetxController {
  var darkMode = false.obs;
  toggleDarkMode() {
    if (darkMode.value) {
      darkMode.value = false;
      Get.changeTheme(lightTheme);
    } else {
      darkMode.value = true;
      Get.changeTheme(darkTheme);
    }
  }
}