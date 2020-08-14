import 'package:flutter/material.dart';

class Ball {
  int id;
  double x;
  double y;
  double x3d;
  double y3d;
  double z3d;
  double r;
  double vx;
  double vy;
  double vz;
  double scaleX;
  double scaleY;
  Color strokeStyle;
  Color fillStyle;
  double alpha;
  double g; // 重力
  double m; // 质量
  double friction; // 摩擦力
  bool firstMove;
  bool dragged;
  bool inside; // 球远离屏幕面

  Ball({
    this.id = 0,
    this.x = 0,
    this.y = 0,
    this.x3d = 0,
    this.y3d = 0,
    this.z3d = 0,
    this.r = 20,
    this.vx = 0,
    this.vy = 0,
    this.vz = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.strokeStyle = Colors.black,
    this.fillStyle = Colors.blue,
    this.alpha = 1,
    this.g = 0,
    this.m = 0,
    this.friction = 0.05,
    this.firstMove = true,
    this.dragged = false,
    this.inside = false,
  });
}
