import 'package:flutter/material.dart';

class Box {
  int id;
  double x;
  double y;
  double w;
  double h;
  double vx;
  double vy;
  Color fillStyle;

  Box({
    this.id = 0,
    this.x = 0,
    this.y = 0,
    this.w = 60,
    this.h = 30,
    this.vx = 0,
    this.vy = 0,
    this.fillStyle = Colors.blue,
  });
}
