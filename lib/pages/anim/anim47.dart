import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim47Page extends StatefulWidget {
  final String title;

  Anim47Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim47PageState createState() => _Anim47PageState();
}

class _Anim47PageState extends State<Anim47Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball>? _balls;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext!.size!;
        }
        if (_balls == null) {
          _balls = _initBalls(num: 50);
        }

        _move();
      }
    });
    super.initState();
  }

  void _move() {
    for (var i = 0; i < _balls!.length; i++) {
      Ball ball = _balls![i];
      ball.x += ball.vx;
      ball.y += ball.vy;
      for (var j = i + 1; j < _balls!.length; j++) {
        var target = _balls![j];
        _gravitate(ball, target);
        checkBallHit(ball, target);
      }
    }
  }

  // 两球引力
  void _gravitate(Ball b1, Ball b2) {
    double dx = b2.x - b1.x;
    double dy = b2.y - b1.y;
    num distSq = math.pow(dx, 2) + math.pow(dy, 2);
    double dist = math.sqrt(distSq);
    // 万有引力与他们质量乘积成正比于他们距离平方成反比
    // force = G * m1 * m2 / dist^2
    // G 引力常数 G = 6.674*10^-11
    // 动画中一般设置G = 1
    // force = m1 * m2 / dist^2
    // 加速度向量
    // va1 = force / m1
    // va2 = -force / m2
    var force = b1.m * b2.m / distSq;
    // 引力分解
    var forceX = force * dx / dist; // cosA = dx / dist
    var forceY = force * dy / dist; // sinA = dy / dist

    b1.vx += forceX / b1.m;
    b1.vy += forceY / b1.m;
    b2.vx -= forceX / b2.m;
    b2.vy -= forceY / b2.m;
  }

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: randomScope([0, _size.width]),
        y: randomScope([0, _size.height]),
        r: 5,
        fillStyle: randomColor(),
        m: 1,
      ),
    );
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
              painter: _balls == null ? null : MyCustomPainter(balls: _balls!),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _balls = _initBalls(num: 50);
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Ball> balls;

  MyCustomPainter({required this.balls});

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

    balls.forEach((ball) {
      _paint.color = ball.fillStyle;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
