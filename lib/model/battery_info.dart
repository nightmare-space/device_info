class BatteryInfo {
  BatteryInfo();

  factory BatteryInfo.parseFormDumpsys(String data) {
    BatteryInfo info = BatteryInfo();
    info.health = int.tryParse(getValueFromProps('health', data));
    info.level = int.tryParse(getValueFromProps('level', data));
    info.temperature =
        double.tryParse(getValueFromProps('temperature', data))! / 10;
    info.technology = getValueFromProps('technology', data);
    info.voltage = getValueFromProps('voltage', data);
    info.status = int.tryParse(getValueFromProps('status', data));
    return info;
  }
  bool? acPowered;
  bool? usbPowerd;
  bool? wirelessPowerd;
  int? status;
  int? health;
  bool? present;
  int? level;
  String? voltage;
  double? temperature;
  String? technology;
}

String getValueFromProps(String key, String data) {
  final List<String> tmp = data.split('\n');
  for (final String line in tmp) {
    if (line.trim().startsWith(key)) {
      return line.replaceAll(RegExp('.*:'), '').trim();
    }
  }
  return '';
  // print(key);
}
