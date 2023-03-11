import 'dart:async';

import 'package:adbutil/adbutil.dart';
import 'package:device_info/device_info.dart';
import 'package:device_info/model/battery_info.dart';
import 'package:device_info/model/cpu_info.dart';
import 'package:device_info/model/mem_info.dart';
import 'package:device_info/model/ram_info.dart';
import 'package:device_info/model/simple_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DeviceInfoController extends GetxController {
  List<int> cpuRadios = [];
  List<int> gpuRadios = [];
  AnimationController? cpuAnimaCtl;
  late Animation<double> cpuUsed;
  AnimationController? gpuAnimaCtl;
  late Animation<double> gpuUsed;
  BatteryInfo batteryInfo = BatteryInfo();
  List<CpuInfo> cpuInfos = [];
  late String device;
  //
  String get cmdPrefix => '$adb -s $device shell';
  SimpleInfo info = SimpleInfo();
  RamInfo ramInfo = RamInfo(0, 0);
  MemInfo memInfo = MemInfo();
  Timer? timer;

  void pollingDeviceCPUGPU() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      getGpuRatio();
      getCpuRatio();
      getBatteryInfo();
      getCpuInfo();
      getRamInfo();
    });
  }

  void initDevice(String device) {
    this.device = device;
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  // 获取简单信息
  Future<void> getSimpleInfo() async {
    final String deviceId = await execCmd(
      '$cmdPrefix getprop ro.product.model',
    );
    // 获取安卓版本
    final String androidVersion = await execCmd(
      '$cmdPrefix getprop ro.build.version.release',
    );
    // final String powerTime;
    String uptime = await execCmd('$cmdPrefix cat /proc/uptime');
    uptime = uptime.split(' ').first.replaceAll('.', '');
    print('uptime->$uptime');
    final DateTime dateTime = DateTime(0, 0, 0, 0, 0, int.tryParse(uptime)! ~/ 100);
    info.uptime = '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
    info.androidVersion = int.tryParse(androidVersion);
    info.deviceId = deviceId;
    update();
    final String dfResult = await execCmd(
      '$cmdPrefix df',
    );
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

  Future<void> getRamInfo() async {
    final String meminfo = await execCmd(
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

  Future<void> getGpuRatio() async {
    String catResult = await execCmd(
      'adb -s $device shell cat /sys/class/kgsl/kgsl-3d0/gpubusy',
    );
    catResult = catResult.trim();
    // Log.i('GPU : $catResult');
    final List tmp = catResult.split(RegExp('\\s+'));
    final int? first = int.tryParse(tmp[0].toString());
    final int? second = int.tryParse(tmp[1].toString());
    final double radio = (second == 0) ? 0 : first! / second!;
    final double preValue = gpuUsed.value;
    gpuUsed = Tween<double>(
      begin: preValue,
      end: radio,
    ).animate(gpuAnimaCtl!);
    gpuAnimaCtl?.reset();
    gpuAnimaCtl?.forward();
    // update();
  }

  Future<void> getCpuRatio() async {
    final String catResult = await execCmd('$cmdPrefix cat /proc/stat');
    // Log.i('catResult : $catResult');
    List<String> statList = catResult.split('\n').first.split(RegExp('\\s+'))..removeAt(0);
    int user = int.tryParse(statList[0])!;
    int nice = int.tryParse(statList[1])!;
    int system = int.tryParse(statList[2])!;
    int idle = int.tryParse(statList[3])!;
    int iowait = int.tryParse(statList[4])!;
    int irq = int.tryParse(statList[5])!;
    int softirq = int.tryParse(statList[6])!;
    final int preTotalTime = user + nice + system + idle + iowait + irq + softirq;
    final int preBusyTime = preTotalTime - idle;
    statList = (await execCmd('$cmdPrefix cat /proc/stat')).split('\n').first.split(RegExp('\\s+'))..removeAt(0);
    user = int.tryParse(statList[0])!;
    nice = int.tryParse(statList[1])!;
    system = int.tryParse(statList[2])!;
    idle = int.tryParse(statList[3])!;
    iowait = int.tryParse(statList[4])!;
    irq = int.tryParse(statList[5])!;
    softirq = int.tryParse(statList[6])!;
    final int curTotalTime = user + nice + system + idle + iowait + irq + softirq;
    final int curBusytime = curTotalTime - idle;
    final double curCpuUsed = (curBusytime - preBusyTime) / (curTotalTime - preTotalTime);
    final double preValue = cpuUsed.value;
    cpuUsed = Tween<double>(
      begin: preValue,
      end: curCpuUsed,
    ).animate(cpuAnimaCtl!);
    cpuAnimaCtl?.reset();
    cpuAnimaCtl?.forward();
  }

  Future<void> getBatteryInfo() async {
    final String result = await execCmd('$cmdPrefix dumpsys battery');
    batteryInfo = BatteryInfo.parseFormDumpsys(result);
    update();
  }

  Future<void> getCpuInfo() async {
    final String result = await execCmd('$cmdPrefix cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq\n' +
        'cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq\n');
    final CpuInfo info = CpuInfo();
    for (final String line in result.split('\n')) {
      info.cpuInfos.add(SingleCpuInfo(int.tryParse(line)! ~/ 1000));
    }
    cpuInfos.add(info);
    removeIfRanged();
    update();
    // Log.i('result : ${result.split('\n')}');
  }

  void removeIfRanged() {
    if (cpuInfos.length > 10) {
      cpuInfos.removeAt(0);
    }
  }
}
