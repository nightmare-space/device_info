class CpuInfo {
  List<SingleCpuInfo> cpuInfos = [];
  SingleCpuInfo get cpu1 => cpuInfos[0];
  SingleCpuInfo get cpu2 => cpuInfos[1];
  SingleCpuInfo get cpu3 => cpuInfos[2];
  SingleCpuInfo get cpu4 => cpuInfos[3];
  SingleCpuInfo get cpu5 => cpuInfos[4];
  SingleCpuInfo get cpu6 => cpuInfos[5];
  SingleCpuInfo get cpu7 => cpuInfos[6];
  SingleCpuInfo get cpu8 => cpuInfos[7];
}

class SingleCpuInfo {
  SingleCpuInfo(this.frequency);
  
  final int frequency;
}
