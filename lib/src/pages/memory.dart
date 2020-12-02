import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class RamSwapInfo {
  RamSwapInfo();
  RamSwapInfo.parse(String freeOut) {
    final List<String> list = freeOut.split('\n');
    list.removeAt(0);
    // SystemChannels..;
    // print(list);
    final List<String> ramInfoList = list.first.split(RegExp('\\s+'));
    final List<String> swapInfoList = list.first.split(RegExp('\\s+'));
    ramFullSize = int.tryParse(ramInfoList[1]);
    ramUsed = int.tryParse(ramInfoList[2]);
    ramFree = int.tryParse(ramInfoList[3]);
    swapFullSize = int.tryParse(swapInfoList[1]);
    swapUsed = int.tryParse(swapInfoList[2]);
    swapFree = int.tryParse(swapInfoList[3]);
    ramFullSizeStr = FileSizeUtils.getFileSize(ramFullSize);
    ramFreeStr = FileSizeUtils.getFileSize(
        ramFree + int.tryParse(list[2].split(RegExp('\\s+'))[3]));
    swapFullSizeStr = FileSizeUtils.getFileSize(swapFullSize);
    swapUsedStr = FileSizeUtils.getFileSize(swapUsed);
  }
  RamSwapInfo.fromMap(Map<String, int> map) {
    ramFullSize = map['totalMem'];
    ramFullSizeStr = FileSizeUtils.getFileSize(ramFullSize, FlashMemoryCell.mb);
    ramFree = map['availMem'];
    ramFreeStr = FileSizeUtils.getFileSize(ramFree, FlashMemoryCell.mb);
    ramUsed = ramFullSize - ramFree;
    swapFullSize = map['totalSwap'];
    swapFullSizeStr =
        FileSizeUtils.getFileSize(swapFullSize, FlashMemoryCell.mb);
    swapUsed = map['usedSwap'];
    swapUsedStr = FileSizeUtils.getFileSize(swapUsed, FlashMemoryCell.mb);
    swapFree = swapFullSize - swapUsed;
  }
  int ramUsed = 1;
  int ramFullSize = 1;
  int ramFree = 1;
  String ramFreeStr;
  String ramFullSizeStr;
  int swapUsed = 1;
  int swapFullSize = 1;
  int swapFree = 1;

  String swapUsedStr;
  String swapFullSizeStr;
  @override
  String toString() {
    return 'ramUsed:$ramUsed  ramFullSize:$ramFullSize  swapUsed:$swapUsed  swapFullSize$swapFullSize';
  }
}

class Memory extends StatefulWidget {
  @override
  _MemoryState createState() => _MemoryState();
}

class _MemoryState extends State<Memory> with SingleTickerProviderStateMixin {
  MethodChannel systemInfo = MethodChannel('device_info');
  AnimationController animationController;
  Animation<double> animation;
  RamSwapInfo ramSwapInfo = RamSwapInfo();
  double ramProgress;

  List<String> rootInfo = <String>[];
  List<String> sdcardInfo = <String>[];
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    animation =
        Tween<double>(begin: 1.0, end: 1.0).animate(animationController);
    animation.addListener(() {
      setState(() {});
    });
    initMemory();
  }

  Future<void> initMemory() async {
    while (mounted) {
      final Map<dynamic, dynamic> systemInfoResult =
          await systemInfo.invokeMethod<Map<dynamic, dynamic>>('getRamStat');
      final Map<String, int> info = systemInfoResult.cast<String, int>();
      // for (var key in systemInfoResult.keys) {}
      final String freeOut = await NiProcess.exec('free');
      // print(freeOut);
      final RegExp swap = RegExp('Swap.*');
      final String swapLine = swap.stringMatch(freeOut);
      final List<String> swapInfos = swapLine.split(RegExp('\\s+'));
      // print(swapInfos);
      info['totalSwap'] = int.tryParse(swapInfos[1]) * 1024;
      info['usedSwap'] = int.tryParse(swapInfos[2]) * 1024;
      info['availSwap'] = int.tryParse(swapInfos[3]) * 1024;
      ramSwapInfo = RamSwapInfo.fromMap(info);
      ramProgress = ramSwapInfo == null
          ? 0.0
          : ramSwapInfo.ramUsed.toDouble() / ramSwapInfo.ramFullSize.toDouble();
      if (!animationController.isAnimating) {
        animation = Tween<double>(begin: ramProgress, end: ramProgress)
            .animate(animationController);
      }
      if (mounted) {
        setState(() {});
      }
      final String result = await NiProcess.exec('df');
      // print(result);
      final List<String> infos = result.split('\n');
      for (final String line in infos) {
        if (line.endsWith('/')) {
          rootInfo = line.split(RegExp(r'\s{1,}'));
          setState(() {});
        }
        if (line.endsWith('/data')) {
          sdcardInfo = line.split(RegExp(r'\s{1,}'));
          setState(() {});
        }
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            // await CustomProcess.exec("echo 3 > /proc/sys/vm/drop_caches");
            final Map<String, int> info =
                await systemInfo.invokeMethod<Map<String, int>>('getRamStat');

            final String freeOut = await NiProcess.exec('free');
            final List<String> swapInfos = (freeOut.split('\n')
                  ..removeAt(0)
                  ..removeAt(0))
                .first
                .split(RegExp('\\s+'));
            // print(swapInfos);
            info['totalSwap'] = int.tryParse(swapInfos[1]) * 1024;
            info['usedSwap'] = int.tryParse(swapInfos[2]) * 1024;
            info['availSwap'] = int.tryParse(swapInfos[3]) * 1024;
            ramSwapInfo = RamSwapInfo.fromMap(info);
            animation = Tween<double>(begin: ramProgress, end: 0)
                .animate(animationController);
            animationController.forward().then((_) {
              animationController.reverse();
            });
            ramProgress = ramSwapInfo == null
                ? 0.0
                : ramSwapInfo.ramUsed.toDouble() /
                    ramSwapInfo.ramFullSize.toDouble();

            animation = Tween<double>(begin: ramProgress, end: 0.0)
                .animate(animationController);
          },
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 30.0,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text(
                    'RAM运行内存',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  height: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: LinearProgressIndicator(
                      value: animation.value,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                    "${ramSwapInfo.ramFreeStr ?? "1"}/${ramSwapInfo.ramFullSizeStr ?? "1"}"),
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 6.0,
              height: 30.0,
              decoration: BoxDecoration(
                // color: YanToolColors.candyColor[1],
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            const Text(
              'SWAP交换分区',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: LinearProgressIndicator(
                value: ramSwapInfo == null
                    ? 0.0
                    : ramSwapInfo.swapUsed.toDouble() /
                        ramSwapInfo.swapFullSize.toDouble(),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
              "${ramSwapInfo.swapUsedStr ?? "1"}/${ramSwapInfo.swapFullSizeStr ?? "1"}"),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 6.0,
              height: 30.0,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            const Text(
              '系统储存',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: LinearProgressIndicator(
                value: rootInfo.isNotEmpty
                    ? double.tryParse(rootInfo[1]) /
                        double.tryParse(rootInfo[2])
                    : 0,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(rootInfo.isNotEmpty
              ? "${FileSizeUtils.getFileSize(int.tryParse(rootInfo[2]) * 1024) ?? "1"}/${FileSizeUtils.getFileSize(int.tryParse(rootInfo[1]) * 1024) ?? "1"}"
              : ''),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 6.0,
              height: 30.0,
              decoration: BoxDecoration(
                // color: YanToolColors.candyColor[3],
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            const Text(
              '内部储存',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ],
        ),

        const SizedBox(
          height: 24.0,
        ),
        Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              height: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: LinearProgressIndicator(
                  value: sdcardInfo.isNotEmpty
                      ? double.tryParse(sdcardInfo[2]) /
                          double.tryParse(sdcardInfo[1])
                      : 0,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).accentColor),
                ),
              ),
            )),
        Align(
          alignment: Alignment.centerRight,
          child: Text(sdcardInfo.isNotEmpty
              ? "${FileSizeUtils.getFileSize(int.tryParse(sdcardInfo[2]) * 1024) ?? "1"}/${FileSizeUtils.getFileSize(int.tryParse(sdcardInfo[1]) * 1024) ?? "1"}"
              : ''),
        ),
        // Text("基本"),
        // Text("RAM运行内存"),
        // Text("内部储存器"),
        // Text("其它分区"),
      ],
    );
  }
}
