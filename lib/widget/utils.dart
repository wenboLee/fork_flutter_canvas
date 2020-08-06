import 'dart:math';
import 'package:flutter/material.dart';

Color randomColor() {
  var red = Random.secure().nextInt(255);
  var greed = Random.secure().nextInt(255);
  var blue = Random.secure().nextInt(255);
  if (red > 100 && greed > 100 && blue > 100) {
    return randomColor();
  } else {
    return Color.fromARGB(255, red, greed, blue);
  }
}