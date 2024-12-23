import 'dart:async';

import 'package:adb_util/adb_util.dart';
import 'package:device_info/model/ram_info.dart';
import 'package:get/get.dart';
// /proc/meminfo 文件包含了关于系统内存使用情况的详细信息。以下是各个字段的解释：

// MemTotal: 总内存大小。
// MemFree: 空闲内存大小。
// MemAvailable: 可用内存大小，表示系统可以分配给新进程而不需要交换的内存。
// Buffers: 用于缓存文件系统元数据的内存。
// Cached: 用于缓存文件数据的内存。
// SwapCached: 已经被交换出来但仍然在交换缓存中的内存。
// Active: 活跃的内存，最近被使用过的内存。
// Inactive: 不活跃的内存，最近没有被使用过的内存。
// Active(anon): 活跃的匿名内存。
// Inactive(anon): 不活跃的匿名内存。
// Active(file): 活跃的文件缓存内存。
// Inactive(file): 不活跃的文件缓存内存。
// Unevictable: 不可回收的内存。
// Mlocked: 被锁定在内存中的内存。
// SwapTotal: 交换分区的总大小。
// SwapFree: 空闲的交换分区大小。
// Dirty: 等待写回到磁盘的内存。
// Writeback: 正在写回到磁盘的内存。
// AnonPages: 匿名页内存。
// Mapped: 映射到用户空间的内存。
// Shmem: 共享内存。
// KReclaimable: 可回收的内核内存。
// Slab: 内核数据结构缓存的内存。
// SReclaimable: 可回收的Slab内存。
// SUnreclaim: 不可回收的Slab内存。
// KernelStack: 内核栈的内存。
// ShadowCallStack: 阴影调用栈的内存。
// PageTables: 页表使用的内存。
// SecPageTables: 安全页表使用的内存。
// NFS_Unstable: 不稳定的NFS页。
// Bounce: 用于块设备I/O的内存。
// WritebackTmp: 用于临时写回的内存。
// CommitLimit: 系统可承诺的内存限制。
// Committed_AS: 已承诺的内存。
// VmallocTotal: 可用的虚拟内存总量。
// VmallocUsed: 已使用的虚拟内存。
// VmallocChunk: 最大的连续虚拟内存块。
// Percpu: 每个CPU的内存。
// AnonHugePages: 匿名大页内存。
// ShmemHugePages: 共享内存大页。
// ShmemPmdMapped: 共享内存PMD映射。
// FileHugePages: 文件大页内存。
// FilePmdMapped: 文件PMD映射。
// CmaTotal: CMA区域的总内存。
// CmaFree: CMA区域的空闲内存。

class RamController extends GetxController {
  RamInfo ramInfo = RamInfo(0, 0);
  String get serial => Get.find<String>(tag: 'serial');
  Future<void> getRamInfo() async {
    // cat /proc/meminfo
    final String meminfo = await runShell(serial: serial, command: 'cat /proc/meminfo');
    final List<String> lines = meminfo.split('\n');
    final String ram = lines.first.split(RegExp('\\s+'))[1];
    final String free = lines[2].split(RegExp('\\s+'))[1];
    ramInfo.total = int.tryParse(ram);
    ramInfo.free = int.tryParse(free);
    update();
    // Log.i('ram :  $ram');
  }

  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      getRamInfo();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
