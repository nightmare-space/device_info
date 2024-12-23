import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  CircleProgress(this.progress, this._size, this.color, this.background);
  late Paint _paintBackground;
  late Paint _paintFore;
  Color color;
  Color background;
  double progress;
  final double _size;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - _size,
    );
    _paintBackground = Paint()
      ..color = background
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = _size
      ..isAntiAlias = true;
    _paintFore = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = _size
      ..isAntiAlias = true;
    canvas.translate(0.0, size.width);
    canvas.rotate(-pi / 2);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - _size, _paintBackground);
    canvas.drawArc(rect, 0, progress * 2 * pi, false, _paintFore);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
