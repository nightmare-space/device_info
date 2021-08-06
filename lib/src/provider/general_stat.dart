import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';

class GeneralStat extends GetxController {
  final List<int> _cpuBusyRatio = <int>[];
  List<int> get cpuBusyRatio => _cpuBusyRatio;
  void setBusyRatio(String cpuBuysInfo) {
    for (final String node in cpuBuysInfo.split('\n')) {
      _cpuBusyRatio.add(int.tryParse(node.trim()));
    }
    // notifyListeners();
    // print(_cpuBusyRatio);
  }

  void clear() {
    _cpuBusyRatio.clear();
  }
}
