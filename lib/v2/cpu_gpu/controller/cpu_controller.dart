import 'dart:async';

import 'package:adb_util/adb_util.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:device_info/v2/adb_device.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class LimitedQueue<T> {
  final int maxLength;
  final List<T> _queue = [];

  LimitedQueue(this.maxLength);

  void add(T item) {
    if (_queue.length >= maxLength) {
      _queue.removeAt(0);
    }
    _queue.add(item);
  }

  List<T> get items => List.unmodifiable(_queue);
}

extension ListExtensions<T extends num> on List<T> {
  T get max {
    if (isEmpty) {
      throw StateError('No elements');
    }
    T maxValue = this[0];
    for (T value in this) {
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue;
  }
}

class CPUController extends GetxController {
  final LimitedQueue<CPU_GPU_Info> cpuGpuInfoQueue = LimitedQueue(10);
  final LimitedQueue<double> cpuUsuages = LimitedQueue(30);
  double gpuUsuage = 0;
  Timer? timer;
  String get serial => Get.find<String>(tag: 'serial');

  @override
  void onInit() {
    super.onInit();
    loadInfo();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<void> getCpuRatio() async {
    double usuage = await calculateCpuUsage();
    Log.i('cpu usage: $usuage');
    if (usuage != -1) {
      cpuUsuages.add(usuage);
      update();
    }
  }

  Future<List<int>> getCpuTimes() async {
    String statContent = await runShell(serial: serial, command: 'cat /proc/stat');
    final lines = statContent.split('\n');
    final cpuLine = lines.firstWhere((line) => line.startsWith('cpu '));
    final times = cpuLine.split(RegExp('\\s+')).skip(1).map(int.parse).toList();
    // Log.i('times: $times');
    return times;
  }

  Future<double> calculateCpuUsage() async {
    // 读取第一次 CPU 时间
    final cpuTimes1 = await getCpuTimes();
    if (cpuTimes1.isEmpty) {
      return -1;
    }
    await Future.delayed(Duration(seconds: 1));
    final cpuTimes2 = await getCpuTimes();
    if (cpuTimes2.isEmpty) {
      return -1;
    }
    // 计算总时间和空闲时间的差值
    // caculate the total and idle time difference
    final idleTime1 = cpuTimes1[3] + cpuTimes1[4];
    final idleTime2 = cpuTimes2[3] + cpuTimes2[4];
    final totalTime1 = cpuTimes1.reduce((a, b) => a + b);
    final totalTime2 = cpuTimes2.reduce((a, b) => a + b);

    final idleDelta = idleTime2 - idleTime1;
    final totalDelta = totalTime2 - totalTime1;

    // 计算 CPU 使用率
    // calculate the CPU usage
    final cpuUsage = 1.0 - (idleDelta / totalDelta);
    return cpuUsage * 100;
  }

  Future<void> loadInfo() async {
    AASClient client = Get.find();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      CPU_GPU_Info cpuGpuInfo = await client.api.cpu_gpu_info(key: 'aas');
      // Log.i('cpuGpuInfo: $cpuGpuInfo');
      gpuUsuage = cpuGpuInfo.gpu[0] / cpuGpuInfo.gpu[1] * 100;
      if (gpuUsuage.isNaN) {
        gpuUsuage = 0;
      }
      Log.i('gpu usage: $gpuUsuage');
      cpuGpuInfoQueue.add(cpuGpuInfo);
      getCpuRatio();
      update();
    });
  }
}
