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
  double az;
  double scaleX;
  double scaleY;
  Color strokeStyle;
  Color fillStyle;
  RadialGradient? gradientColor;
  double alpha;
  double g; // 重力
  double m; // 质量
  double friction; // 摩擦力
  bool firstMove;
  bool dragged;
  double scale;
  bool show;
  double strength; //力量
  double value;

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
    this.az = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.strokeStyle = Colors.black,
    this.fillStyle = Colors.blue,
    this.gradientColor,
    this.alpha = 1,
    this.g = 0,
    this.m = 0,
    this.friction = 0.05,
    this.firstMove = true,
    this.dragged = false,
    this.scale = 0,
    this.show = true,
    this.strength = 0,
    this.value = 0,
  });
}
