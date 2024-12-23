import 'package:flutter/material.dart';

Color getColor(double progress) {
  if (progress.isNaN) {
    return Colors.transparent;
  }
  if (progress < 0.5) {
    return Color.fromRGBO((255 * progress).toInt(), 255, 0, 1);
  } else {
    return Color.fromRGBO(255, 255 - (255 * progress).toInt(), 0, 1);
  }
}

bool isLightColor(int color) {
  return true;
  // return image.getLuminance(color) > 0.5;
  // final double darkness = 1 -
  //     (0.299 * image.getRed(color) +
  //             0.587 * image.getGreen(color) +
  //             0.114 * image.getBlue(color)) /
  //         255;
  // if (darkness < 0.5) {
  //   return true; // It's a light color
  // } else {
  //   return false; // It's a dark color
  // }
}
