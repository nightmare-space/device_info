import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info/model/cpu_info.dart';
import 'package:device_info/src/canvas/circle_progress.dart';
import 'package:device_info/src/controller/device_controller.dart';
import 'package:device_info/src/provider/general_stat.dart';
import 'package:device_info/src/utils/get_ratio_color.dart';
import 'package:device_info/src/utils/percentage_util.dart';
import 'package:device_info/src/widgets/flutter_wave.dart';
import 'package:device_info/src/widgets/night_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'line_chart_sample2.dart';

class General extends StatefulWidget {
  @override
  _GeneralState createState() => _GeneralState();
}

class _GeneralState extends State<General> with TickerProviderStateMixin {
  DeviceController controller = Get.put(
    DeviceController()
      ..pollingDeviceCPUGPU()
      ..getSimpleInfo(),
  );

  MethodChannel systemInfo = MethodChannel('device_info');
  StreamSubscription<void> _streamSubscription;
  AnimationController _animationController;
  AnimationController ramAnimaCtl; //运行内存动画控制器
  Animation<double> ramScale; //RAM动画值

  // num _sensor;
  @override
  void initState() {
    super.initState();
    ramAnimaCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    ramScale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: ramAnimaCtl, curve: Curves.easeIn));
    ramScale.addListener(() {
      setState(() {});
    });
    controller.cpuAnimaCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    controller.cpuUsed =
        Tween<double>(begin: 0.0, end: 0.0).animate(controller.cpuAnimaCtl);

    controller.gpuAnimaCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    controller.gpuUsed =
        Tween<double>(begin: 0.0, end: 0.0).animate(controller.cpuAnimaCtl);

    // _animationController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    // _angelvalue =
    //     Tween<double>(begin: 0.0, end: 0).animate(_animationController);
    // _angelvalue.addListener(() {
    //   // print(_angelvalue.value);
    //   setState(() {});
    // });
    // _animationController.forward();
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

  @override
  void dispose() {
    _animationController?.dispose();
    _streamSubscription?.cancel();
    ramAnimaCtl.dispose();
    controller.cpuAnimaCtl.dispose();
    controller.gpuAnimaCtl.dispose();
    super.dispose();
  }

  double pitch = 0.0;
  double rotated = 0.0;
  Color cpuProgressColor = const Color.fromRGBO(0, 255, 0, 1);

  @override
  Widget build(BuildContext context) {
    // print('build');
    final Color ramCircleColor = getColor(ramScale.value);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 130,
              child: Wrap(
                spacing: 12,
                children: <Widget>[
                  simple(context),
                  cpugpu(context),
                  // const Text(
                  //   '运行内存:',
                  //   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(
                  //   width: 100,
                  //   height: 100,
                  //   child: GestureDetector(
                  //     onTap: () async {
                  //       // showToast('清理中');
                  //       await ramAnimaCtl.reverse();
                  //       await exec(
                  //           '''BUSYBOX=/data/data/com.nightmare/files/usr/bin/busybox
                  //       \$BUSYBOX clear
                  //       \$BUSYBOX echo ''
                  //       \$BUSYBOX free | \$BUSYBOX awk '/Mem/{print '>>>...Memory Before Boosting: '\$4/1024' MB';}'
                  //       \$BUSYBOX echo ''
                  //       \$BUSYBOX echo 'Dropping cache'
                  //       \$BUSYBOX sync
                  //       \$BUSYBOX sysctl -w vm.drop_caches=3
                  //       dc=/proc/sys/vm/drop_caches
                  //       dc_v=`cat \$dc`
                  //       if [ '\$dc_v' -gt 1 ]; then
                  //       \$BUSYBOX sysctl -w vm.drop_caches=1
                  //       fi
                  //       \$BUSYBOX echo ''
                  //       \$BUSYBOX echo ''
                  //       \$BUSYBOX echo 'BOOSTED!!!'
                  //       \$BUSYBOX echo ''
                  //       \$BUSYBOX echo ''
                  //       \$BUSYBOX free | \$BUSYBOX awk '/Mem/{print '>>>...Memory After Boosting : '\$4/1024' MB';}'
                  //       \$BUSYBOX echo 'RAM boost \$( date +'%m-%d-%Y %H:%M:%S' )'
                  //       ''');
                  //       // final Map<String, int> info = await PlatformChannel
                  //       //     .SystemInfo.invokeMethod<Map<String, int>>('');
                  //       // final int totalMem = info['totalMem'];
                  //       // final int availMem = info['availMem'];
                  //       // ramScale = Tween<double>(
                  //       //         begin: 0.0, end: (totalMem - availMem) / totalMem)
                  //       //     .animate(CurvedAnimation(
                  //       //         parent: ramAnimaCtl, curve: Curves.easeIn));
                  //       ramAnimaCtl.forward();
                  //     },
                  //     child: Transform(
                  //       alignment: Alignment.center,
                  //       transform: Matrix4.identity(),
                  //       child: Stack(
                  //         alignment: Alignment.center,
                  //         children: <Widget>[
                  //           Container(
                  //             width: 100,
                  //             height: 100,
                  //             decoration: BoxDecoration(
                  //               color: Colors.transparent,
                  //               borderRadius: const BorderRadius.all(
                  //                 Radius.circular(100.0),
                  //               ),
                  //               boxShadow: <BoxShadow>[
                  //                 BoxShadow(
                  //                     color: Colors.black12.withOpacity(0.2),
                  //                     offset: Offset(0.0, pitch * 8), //阴影xy轴偏移量
                  //                     blurRadius: 8.0, //阴影模糊程度
                  //                     spreadRadius: 1.0 //阴影扩散程度
                  //                     ),
                  //               ],
                  //             ),
                  //           ),
                  //           Material(
                  //             borderRadius: const BorderRadius.all(
                  //               Radius.circular(100.0),
                  //             ),
                  //             elevation: 0.0,
                  //             child: FlutterWaveLoading(
                  //               isOval: true,
                  //               color: ramCircleColor,
                  //               progress: ramScale.value,
                  //               width: 100,
                  //               height: 100,
                  //             ),
                  //           ),
                  //           Center(
                  //             child: Text(
                  //               toPercentage(ramScale.value),
                  //               style: TextStyle(
                  //                 fontWeight: FontWeight.bold,
                  //                 color: isLightColor(ramCircleColor.value)
                  //                     ? Theme.of(context).textTheme.bodyText2.color
                  //                     : Colors.white,
                  //               ),
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  battery(context),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '内存',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08),
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
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '网络',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GetBuilder<DeviceController>(builder: (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LayoutBuilder(builder: (context, con) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (controller.cpuInfos.isEmpty)
                      const SizedBox()
                    else
                      for (int i = 0;
                          i < controller.cpuInfos.last.cpuInfos.length;
                          i++)
                        Container(
                          width: (con.maxWidth - 12 * 3) / 4,
                          // height: 100,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.08),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(controller
                                      .cpuInfos.last.cpuInfos[i].frequency
                                      .toString() +
                                  "Mhz"),
                              SizedBox(height: 4),
                              Builder(builder: (context) {
                                List<int> datas = [];
                                for (CpuInfo info in controller.cpuInfos) {
                                  datas.add(info.cpuInfos[i].frequency);
                                }
                                return LineChartSample2(
                                  datas: datas,
                                );
                              }),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                  ],
                );
              }),
            );
          }),
          // _CpuInfo(),
        ],
      ),
    );
  }

  Widget simple(BuildContext context) {
    return GetBuilder<DeviceController>(builder: (_) {
      return Container(
        padding: EdgeInsets.all(10),
        width: 160,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Text('设备ID ' + (controller.info.deviceId ?? '')),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Icon(Icons.adb),
                  SizedBox(width: 4),
                  Text('Android ' + controller.info.androidVersion.toString()),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget battery(BuildContext context) {
    return GetBuilder<DeviceController>(builder: (_) {
      return Container(
        padding: EdgeInsets.all(10),
        width: 160,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '电池',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(builder: (context, con) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 32,
                          height: con.maxHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.11),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: (controller.batteryInfo.level ?? 1) /
                              100 *
                              con.maxHeight,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${controller.batteryInfo.level ?? ''}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(width: 4),
                  LayoutBuilder(builder: (context, con) {
                    return SizedBox(
                      height: con.maxHeight,
                      width: 100,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.11),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Center(
                                child: Text(
                                  '${controller.batteryInfo.temperature ?? ''} ℃',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.11),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Center(
                                child: Text(
                                  '未充电',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  SizedBox cpugpu(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              child: Row(
                children: <Widget>[
                  const Text(
                    'CPU:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  AnimatedBuilder(
                    animation: controller.cpuUsed,
                    builder: (BuildContext ctx, Widget child) {
                      cpuProgressColor = getColor(controller.cpuUsed.value);
                      // print('build');
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomPaint(
                            size: const Size(50.0, 50.0),
                            painter: CircleProgress(
                              controller.cpuUsed.value,
                              6.0,
                              cpuProgressColor,
                              Theme.of(context).primaryColor.withOpacity(0.11),
                            ),
                            child: Center(
                              child: Text(
                                toPercentage(controller.cpuUsed.value),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              child: Row(
                children: <Widget>[
                  const Text(
                    'GPU:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  AnimatedBuilder(
                    animation: controller.cpuUsed,
                    builder: (BuildContext ctx, Widget child) {
                      cpuProgressColor = getColor(
                        controller.gpuUsed.value,
                      );
                      // print('build');
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomPaint(
                            size: const Size(50.0, 50.0),
                            painter: CircleProgress(
                              controller.gpuUsed.value,
                              6.0,
                              cpuProgressColor,
                              Theme.of(context).primaryColor.withOpacity(0.11),
                            ),
                            child: Center(
                              child: Text(
                                toPercentage(controller.gpuUsed.value),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
