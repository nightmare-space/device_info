import 'package:adb_util/adb_util.dart';
import 'package:device_info/model/mem_info.dart';
import 'package:device_info/model/simple_info.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class SimileInfoController extends GetxController {
  SimpleInfo info = SimpleInfo();
  MemInfo memInfo = MemInfo();
  String get serial => Get.find<String>(tag: 'serial');
  // 获取简单信息
  Future<void> getSimpleInfo() async {
    final String deviceId = await runShell(
      serial: serial,
      command: 'getprop ro.product.model',
    );
    // getprop ro.serialno
    // 获取安卓版本
    final String androidVersion = await runShell(
      serial: serial,
      command: 'getprop ro.build.version.release',
    );
    // final String powerTime;
    String uptime = await runShell(
      serial: serial,
      command: 'cat /proc/uptime',
    );
    uptime = uptime.split(' ').first.replaceAll('.', '');
    print('uptime->$uptime');
    final DateTime dateTime = DateTime(0, 0, 0, 0, 0, int.tryParse(uptime)! ~/ 100);
    info.uptime = '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
    info.androidVersion = int.tryParse(androidVersion);
    info.deviceId = deviceId;
    update();
    final String dfResult = await runShell(serial: serial, command: 'df');
    for (final String line in dfResult.split('\n')) {
      final List<String> tmp = line.split(RegExp('\\s+'));
      if (tmp.last == '/data') {
        Log.w(tmp);
        memInfo.sdTotal = int.tryParse(tmp[1]);
        memInfo.sdUse = int.tryParse(tmp[2]);
        update();
      }
    }
    // Log.i(dfResult);
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }
}
