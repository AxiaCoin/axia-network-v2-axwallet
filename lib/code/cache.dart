import 'package:get_storage/get_storage.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:axwallet_sdk/axwallet_sdk.dart';

class CustomCacheManager {
  static final CustomCacheManager instance = CustomCacheManager._();
  CustomCacheManager._();
  static const key = 'axc_base_cache';
  final box = GetStorage(key);

  List<ValidatorItem> validatorsFromCache() {
    List? data = box.read("validator_list");
    return data?.map((e) => ValidatorItem.fromJson(e)).toList() ?? [];
  }

  void cacheValidators(List<ValidatorItem> data) {
    var validators = data.map((e) => e.toJson()).toList();
    box.write("validator_list", validators);
  }

  List<NetworkConfig> networkConfigs() {
    List? data = box.read("network_configs");
    return data?.map((e) => NetworkConfig.fromJson(e)).toList() ?? [];
  }

  void cacheNetworkConfigs(List<NetworkConfig> data) {
    var networkConfigs = data.map((e) => e.toJson()).toList();
    box.write("network_configs", networkConfigs);
  }

  List<NetworkConfig> customNetworkConfigs() {
    List? data = box.read("custom_network_configs");
    return data?.map((e) => NetworkConfig.fromJson(e)).toList() ?? [];
  }

  void cacheCustomNetworkConfigs(List<NetworkConfig> data) {
    var networkConfigs = data.map((e) => e.toJson()).toList();
    box.write("custom_network_configs", networkConfigs);
  }
}
