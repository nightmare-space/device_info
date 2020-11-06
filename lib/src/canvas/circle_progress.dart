import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  CircleProgress(this.progress, this._size, this.color);
  Paint _paintBackground;
  Paint _paintFore;
  Color color;
  double progress;
  final double _size;

  @override
  void paint(Canvas canvas, Size size) {
    // final Gradient gradient = new SweepGradient(
    //   colors: [
    //     Colors.white,
    //     color,
    //   ],
    // );

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - _size,
    );
    _paintBackground = Paint()
      ..color = Colors.grey
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
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 2 - _size, _paintBackground);
    canvas.drawArc(rect, 0, progress * 2 * pi, false, _paintFore);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
