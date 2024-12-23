import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'device_info.dart';
import 'controller/device_controller.dart';
import 'v2/dashboard.dart';

void main() {
  runApp(MyApp());
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.device_info');
  AASClient client = AASClient(port: 15000);
  Get.put(client);
  Get.put(DeviceInfoController());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // showPerformanceOverlay: true,
      home: Scaffold(
        body: DeviceDashboard(
          serial: '192.168.31.111:5555',
        ),
      ),
    );
  }
}
