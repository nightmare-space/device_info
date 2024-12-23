import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'battery/view/battery_container.dart';
import 'cpu_gpu/view/cpu_container.dart';
import 'cpu_gpu/view/cpu_detail_container.dart';
import 'ram/view/ram_container.dart';
import 'simple_info/view/simpile_info_container.dart';

class SerialInheritedWidget extends InheritedWidget {
  final String serial;

  const SerialInheritedWidget({
    super.key,
    required this.serial,
    required super.child,
  });

  static SerialInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SerialInheritedWidget>();
  }

  @override
  bool updateShouldNotify(SerialInheritedWidget oldWidget) {
    return serial != oldWidget.serial;
  }
}

class DeviceDashboard extends StatefulWidget {
  const DeviceDashboard({super.key, required this.serial});
  final String serial;
  final String password;

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard> {
  @override
  void initState() {
    super.initState();
    Get.put(widget.serial, tag: 'serial');
  }

  @override
  Widget build(BuildContext context) {
    return SerialInheritedWidget(
      serial: widget.serial,
      child: Column(
        children: [
          SizedBox(height: 10.w),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.w,
              children: [
                SizedBox(
                  width: 200.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SimpileInfoContainer(),
                      SizedBox(height: 8.w),
                      BatteryContainer(),
                    ],
                  ),
                ),
                SizedBox(
                  width: 200.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CPUContainer(),
                      SizedBox(height: 8.w),
                      RamContainer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.w),
          CPUDetailContainer(),
        ],
      ),
    );
  }
}
