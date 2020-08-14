import 'package:flutter/cupertino.dart';

class Line {
  int id;
  double x;
  double y;
  Offset p1;
  Offset p2;
  double rotation;

  Line({
    this.id = 0,
    this.x = 0,
    this.y = 0,
    this.p1 = Offset.zero,
    this.p2 = Offset.zero,
    this.rotation = 0,
  });
}
