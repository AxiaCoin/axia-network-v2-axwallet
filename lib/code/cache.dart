import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wallet/Crypto_Models/axc_wallet.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:axwallet_sdk/axwallet_sdk.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/storage.dart';

class CustomCacheManager {
  static final CustomCacheManager instance = CustomCacheManager._();
  CustomCacheManager._();
  WalletData walletData = Get.put(WalletData());
  static const key = 'axc_base_cache';
  final box = GetStorage(key);
  final _balanceKey = "balances";
  final _addressKey = "addresses";
  final _validatorsKey = "validator_list";
  final _networkKey = "network_configs";
  final _customNetworkKey = "custom_network_configs";
  final _transactionsKey = "transactions";

  getAccountKey(String key) {
    String pubKey = (StorageService.instance.readCurrentPubKey()) ?? "";
    return pubKey + "_" + key;
  }

  AXCWallet? addressFromCache() {
    String? bal = box.read(getAccountKey(_addressKey));
    if (bal != null) {
      return AXCWallet.fromJson(bal);
    }
    return null;
  }

  void cacheAddress(AXCWallet data) {
    box.write(getAccountKey(_addressKey), data.toJson());
  }

  AXCBalance? balanceFromCache() {
    String? bal = box.read(getAccountKey(_balanceKey));
    if (bal != null) {
      return AXCBalance.fromJson(bal);
    }
    return null;
  }

  void cacheBalance(AXCBalance data) {
    box.write(getAccountKey(_balanceKey), data.toJson());
  }

  List<ValidatorItem> validatorsFromCache() {
    List? data = box.read(_validatorsKey);
    return data?.map((e) => ValidatorItem.fromJson(e)).toList() ?? [];
  }

  void cacheValidators(List<ValidatorItem> data) {
    var validators = data.map((e) => e.toJson()).toList();
    box.write(_validatorsKey, validators);
  }

  List<NetworkConfig> networkConfigs() {
    List? data = box.read(_networkKey);
    return data?.map((e) => NetworkConfig.fromJson(e)).toList() ?? [];
  }

  void cacheNetworkConfigs(List<NetworkConfig> data) {
    var networkConfigs = data.map((e) => e.toJson()).toList();
    box.write(_networkKey, networkConfigs);
  }

  List<NetworkConfig> customNetworkConfigs() {
    List? data = box.read(_customNetworkKey);
    return data?.map((e) => NetworkConfig.fromJson(e)).toList() ?? [];
  }

  void cacheCustomNetworkConfigs(List<NetworkConfig> data) {
    var networkConfigs = data.map((e) => e.toJson()).toList();
    box.write(_customNetworkKey, networkConfigs);
  }

  List<AXCTransaction> transactionsFromCache() {
    List? data = box.read(getAccountKey(_transactionsKey));
    return data?.map((e) => AXCTransaction.fromJson(e)).toList() ?? [];
  }

  void cacheTransactions(List<AXCTransaction> data) {
    var transactions = data.map((e) => e.toJson()).toList();
    box.write(getAccountKey(_transactionsKey), transactions);
    // need this because for some reason the pubkey is null on runtime
    // so at launch, the transaction data is empty
    box.write(_transactionsKey, transactions);
  }
}
