String toPercentage(double scale) {
  if (scale.isNaN) {
    return '0%';
  }
  return '${(scale * 100).toInt()}%';
}
