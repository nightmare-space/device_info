class Global {
  // 工厂模式

  factory Global() => _getInstance();
  Global._internal() {}

  static Global get instance => _getInstance();

  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  void setDevice(String id) {}
  String device;
}
