import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();
  final box = GetStorage();

  String? authToken;
  String? sessionID;
  String? deviceID;

  init() {
    authToken = box.read("authToken");
    sessionID = box.read("sessionID");
    deviceID = box.read("deviceID");
    if (deviceID == null) getDeviceID();
  }

  getDeviceID() async {
    if (Platform.isAndroid) {
      var deviceInfo = await DeviceInfoPlugin().androidInfo;
      deviceID = deviceInfo.androidId!;
    } else {
      var deviceInfo = await DeviceInfoPlugin().iosInfo;
      deviceID = deviceInfo.identifierForVendor!;
    }
  }

  updateAuthToken(String value) {
    authToken = value;
    box.write("authToken", value);
  }

  updateSessionID(String value) {
    sessionID = value;
    box.write("sessionID", value);
  }

  updateDeviceID(String value) {
    deviceID = value;
    box.write("deviceID", value);
  }

  clearTokens() {
    authToken = null;
    sessionID = null;
    box.remove("authToken");
    box.remove("sessionID");
  }
}
