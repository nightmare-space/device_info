import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class Device extends StatefulWidget {
  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  late String props;
  Map<String, String> values = <String, String>{};
  Map<String, String> keys = <String, String>{
    '型号': 'ro.product.model',
    '制造商': 'ro.product.manufacture',
    '设备': 'ro.product.device',
    '主板': 'ro.product.name',
    '平台': 'ro.hardware',
    '品牌': 'ro.product.brand',
  };
  @override
  void initState() {
    super.initState();
    initSystem();
  }

  String getValueFromProps(String? key) {
    final List<String> tmp = props.split('\n');
    for (final String line in tmp) {
      if (line.contains(key!)) {
        return line.replaceAll(RegExp('.*\\]:|\\[|\\]'), '');
      }
    }
    return '';
    // print(key);
  }

  Future<void> initSystem() async {
    props = await exec('getprop');
    for (final String key in keys.keys) {
      if (keys[key] != null) {
        values[key] = getValueFromProps(keys[key]);
      }
    }

    setState(() {});
    // print(getValueFromProps("ro.build.version.sdk"));
    // print(props);
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
                    values[values.keys.elementAt(i)]!,
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
