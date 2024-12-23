import 'dart:async';

import 'package:adb_util/adb_util.dart';
import 'package:device_info/model/battery_info.dart';
import 'package:device_info/v2/adb_device.dart';
import 'package:get/get.dart';

class BatteryController extends GetxController {
  BatteryInfo batteryInfo = BatteryInfo();
  String get serial => Get.find<String>(tag: 'serial');
  Timer? timer;

  Future<void> getBatteryInfo() async {
    // dumpsys battery
    final String result = await runShell(serial: serial, command: 'dumpsys battery');
    batteryInfo = BatteryInfo.parseFormDumpsys(result);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      getBatteryInfo();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
