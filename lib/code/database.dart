import 'dart:math';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:wallet/code/storage.dart';

class TokenData extends GetxController {
  RxList<Currency> data = currencyList.map((e) => e).toList().obs;
  List<Currency>? selected;
  changeSelection(int index, bool value) {
    CoinData coin = data[index].coinData;
    coin.selected = value;
    StorageService.instance.updateDefaultWallets(coin.unit, isSelected: value);
    selected = data.where((e) => e.coinData.selected).toList();
  }

  defaultSelection() {
    List<String> defaultWallets = StorageService.instance.defaultWallets!;
    data.forEach((e) {
      if (defaultWallets.contains(e.coinData.unit)) {
        e.coinData.selected = true;
      } else {
        e.coinData.selected = false;
      }
    });
    return selected = data.where((e) => e.coinData.selected).toList();
  }
}

class BalanceData extends GetxController {
  final TokenData tokenData = Get.put(TokenData());
  Map<Currency, double>? data;
  Map<Currency, double> getData() => data ??= {
        for (var item in tokenData.data)
          // if (Random().nextInt(100) < 50)
          if (true) item: (((Random().nextDouble() * 10000).toInt()) / 100)
        // else
        // item: 0.0
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

class User extends GetxController {
  var userModel = UserModel.none().obs;

  updateUser(UserModel user) {
    userModel.value = user;
  }
}
