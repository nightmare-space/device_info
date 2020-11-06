import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class Battery extends StatefulWidget {
  @override
  _BatteryState createState() => _BatteryState();
}

class _BatteryState extends State<Battery> {
  String batteryInfos;
  Map<String, String> keys = <String, String>{
    '健康状态': 'health',
    '当前电量': 'level',
    '电池温度': 'temperature',
    '技术': 'technology',
    '电压': 'voltage',
    '电池状态': 'status',
  };
  Map<String, String> values = <String, String>{};
  @override
  void initState() {
    super.initState();
    init();
  }

  String getValueFromProps(String key) {
    final List<String> tmp = batteryInfos.split('\n');
    for (final String line in tmp) {
      if (line.trim().startsWith(key)) {
        return line.replaceAll(RegExp('.*:'), '').trim();
      }
    }
    return '';
    // print(key);
  }

  Future<void> init() async {
    while (mounted) {
      batteryInfos = await NiProcess.exec('dumpsys battery');
      for (final String key in keys.keys) {
        if (keys[key] != null) {
          values[key] = getValueFromProps(keys[key]);
        }
      }
      if (values['健康状态'] == '2') {
        values['健康状态'] = '良好';
      }
      values['电池温度'] = values['电池温度'].substring(0, 2) + '℃';
      values['电压'] += 'mV';
      setState(() {});
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: values.keys.length,
      itemBuilder: (BuildContext c, int i) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  child: Text(
                    values.keys.elementAt(i),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    values[values.keys.elementAt(i)],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
