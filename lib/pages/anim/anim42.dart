import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/line.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim42Page extends StatefulWidget {
  final String title;

  Anim42Page({this.title});

  @override
  _Anim42PageState createState() => _Anim42PageState();
}

class _Anim42PageState extends State<Anim42Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Line _line;
  Ball _ball;
  double g = 0.1, bounce = -0.8, _rotation = toRad(10);

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext.size;
        }
        if (_ball == null) {
          var r = _size.width / 4 * 1 / 4;
          _ball = Ball(
            x: r + 50,
            y: r + 50,
            r: r,
          );
        }
        if (_line == null) {
          var p1 = Offset(50, 200);
          var p2 = Offset(_size.width * 3 / 4, 200);
          _line = Line(
            x: (p2.dx - p1.dx).abs() / 2 + p1.dx,
            y: (p2.dy - p1.dy).abs() / 2 + p1.dy,
            p1: p1,
            p2: p2,
            rotation: _rotation,
          );
          // 旋转直线进行高级坐标旋转p1为圆心
          var dxp2 = (p2.dx - p1.dx).abs();
          var dyp2 = (p2.dy - p1.dy).abs();
          var dx = dxp2 * math.cos(_rotation) - dyp2 * math.sin(_rotation);
          var dy = dyp2 * math.cos(_rotation) + dxp2 * math.sin(_rotation);
          _line.p2 = Offset(dx + p1.dx, dy + p1.dy);
          _line.x = (_line.p2.dx - p1.dx).abs() / 2 + p1.dx;
          _line.y = (_line.p2.dy - p1.dy).abs() / 2 + p1.dy;
        }

        _ball.vy += g;
        _ball.x += _ball.vx;
        _ball.y += _ball.vy;

        //处理斜面反弹
        _checkBallMove(_ball, _line, _rotation);
        // 处理和边界反弹
        checkBallBounce(_ball, _size, bounce);
      }
    });
    super.initState();
  }

  void _checkBallMove(Ball ball, Line line, double rotation) {
    // 获取小球相对线的中心点坐标, 类比圆心
    var rx = line.x - ball.x;
    var ry = line.y - ball.y;

    // 对小球坐标进行高级坐标旋转
    var x1 = rx * math.cos(rotation) + ry * math.sin(rotation);
    var y1 = ry * math.cos(rotation) - rx * math.sin(rotation);

    // 对小球速度进行高级坐标旋转
    var vx1 = ball.vx * math.cos(rotation) + ball.vy * math.sin(rotation);
    var vy1 = ball.vy * math.cos(rotation) - ball.vx * math.sin(rotation);

    // 检测小球和水平线的碰撞
    if (x1 + ball.r > line.p1.dx && x1 - ball.r < line.p2.dx) {
      if (y1 + ball.r > 0 && vy1 > y1) {
        y1 = -_ball.r;
        vy1 *= bounce;
      }
      if (y1 - ball.r < 0 && vy1 < y1) {
        y1 = ball.r;
        vy1 *= bounce;
      }
    }

    // 将整个系统利用高级坐标旋转回初始位置
    rx = x1 * math.cos(rotation) - y1 * math.sin(rotation);
    ry = y1 * math.cos(rotation) + x1 * math.sin(rotation);

    ball.vx = vx1 * math.cos(rotation) - vy1 * math.sin(rotation);
    ball.vy = vy1 * math.cos(rotation) + vx1 * math.sin(rotation);

    // 类别圆心
    ball.x = line.x + rx;
    ball.y = line.y + ry;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.title),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: MyCustomPainter(ball: _ball, line: _line),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  final Line line;

  MyCustomPainter({this.ball, this.line});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas, size);

    _paint.color = Colors.red;
    canvas.drawLine(line.p1, line.p2, _paint);
    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(line.x, line.y), 2, _paint);

    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
