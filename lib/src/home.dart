import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/battery.dart';
import 'pages/device.dart';
import 'pages/general.dart';
import 'pages/memory.dart';
import 'pages/system.dart';
import 'provider/general_stat.dart';

class DeviceInfo extends StatefulWidget {
  @override
  _DeviceInfoState createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 11, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // debugRepaintRainbowEnabled
    return MaterialApp(
      // showPerformanceOverlay: true,
      // // showSemanticsDebugger: true,
      // checkerboardRasterCacheImages: true,
      // checkerboardOffscreenLayers: true,
      // debugShowCheckedModeBanner: true,
      // debugShowMaterialGrid: true,
      theme: ThemeData(
        fontFamily: Platform.isLinux ? 'SourceHanSansSC-Light' : null,
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: const Color(0xb3ffffff),
          ),
        ),
        accentColor: const Color(0xff6002ee),
        primaryColorBrightness: Brightness.light,
        backgroundColor: Colors.black,
        // tabBarTheme: TabBarTheme(
        //   labelColor: Color(0xff6002ee),
        // ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: const Color(0xb3ffffff),
          ),
          textTheme: TextTheme(
            headline6: TextStyle(
              color: const Color(0xb3ffffff),
              fontSize: 18.0,
            ),
          ),
          color: const Color(0xff303030),
        ),
        scaffoldBackgroundColor: const Color(0xff303030),
      ),
      home: ChangeNotifierProvider<GeneralStat>(
        create: (_) => GeneralStat(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: const Text(
              '设备信息',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              isScrollable: true,
              indicatorPadding: const EdgeInsets.only(left: 20.0),
              indicator: const RoundedUnderlineTabIndicator(
                // insets:EdgeInsets.all(16.0),
                radius: 25.0,
                width: 72.0,
                borderSide: BorderSide(
                  width: 4.0,
                  color: Color(0xff6002ee),
                ),
                // color: Color(0xff6002ee),
                // borderRadius: BorderRadius.only(
                //     topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              ),
              controller: tabController,
              labelStyle: const TextStyle(
                color: Color(0xff6002ee),
              ),
              labelColor: const Color(0xff6002ee),
              unselectedLabelColor: Colors.black,
              tabs: const <Widget>[
                Tab(
                  child: Text('设备概况'),
                ),
                Tab(
                  child: Text('设备'),
                ),
                Tab(
                  child: Text('系统'),
                ),
                Tab(
                  child: Text('电池'),
                ),
                Tab(
                  child: Text('储存器'),
                ),
                Tab(
                  child: Text('芯片'),
                ),
                Tab(
                  child: Text('网络'),
                ),
                Tab(
                  child: Text('屏幕'),
                ),
                Tab(
                  child: Text('摄像头'),
                ),
                Tab(
                  child: Text('温度'),
                ),
                Tab(
                  child: Text('传感器'),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: <Widget>[
              General(),
              Device(),
              SystemInfo(),
              Battery(),
              Memory(),
              const Text('还没写'),
              const Text('还没写'),
              const Text('还没写'),
              const Text('还没写'),
              const Text('还没写'),
              const Text('还没写'),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundedUnderlineTabIndicator extends Decoration {
  const RoundedUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.radius,
    this.width,
  })  : assert(borderSide != null),
        assert(insets != null);
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final double radius;
  final double width;

  @override
  Decoration lerpFrom(Decoration a, double t) {
    if (a is RoundedUnderlineTabIndicator) {
      return RoundedUnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t),
        radius: radius ?? borderSide.width * 5,
        width: width,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration lerpTo(Decoration b, double t) {
    if (b is RoundedUnderlineTabIndicator) {
      return RoundedUnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
        radius: radius ?? borderSide.width * 5,
        width: width,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _RoundedUnderlinePainter createBoxPainter([VoidCallback onChanged]) {
    return _RoundedUnderlinePainter(
      this,
      onChanged,
      radius: radius ?? borderSide.width * 5,
      width: width,
    );
  }
}

class _RoundedUnderlinePainter extends BoxPainter {
  _RoundedUnderlinePainter(
    this.decoration,
    VoidCallback onChanged, {
    @required this.radius,
    this.width,
  })  : assert(decoration != null),
        super(onChanged);
  final double radius;
  final double width;

  final RoundedUnderlineTabIndicator decoration;

  BorderSide get borderSide => decoration.borderSide;
  EdgeInsetsGeometry get insets => decoration.insets;

  RRect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return RRect.fromRectAndCorners(
      width == null
          ? Rect.fromLTWH(
              indicator.left,
              indicator.bottom - borderSide.width,
              indicator.width,
              borderSide.width,
            )
          : Rect.fromCenter(
              center: Offset(
                indicator.left + indicator.width / 2,
                indicator.bottom - borderSide.width,
              ),
              width: width,
              height: borderSide.width,
            ),
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    final RRect indicator =
        _indicatorRectFor(rect, textDirection).deflate(borderSide.width);
    final Paint paint = borderSide.toPaint()
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill;
    // Paint _paintFore = Paint()
    //   ..color = Colors.red
    //   ..strokeCap = StrokeCap.round
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2
    //   ..isAntiAlias = true;
    canvas.drawRRect(indicator, paint);
  }
}
