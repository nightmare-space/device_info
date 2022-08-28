import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
export 'home.dart';
export 'global/global.dart';

// class DeviceInfo {
//   // static const MethodChannel _channel =
//   //     const MethodChannel('device_info');

//   // static Future<String> get platformVersion async {
//   //   final String version = await _channel.invokeMethod('getPlatformVersion');
//   //   return version;
//   // }
// }

Future<String> execCmd(
  String cmd, {
  bool throwException = true,
}) async {
  final List<String> args = cmd.split(' ');
  final Map<String, String> envir = RuntimeEnvir.envir();
  envir['TMPDIR'] = RuntimeEnvir.binPath;
  envir['HOME'] = RuntimeEnvir.binPath;
  envir['LD_LIBRARY_PATH'] = RuntimeEnvir.binPath;
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: true,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: envir,
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    if (throwException) {
      // Log.w('adb stderr -> ${execResult.stderr}');
      throw Exception(execResult.stderr);
    }
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}
