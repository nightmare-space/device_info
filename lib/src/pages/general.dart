import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info/src/canvas/circle_progress.dart';
import 'package:device_info/src/provider/general_stat.dart';
import 'package:device_info/src/utils/get_ratio_color.dart';
import 'package:device_info/src/utils/percentage_util.dart';
import 'package:device_info/src/widgets/flutter_wave.dart';
import 'package:device_info/src/widgets/night_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class General extends StatefulWidget {
  @override
  _GeneralState createState() => _GeneralState();
}

class _GeneralState extends State<General> with TickerProviderStateMixin {
  MethodChannel systemInfo = MethodChannel('device_info');
  StreamSubscription<void> _streamSubscription;
  AnimationController _animationController;
  AnimationController ramAnimaCtl; //运行内存动画控制器
  Animation<double> ramScale; //RAM动画值
  AnimationController cpuAnimaCtl;
  Animation<double> cpuUsed;
  AnimationController gpuAnimaCtl;
  Animation<double> gpuUsed;
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
    cpuAnimaCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    cpuUsed = Tween<double>(begin: 0.0, end: 0.0).animate(cpuAnimaCtl);

    gpuAnimaCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    gpuUsed = Tween<double>(begin: 0.0, end: 0.0).animate(cpuAnimaCtl);

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
    final Map<dynamic, dynamic> info =
        await systemInfo.invokeMethod<Map<dynamic, dynamic>>('getRamStat');
    final int totalMem = info['totalMem'] as int;
    final int availMem = info['availMem'] as int;
    // print(info);
    ramScale = Tween<double>(begin: 0.0, end: (totalMem - availMem) / totalMem)
        .animate(CurvedAnimation(parent: ramAnimaCtl, curve: Curves.easeIn));
    ramAnimaCtl.forward();
    while (mounted) {
      await getCpuRatio();
      await getGpuRatio();
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> getGpuRatio() async {
    final List<String> gpuInfo = (await NiProcess.exec(
            'cat /sys/class/kgsl/kgsl-3d0/gpu_busy_percentage'))
        .split(RegExp('\\s+'));
    gpuUsed = Tween<double>(
      begin: gpuUsed.value,
      end: double.tryParse(gpuInfo.first) / 100,
    ).animate(gpuAnimaCtl);
    gpuAnimaCtl.reset();
    gpuAnimaCtl.forward();
  }

  Future<void> getCpuRatio() async {
    List<String> statList = (await NiProcess.exec('cat /proc/stat'))
        .split('\n')
        .first
        .split(RegExp('\\s+'))
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
    statList = (await NiProcess.exec('cat /proc/stat'))
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
    cpuUsed = Tween<double>(
      begin: cpuUsed.value,
      end: curCpuUsed,
    ).animate(cpuAnimaCtl);
    cpuAnimaCtl.reset();
    cpuAnimaCtl.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _streamSubscription?.cancel();
    ramAnimaCtl.dispose();
    cpuAnimaCtl.dispose();
    gpuAnimaCtl.dispose();
    super.dispose();
  }

  double pitch = 0.0;
  // void sensorLinsten() {
  //   _streamSubscription =
  //       AeyriumSensor.sensorEvents.listen((SensorEvent event) async {
  //     // _hasListen = true;
  //     // if (widget.reverse)
  //     //   _sensor = event.roll;
  //     // else
  //     // rotated = ;
  //     double positiveAngel;
  //     if (event.roll >= 0)
  //       positiveAngel = event.roll;
  //     else
  //       positiveAngel = (2 * pi + event.roll).abs();
  //     pitch = event.pitch + pi / 2;
  //     if (_angelvalue.value < pi / 2 && positiveAngel > 1.5 * pi) {
  //       _angelvalue = Tween<double>(begin: _angelvalue.value, end: 0)
  //           .animate(_animationController);
  //       if (!_animationController.isAnimating) {
  //         _animationController.reset();
  //         await _animationController.forward();
  //         _angelvalue = Tween<double>(begin: 2 * pi, end: positiveAngel)
  //             .animate(_animationController);
  //         _animationController.forward();
  //       }
  //     } else if (_angelvalue.value > 1.5 * pi / 2 && positiveAngel < pi / 2) {
  //       _angelvalue = Tween<double>(begin: _angelvalue.value, end: 2 * pi)
  //           .animate(_animationController);
  //       if (!_animationController.isAnimating) {
  //         _animationController.reset();
  //         await _animationController.forward();
  //         _angelvalue = Tween<double>(begin: 2 * pi, end: positiveAngel)
  //             .animate(_animationController);
  //         _animationController.forward();
  //       }
  //     } else {
  //       _angelvalue =
  //           Tween<double>(begin: _angelvalue.value, end: positiveAngel)
  //               .animate(_animationController);
  //       if (!_animationController.isAnimating) {
  //         _animationController.reset();
  //         _animationController.forward();
  //       }
  //     }

  //     // setState(() {});
  //     // print(_sensor);
  //     //保存传感器插件传回来的Z轴的弧度变化
  //     //由于传感器数据在刚好超过π时会马上变为负值
  //     //所以写一下逻辑来避免一些动画过渡的Bug
  //     // if (_sensor.abs() >= pi / 2) {
  //     //   //当倾斜弧度的绝对值大于π/2即90°用另一种方法计算当前的偏移位置
  //     //   if (_sensor >= 0) {
  //     //     _tmp = _angelvalue * pi / 180;
  //     //   }
  //     //   if (_sensor <= 0) {
  //     //     if (_angelvalue == 0.0) {
  //     //       _tmp = _angelvalue;
  //     //     } else {
  //     //       _tmp = _angelvalue * pi / 180 - 2 * pi; //将传感器值处于三四象限为负转化为正
  //     //     }
  //     //   }

  //     // } else {
  //     //   _tmp = _rotation;
  //     //   _change = _sensor - _tmp;
  //     // }
  //     // _animationController.addListener(() {
  //     //   setState(() {
  //     //     _rotation = _tmp + _change * _values.value;
  //     //     //利用动画的值改变控件倾斜的角度
  //     //   });
  //     // });
  //     // if (!_animationController.isAnimating) {
  //     //   if (_syncSensor) {
  //     //     _animationController.forward();
  //     //   }
  //     // }
  //   });
  // }

  double rotated = 0.0;
  Color cpuProgressColor = const Color.fromRGBO(0, 255, 0, 1);
  @override
  Widget build(BuildContext context) {
    // print('build');
    final Color ramCircleColor = getColor(ramScale.value);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 40.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'CPU:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      AnimatedBuilder(
                        animation: cpuUsed,
                        builder: (BuildContext ctx, Widget child) {
                          cpuProgressColor = getColor(cpuUsed.value);
                          // print('build');
                          return Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                size: const Size(50.0, 50.0),
                                painter: CircleProgress(
                                  cpuUsed.value,
                                  6.0,
                                  cpuProgressColor,
                                ),
                                child: Center(
                                  child: Text(
                                    toPercentage(cpuUsed.value),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        'GPU:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      AnimatedBuilder(
                        animation: gpuUsed,
                        builder: (BuildContext ctx, Widget child) {
                          return Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                child: Center(
                                  child: Text(
                                    toPercentage(gpuUsed.value),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                size: const Size(50, 50),
                                painter: CircleProgress(
                                  gpuUsed.value,
                                  6.0,
                                  getColor(gpuUsed.value),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                '运行内存:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: GestureDetector(
                  onTap: () async {
                    // showToast('清理中');
                    await ramAnimaCtl.reverse();
                    await NiProcess.exec(
                        '''BUSYBOX=/data/data/com.nightmare/files/usr/bin/busybox
                    \$BUSYBOX clear
                    \$BUSYBOX echo ''
                    \$BUSYBOX free | \$BUSYBOX awk '/Mem/{print '>>>...Memory Before Boosting: '\$4/1024' MB';}'
                    \$BUSYBOX echo ''
                    \$BUSYBOX echo 'Dropping cache'
                    \$BUSYBOX sync
                    \$BUSYBOX sysctl -w vm.drop_caches=3
                    dc=/proc/sys/vm/drop_caches
                    dc_v=`cat \$dc`
                    if [ '\$dc_v' -gt 1 ]; then
                    \$BUSYBOX sysctl -w vm.drop_caches=1
                    fi
                    \$BUSYBOX echo ''
                    \$BUSYBOX echo ''
                    \$BUSYBOX echo 'BOOSTED!!!'
                    \$BUSYBOX echo ''
                    \$BUSYBOX echo ''
                    \$BUSYBOX free | \$BUSYBOX awk '/Mem/{print '>>>...Memory After Boosting : '\$4/1024' MB';}'
                    \$BUSYBOX echo 'RAM boost \$( date +'%m-%d-%Y %H:%M:%S' )'
                    ''');
                    // final Map<String, int> info = await PlatformChannel
                    //     .SystemInfo.invokeMethod<Map<String, int>>('');
                    // final int totalMem = info['totalMem'];
                    // final int availMem = info['availMem'];
                    // ramScale = Tween<double>(
                    //         begin: 0.0, end: (totalMem - availMem) / totalMem)
                    //     .animate(CurvedAnimation(
                    //         parent: ramAnimaCtl, curve: Curves.easeIn));
                    ramAnimaCtl.forward();
                  },
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black12.withOpacity(0.2),
                                  offset: Offset(0.0, pitch * 8), //阴影xy轴偏移量
                                  blurRadius: 8.0, //阴影模糊程度
                                  spreadRadius: 1.0 //阴影扩散程度
                                  ),
                            ],
                          ),
                        ),
                        Material(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                          elevation: 0.0,
                          child: FlutterWaveLoading(
                            isOval: true,
                            color: ramCircleColor,
                            progress: ramScale.value,
                            width: 100,
                            height: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            toPercentage(ramScale.value),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLightColor(ramCircleColor.value)
                                  ? Theme.of(context).textTheme.bodyText2.color
                                  : Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _CpuInfo(),
        ],
      ),
    );
  }
}

// class CpuEntity {
//   String scaling_cur_freq;
//   String busy;
//   String scaling_min_freq;
//   String scaling_max_freq;
// }

class _CpuInfo extends StatefulWidget {
  @override
  __CpuInfoState createState() => __CpuInfoState();
}

class __CpuInfoState extends State<_CpuInfo> {
  @override
  Widget build(BuildContext context) {
    return CpuInfoBody();
  }
}

class CpuInfoBody extends StatefulWidget {
  @override
  _CpuInfoBodyState createState() => _CpuInfoBodyState();
}

class _CpuInfoBodyState extends State<CpuInfoBody>
    with TickerProviderStateMixin {
  AnimationController animaCtl;
  GeneralStat cpuBusyRadio;

  @override
  void initState() {
    super.initState();
    animaCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    getCpuInfo();
  }

  Future<void> getCpuInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    while (mounted) {
      String globalStateRaw = File(
        '/sys/devices/system/cpu/cpu0/core_ctl/global_state',
      ).readAsStringSync();
      // print(globalStateRaw);
      RegExp busy = RegExp('Busy.*');
      Iterable<RegExpMatch> allMatches = busy.allMatches(globalStateRaw);
      String cpuInfo = '';
      for (var match in allMatches) {
        cpuInfo += match.group(0).replaceAll('Busy%: ', '') + '\n';
        print(match.group(0));
      }
      // print(cpuInfo);
      cpuBusyRadio.clear();
      cpuBusyRadio.setBusyRatio(cpuInfo);

      await Future<void>.delayed(const Duration(milliseconds: 1000));
    }
    // String result = await CustomProcess.exec(
    //     'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq\n' +
    //         'cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq\n' );
    // 'cat /sys/devices/system/cpu/cpu0/core_ctl/global_state | busybox grep \'Busy\' | busybox sed 's/Busy%: //g'');

    // print(result);
  }

  @override
  Widget build(BuildContext context) {
    cpuBusyRadio = Get.find();
    // print(cpuBusyRadio.cpuBusyRatio);
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 20.0,
        ),

        const DividerAndText('四小核'),
        SizedBox(
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (BuildContext c, int i) {
              return Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                child: _SingleCpu(
                  cpuIndex: i,
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        const DividerAndText('四大核'),
        SizedBox(
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (BuildContext c, int i) {
              return Padding(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                child: _SingleCpu(
                  cpuIndex: i + 4,
                ),
              );
            },
          ),
        ),

        // SizedBox(
        //   height: 100.0,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: 4,
        //     itemBuilder: (c, i) {
        //       return Padding(
        //         padding: EdgeInsets.only(left: 6.0, right: 6.0),
        //         child: FlutterWaveLoading(
        //           borderRadius: 16.0,
        //           color: Colors.green,
        //           progress: 0.8,
        //           width: deviceWidth / 4 - 12.0,
        //           height: 100,
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class _SingleCpu extends StatefulWidget {
  const _SingleCpu({Key key, this.cpuIndex}) : super(key: key);
  //是第几个CPU
  final int cpuIndex;

  @override
  __SingleCpuState createState() => __SingleCpuState();
}

class __SingleCpuState extends State<_SingleCpu>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    animation =
        Tween<double>(begin: 0.0, end: 0.0).animate(animationController);
    whileGetInfo();
  }

  Future<void> whileGetInfo() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    while (mounted) {
      final double curRatio =
          generalStat.cpuBusyRatio[widget.cpuIndex].toDouble() / 100;
      animation = Tween<double>(
        begin: animation.value,
        end: curRatio,
      ).animate(animationController);
      animationController.reset();
      animationController.forward();
      await Future<void>.delayed(
        const Duration(milliseconds: 1000),
      );
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  GeneralStat generalStat;
  @override
  Widget build(BuildContext context) {
    generalStat = Get.find();
    final double deviceWidth = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext ctx, Widget child) {
        final Color cpuColor = getColor(animation.value);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            FlutterWaveLoading(
              borderRadius: 8.0,
              color: cpuColor,
              progress: animation.value,
              width: deviceWidth / 4 - 12.0,
              height: 100,
            ),
            Center(
              child: Text(
                toPercentage(animation.value),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLightColor(cpuColor.value)
                      ? Theme.of(context).textTheme.bodyText2.color
                      : Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'CPU:${widget.cpuIndex + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLightColor(cpuColor.value)
                        ? Theme.of(context).textTheme.bodyText2.color
                        : Colors.white,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
