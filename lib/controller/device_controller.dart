import 'dart:async';

// import 'package:adbutil/adbutil.dart';
import 'package:adb_util/adb_util.dart';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:device_info/device_info.dart';
import 'package:device_info/model/battery_info.dart';
import 'package:device_info/model/cpu_info.dart';
import 'package:device_info/model/mem_info.dart';
import 'package:device_info/model/ram_info.dart';
import 'package:device_info/model/simple_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart' hide exec;

class DeviceInfoController extends GetxController {
  List<CpuInfo> cpuInfos = [];
  String device = '192.168.31.110:5555';
  //
  String get cmdPrefix => 'adb -s $device shell';
  SimpleInfo info = SimpleInfo();
  RamInfo ramInfo = RamInfo(0, 0);
  MemInfo memInfo = MemInfo();
  Timer? timer;

  void pollingDeviceCPUGPU() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      // getGpuRatio();
      // getCpuRatio();
      // getBatteryInfo();
      // getRamInfo();
    });
  }

  void initDevice(String device) {
    this.device = device;
  }

  Future<void> getRamInfo() async {
    final String meminfo = await exec(
      '$cmdPrefix cat /proc/meminfo',
    );
    final List<String> lines = meminfo.split('\n');
    final String ram = lines.first.split(RegExp('\\s+'))[1];
    final String free = lines[2].split(RegExp('\\s+'))[1];
    ramInfo.total = int.tryParse(ram);
    ramInfo.free = int.tryParse(free);
    update();
    // Log.i('ram :  $ram');
  }
}
