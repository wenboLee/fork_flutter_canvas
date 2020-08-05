import 'package:flutter/material.dart';

class Ball {
  double x = 0;
  double y = 0;
  double x3d = 0;
  double y3d = 0;
  double z3d = 0;
  double r = 20;
  double vx = 0;
  double vy = 0;
  double vz = 0;
  double scaleX = 1;
  double scaleY = 1;
  Color strokeStyle = Color.fromARGB(0, 0, 0, 0);
  Color fillStyle = Color.fromARGB(1, 57, 119, 224);
  double alpha = 1;

  Ball({
    this.x,
    this.y,
    this.x3d,
    this.y3d,
    this.z3d,
    this.r,
    this.vx,
    this.vy,
    this.vz,
    this.scaleX,
    this.scaleY,
    this.strokeStyle,
    this.fillStyle,
    this.alpha,
  });
}
