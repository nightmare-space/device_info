import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:global_repository/global_repository_dart.dart';
import 'package:test/test.dart';
import 'package:adb_util/adb_util.dart';

void main() {
  int testCount = 3000;
  String serial = '192.168.31.110:5555';
  RuntimeEnvir.initEnvirWithPackageName('adb_kit_util', appSupportDirectory: './');
  AASClient aas = AASClient(port: 15000);
  // api 3000 times avg 50.88
  test('test exec cmd with start', () async {
    int sumTime = 0;
    await aas.api.getProcStat(key: 'aas');
    for (int i = 0; i < testCount; i++) {
      final Stopwatch stopwatch = Stopwatch()..start();
      String result = await aas.api.getProcStat(key: 'aas');
      // print(result);
      // print('耗时:${stopwatch.elapsedMilliseconds}');
      sumTime += stopwatch.elapsedMilliseconds;
    }
    print('平均耗时:${sumTime / testCount}');
  });
  // process 3000 times avg 48.33
  test('test exec cmd with run', () async {
    int sumTime = 0;
    for (int i = 0; i < testCount; i++) {
      final Stopwatch stopwatch = Stopwatch()..start();
      String result = await runShell(serial: serial, command: 'cat /proc/stat');
      // print(result);
      // print('耗时:${stopwatch.elapsedMilliseconds}');
      sumTime += stopwatch.elapsedMilliseconds;
    }
    print('平均耗时:${sumTime / testCount}');
  });
}
