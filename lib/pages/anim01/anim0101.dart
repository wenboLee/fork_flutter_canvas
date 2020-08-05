import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim0101Page extends StatefulWidget {
  final String title;

  Anim0101Page({this.title});

  @override
  _Anim0101PageState createState() => _Anim0101PageState();
}

class _Anim0101PageState extends State<Anim0101Page>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Ball _ball;
  double angle = 60 * math.pi / 180, a = 0.05, vx = 0, vy = 0;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _ball = Ball(x: 50, y: 50, r: 30);
    _controller.addListener(() {
      double ax = math.cos(angle) * a;
      double ay = math.sin(angle) * a;
      _ball.x += vx;
      _ball.y += vy;
      vx += ax;
      vy += ay;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBar(widget.title),
      body: Container(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: MyCustomPainter(
                  ball: _ball, angle: angle, a: a, vx: vx, vy: vy),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  final double angle, a, vx, vy;

  MyCustomPainter({this.ball, this.angle, this.a, this.vx, this.vy});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
