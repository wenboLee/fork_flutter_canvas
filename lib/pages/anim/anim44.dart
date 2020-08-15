import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim44Page extends StatefulWidget {
  final String title;

  Anim44Page({this.title});

  @override
  _Anim44PageState createState() => _Anim44PageState();
}

class _Anim44PageState extends State<Anim44Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball1, _ball2;
  double _bounce = -1;

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
        if (_ball1 == null) {
          double r = 40;
          _ball1 = Ball(
            x: randomScope([0, _size.width - r]),
            y: randomScope([0, _size.height - r]),
            r: r,
            fillStyle: Colors.red,
            m: 4,
            vx: randomScope([-5, 5]),
            vy: randomScope([-5, 5]),
          );
        }
        if (_ball2 == null) {
          double r = 60;
          _ball2 = Ball(
            x: randomScope([0, _size.width - r]),
            y: randomScope([0, _size.height - r]),
            r: r,
            fillStyle: Colors.blue,
            m: 6,
            vx: randomScope([-5, 5]),
            vy: randomScope([-5, 5]),
          );
        }

        _ball1.x += _ball1.vx;
        _ball1.y += _ball1.vy;
        _ball2.x += _ball2.vx;
        _ball2.y += _ball2.vy;

        _checkMove(_ball1, _ball2);

        // 边界检测
        checkBallBounce(_ball1, _size, _bounce);
        checkBallBounce(_ball2, _size, _bounce);
      }
    });
    super.initState();
  }

  void _checkMove(Ball b1, Ball b2) {
    var dx = b2.x - b1.x;
    var dy = b2.y - b1.y;
    var dist = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2));
    if (dist < b1.r + b2.r) {
      var angle = math.atan2(dy, dx);
      var sin = math.sin(angle);
      var cos = math.cos(angle);

      // 以b1为参照物，设定b1中心点为旋转基点
      double x1 = 0, y1 = 0;
      var x2 = dx * cos + dy * sin;
      var y2 = dy * cos - dx * sin;

      // 旋转b1和b2的速度
      var vx1 = b1.vx * cos + b1.vy * sin;
      var vy1 = b1.vy * cos - b1.vx * sin;
      var vx2 = b2.vx * cos + b2.vy * sin;
      var vy2 = b2.vy * cos - b2.vx * sin;

      // 求出b1和b2碰撞后的速度,动能守恒
      var vx1Final = ((b1.m - b2.m) * vx1 + 2 * b2.m * vx2) / (b1.m + b2.m);
      var vx2Final = ((b2.m - b1.m) * vx2 + 2 * b1.m * vx1) / (b1.m + b2.m);

      // 处理两个小球碰撞后，将他们归位
      var lep = (b1.r + b2.r) - (x2 - x1).abs();
      x1 = x1 + (vx1Final < 0 ? -lep / 2 : lep / 2);
      x2 = x2 + (vx2Final < 0 ? -lep / 2 : lep / 2);

      b2.x = b1.x + (x2 * cos - y2 * sin);
      b2.y = b1.y + (y2 * cos + x2 * sin);
      b1.x = b1.x + (x1 * cos - y1 * sin);
      b1.y = b1.y + (y1 * cos + x1 * sin);

      b1.vx = vx1Final * cos - vy1 * sin;
      b1.vy = vy1 * cos + vx1Final * sin;
      b2.vx = vx2Final * cos - vy2 * sin;
      b2.vy = vy2 * cos + vx2Final * sin;
    }
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
              painter: MyCustomPainter(ball1: _ball1, ball2: _ball2),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball1;
  final Ball ball2;

  MyCustomPainter({this.ball1, this.ball2});

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

    _paint.color = ball1.fillStyle;
    canvas.drawCircle(Offset(ball1.x, ball1.y), ball1.r, _paint);

    _paint.color = ball2.fillStyle;
    canvas.drawCircle(Offset(ball2.x, ball2.y), ball2.r, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
