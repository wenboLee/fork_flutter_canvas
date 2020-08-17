import 'package:flutter/material.dart';

class Line {
  int id;
  double x;
  double y;
  Offset p1;
  Offset p2;
  double rotation;
  double lineWidth;
  double alpha;
  Color fillStyle;

  Line({
    this.id = 0,
    this.x = 0,
    this.y = 0,
    this.p1 = Offset.zero,
    this.p2 = Offset.zero,
    this.rotation = 0,
    this.lineWidth = 0,
    this.alpha = 0,
    this.fillStyle = Colors.blue,
  });
}
