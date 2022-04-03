import 'dart:math';

import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';

class TokenData extends GetxController {
  var data = currencyList.map((e) => e.coinData).toList().obs;
  var selected;
  changeSelection(int index, bool value) {
    CoinData coin = data[index];
    coin.selected = value;
    StorageService.instance.updateDefaultWallets(coin.unit, isSelected: value);
    selected = data.where((e) => e.selected).toList();
  }

  defaultSelection() {
    List<String> defaultWallets = StorageService.instance.defaultWallets!;
    data.forEach((e) {
      if (defaultWallets.contains(e.unit)) {
        e.selected = true;
      } else {
        e.selected = false;
      }
    });
    return selected = data.where((e) => e.selected).toList();
  }
}

class BalanceData extends GetxController {
  final TokenData tokenData = Get.put(TokenData());
  Map<CoinData, double>? data;
  Map<CoinData, double> getData() => data ??= {
        for (var item in tokenData.data)
          // if (Random().nextInt(100) < 50)
          if (true)
            item: (((Random().nextDouble() * 10000).toInt()) / 100)
          else
            item: 0.0
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
