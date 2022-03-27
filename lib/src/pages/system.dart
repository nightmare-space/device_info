import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class SystemInfo extends StatefulWidget {
  @override
  _SystemInfoState createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  String props;
  Map<String, String> keys = <String, String>{
    '版本名': 'ro.build.version.release',
    'API版本': 'ro.build.version.sdk',
    '系统版本号': 'ro.build.display.id',
    '构建时间': 'ro.system.build.date.utc',
    '设备版本号': 'ro.build.id',
    '程序安全补丁级别': 'ro.build.version.security_patch',
    '基带版本': 'gsm.version.baseband',
    '指纹': 'ro.build.fingerprint',
    '语言': 'ro.product.local',
    '时区': 'persist.sys.timezone',
    '设备架构': 'ro.product.cpu.abi',
    '支持的架构列表': 'ro.product.cpu.abilist',
    'ROOT权限': null,
    '已开机时长': null,
  };
  Map<String, String> values = <String, String>{};
  @override
  void initState() {
    super.initState();
    initSystem();
  }

  String getValueFromProps(String key) {
    final List<String> tmp = props.split('\n');
    for (final String line in tmp) {
      if (line.contains(key)) {
        return line.replaceAll(RegExp('.*\\]:|\\[|\\]'), '');
      }
    }
    return '';
    // print(key);
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  Future<void> initSystem() async {
    props = await exec('getprop');
    for (final String key in keys.keys) {
      if (keys[key] != null) {
        values[key] = getValueFromProps(keys[key]);
      }
    }
    String time = await exec('cat /proc/uptime');
    final String uptime =
        (await exec('cat /proc/uptime')).split(' ').first.replaceAll('.', '');
    print('uptime->$uptime');
    DateTime dateTime = DateTime(0, 0, 0, 0, 0, int.tryParse(uptime) ~/ 100);
    values['已开机时长'] =
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
    values['内核信息'] = await exec('cat /proc/version');
    final bool isRoot = (await exec('which su')) != '';
    if (isRoot) {
      values['ROOT权限'] = '已获取ROOT权限';
    } else {
      values['ROOT权限'] = '未获取ROOT权限';
    }
    values['ROOT版本'] = await exec('su -v');
    final String sysBbPath = (await Process.run(
            '/system/bin/which', <String>['busybox'],
            includeParentEnvironment: true))
        .stdout
        .toString();
    final bool sysHasBusybox = sysBbPath != '';
    if (sysHasBusybox) {
      values['系统Busybox路径'] = sysBbPath;
    } else {
      values['系统Busybox路径'] = '未发现Busybox';
    }
    final String appBbPath = await exec('which busybox');
    final bool appHasBusybox = appBbPath != '';
    if (appHasBusybox) {
      values['工具箱Busybox路径'] = appBbPath;
    } else {
      values['工具箱Busybox路径'] = '未发现Busybox';
    }
    values['构建时间'] =
        '${DateTime.fromMillisecondsSinceEpoch(int.tryParse(values['构建时间']) * 1000)}';
    values['系统环境变量'] =
        (await Process.run('env', <String>[], includeParentEnvironment: true))
            .stdout
            .toString();
    // print();
    setState(() {});
    Timer timer;
    Future<void>.delayed(const Duration(), () {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          dateTime = dateTime.add(const Duration(seconds: 1));
          values['已开机时长'] =
              '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
          setState(() {});
        } else {
          timer.cancel();
        }
      });
    });
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
