import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:device_info/global/global.dart';
import 'package:device_info/model/battery_info.dart';
import 'package:device_info/model/cpu_info.dart';
import 'package:device_info/model/simple_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DeviceController extends GetxController {
  List<int> cpuRadios = [];
  List<int> gpuRadios = [];
  AnimationController cpuAnimaCtl;
  Animation<double> cpuUsed;
  AnimationController gpuAnimaCtl;
  Animation<double> gpuUsed;
  BatteryInfo batteryInfo = BatteryInfo();
  List<CpuInfo> cpuInfos = [];
  String get cmdPrefix => 'adb -s ${Global().device} shell';
  SimpleInfo info = SimpleInfo();

  void pollingDeviceCPUGPU() {
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      getGpuRatio();
      getCpuRatio();
      getBatteryInfo();
      getCpuInfo();
    });
  }

  Future<void> getSimpleInfo() async {
    String deviceId = await execCmd(
      '$cmdPrefix getprop ro.product.model',
    );
    String androidVersion = await execCmd(
      '$cmdPrefix getprop ro.build.version.release',
    );
    info.androidVersion = int.tryParse(androidVersion);
    info.deviceId = deviceId;
    update();
  }

  Future<void> getGpuRatio() async {
    String catResult = await execCmd(
      'adb -s ${Global().device} shell cat /sys/class/kgsl/kgsl-3d0/gpubusy',
    );
    catResult = catResult.trim();
    // Log.i('GPU : $catResult');
    List tmp = catResult.split(RegExp('\\s+'));
    int first = int.tryParse(tmp[0]);
    int second = int.tryParse(tmp[1]);
    double radio = (second == 0) ? 0 : first / second;
    double preValue = gpuUsed.value;
    gpuUsed = Tween<double>(
      begin: preValue,
      end: radio,
    ).animate(gpuAnimaCtl);
    gpuAnimaCtl.reset();
    gpuAnimaCtl.forward();
    // update();
  }

  Future<void> getCpuRatio() async {
    String catResult = await execCmd('$cmdPrefix cat /proc/stat');
    // Log.i('catResult : $catResult');
    List<String> statList = catResult.split('\n').first.split(RegExp('\\s+'))
      ..removeAt(0);
    int user = int.tryParse(statList[0]);
    int nice = int.tryParse(statList[1]);
    int system = int.tryParse(statList[2]);
    int idle = int.tryParse(statList[3]);
    int iowait = int.tryParse(statList[4]);
    int irq = int.tryParse(statList[5]);
    int softirq = int.tryParse(statList[6]);
    final int preTotalTime =
        user + nice + system + idle + iowait + irq + softirq;
    final int preBusyTime = preTotalTime - idle;
    statList = (await execCmd('$cmdPrefix cat /proc/stat'))
        .split('\n')
        .first
        .split(RegExp('\\s+'))
      ..removeAt(0);
    user = int.tryParse(statList[0]);
    nice = int.tryParse(statList[1]);
    system = int.tryParse(statList[2]);
    idle = int.tryParse(statList[3]);
    iowait = int.tryParse(statList[4]);
    irq = int.tryParse(statList[5]);
    softirq = int.tryParse(statList[6]);
    final int curTotalTime =
        user + nice + system + idle + iowait + irq + softirq;
    final int curBusytime = curTotalTime - idle;
    final double curCpuUsed =
        (curBusytime - preBusyTime) / (curTotalTime - preTotalTime);
    double preValue = cpuUsed.value;
    cpuUsed = Tween<double>(
      begin: preValue,
      end: curCpuUsed,
    ).animate(cpuAnimaCtl);
    cpuAnimaCtl.reset();
    cpuAnimaCtl.forward();
  }

  Future<void> getBatteryInfo() async {
    String result = await execCmd('$cmdPrefix dumpsys battery');
    batteryInfo = BatteryInfo.parseFormDumpsys(result);
    update();
  }

  Future<void> getCpuInfo() async {
    String result = await execCmd(
        '$cmdPrefix cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq\n' +
            'cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq\n');
    CpuInfo info = CpuInfo();
    for (String line in result.split('\n')) {
      info.cpuInfos.add(SingleCpuInfo(int.tryParse(line) ~/ 1000));
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
