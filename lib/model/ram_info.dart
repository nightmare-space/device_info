class RamInfo {
  RamInfo(this.total, this.free);

  int? total;
  int? use;
  int? free;

  double get radio => (total! - free!) / total!;
}
