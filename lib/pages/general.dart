import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info/model/cpu_info.dart';
import 'package:device_info/canvas/circle_progress.dart';
import 'package:device_info/controller/device_controller.dart';
import 'package:device_info/provider/general_stat.dart';
import 'package:device_info/utils/get_ratio_color.dart';
import 'package:device_info/utils/percentage_util.dart';
import 'package:device_info/widgets/flutter_wave.dart';
import 'package:device_info/widgets/night_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import '../v2/cpu_gpu/view/cpu_line_chart.dart';

class General extends StatefulWidget {
  @override
  _GeneralState createState() => _GeneralState();
}

class _GeneralState extends State<General> with TickerProviderStateMixin {
  DeviceInfoController controller = Get.find();

  MethodChannel systemInfo = const MethodChannel('device_info');
  StreamSubscription<void>? _streamSubscription;
  AnimationController? _animationController;
  late AnimationController ramAnimaCtl; //运行内存动画控制器
  late Animation<double> ramScale; //RAM动画值

  // num _sensor;
  @override
  void initState() {
    super.initState();
    controller..pollingDeviceCPUGPU();
    ramAnimaCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    ramScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: ramAnimaCtl, curve: Curves.easeIn));
    ramScale.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    initRamInfo();
  }

  Future<void> initRamInfo() async {
    // final Map<dynamic, dynamic> info =
    //     await systemInfo.invokeMethod<Map<dynamic, dynamic>>('getRamStat');
    // final int totalMem = info['totalMem'] as int;
    // final int availMem = info['availMem'] as int;
    // print(info);
    // ramScale = Tween<double>(begin: 0.0, end: (totalMem - availMem) / totalMem)
    //     .animate(CurvedAnimation(parent: ramAnimaCtl, curve: Curves.easeIn));
    ramAnimaCtl.forward();
  }

  // todo
  // @override
  // void dispose() {
  //   _animationController?.dispose();
  //   _streamSubscription?.cancel();
  //   ramAnimaCtl.dispose();
  //   controller.cpuAnimaCtl.dispose();
  //   controller.cpuAnimaCtl = null;
  //   controller.gpuAnimaCtl.dispose();
  //   controller.gpuAnimaCtl = null;
  //   controller.timer.cancel();
  //   super.dispose();
  // }

  double pitch = 0.0;
  double rotated = 0.0;
  Color cpuProgressColor = const Color.fromRGBO(0, 255, 0, 1);
  double getPadding = 10;
  @override
  Widget build(BuildContext context) {
    // print('build');
    final Color ramCircleColor = getColor(ramScale.value);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getPadding),
            child: SizedBox(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  simple(context),
                  // ram(context),
                  mem(context),
                  // Container(
                  //   width: 100,
                  //   padding: EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //     color: Theme.of(context)
                  //         .colorScheme
                  //         .primary
                  //         .withOpacity(0.08),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         '网络',
                  //         style: TextStyle(
                  //           color: Theme.of(context).primaryColor,
                  //         ),
                  //       ),
                  //       SizedBox(height: 12),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // _CpuInfo(),
        ],
      ),
    );
  }

  Widget mem(BuildContext context) {
    return GetBuilder<DeviceInfoController>(builder: (_) {
      return Container(
        width: getWidth(),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '储存',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: controller.memInfo.sdUse == 0 ? 0 : controller.memInfo.sdUse! / controller.memInfo.sdTotal!,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  FileSizeUtils.getFileSize(controller.memInfo.sdUse! * 1024)!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Text('/'),
                Text(
                  FileSizeUtils.getFileSize(controller.memInfo.sdTotal! * 1024)!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  double getWidth() {
    double deviceWidth = MediaQuery.of(context).size.width;
    if (deviceWidth > 800) {
      return 160;
    }
    return (deviceWidth - 32) / 2;
  }

  Widget simple(BuildContext context) {
    return GetBuilder<DeviceInfoController>(builder: (_) {
      return Container(
        padding: const EdgeInsets.all(10),
        width: getWidth(),
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text('ID ' + (controller.info.deviceId ?? '')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    // Icon(Icons.adb),
                    // SizedBox(width: 4),
                    Text('Android ' + controller.info.androidVersion.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text('已开机 ' + controller.info.uptime.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
