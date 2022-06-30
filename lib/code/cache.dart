import 'package:get_storage/get_storage.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/services.dart';

class CustomCacheManager {
  static final CustomCacheManager instance = CustomCacheManager._();
  CustomCacheManager._();
  static const key = 'axc_base_cache';
  final box = GetStorage(key);

  List<ValidatorItem>? validatorsFromCache() {
    List? data = box.read("validator_list");
    return data?.map((e) => ValidatorItem.fromJson(e)).toList();
  }

  void cacheValidators(List<ValidatorItem> data) {
    var validators = data.map((e) => e.toJson()).toList();
    box.write("validator_list", validators);
  }
}
