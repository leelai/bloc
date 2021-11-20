import 'dart:math';

import 'package:platform_device_id/platform_device_id.dart';

const totalCount = 800;

List<String> systemGUIDs = [
  '899369E3-745A-5617-A837-3158E968D793',
  '46D00CC8-2C8A-4E49-976D-5F73396C1C05',
  '4C4C4544-0046-5710-8056-C4C04F464332'
];

class Util {
  static String? systemGUID;

  static Future<String> getSystemGUID() async {
    try {
      systemGUID = await PlatformDeviceId.getDeviceId;
    } on Exception catch (err) {
      systemGUID = err.toString();
    }

    return systemGUID ?? 'Failed to get deviceId.';
  }

  static Future<bool> isVaildDevice() async {
    systemGUID ??= await getSystemGUID();
    for (var guid in systemGUIDs) {
      systemGUID = systemGUID!.trim();
      if (systemGUID == guid) {
        return true;
      }
    }
    return false;
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String _getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

  static String genPw() => _getRandomString(6);
}
