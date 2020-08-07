import 'package:flutter/material.dart';

class Arrow {
  int id;
  double x;
  double y;
  double w;
  double h;
  double rotation;
  Color fillStyle;
  Color strokeStyle;

  Arrow({
    this.id = 0,
    this.x = 0,
    this.y = 0,
    this.w = 60,
    this.h = 30,
    this.rotation = 0,
    this.strokeStyle = Colors.black,
    this.fillStyle = Colors.blue,
  });
}
