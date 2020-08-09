import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'dart:math' as math;

class Anim07Page extends StatefulWidget {
  final String title;

  Anim07Page({this.title});

  @override
  _Anim07PageState createState() => _Anim07PageState();
}

class _Anim07PageState extends State<Anim07Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double angle = 0, speed = 0.015, ovalW = 0, ovalH = 0;

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
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
          ovalW = _size.width * 0.4;
          ovalH = _size.height * 0.8;
        }
        _ball.x = _size.width / 2 + (ovalW / 2) * math.cos(angle);
        _ball.y = _size.height / 2 + (ovalH / 2) * math.sin(angle);
        angle += speed;
        angle %= math.pi * 2;
      }
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
              painter: MyCustomPainter(ball: _ball, ovalW: ovalW, ovalH: ovalH),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  final double ovalW, ovalH;

  MyCustomPainter({this.ball, this.ovalW, this.ovalH});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _paint.color = Colors.black;
    _paint.style = PaintingStyle.stroke;
    Offset center = size.center(Offset.zero);
    canvas.drawOval(
        Rect.fromCenter(
            center: center, width: ovalW, height: ovalH),
        _paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), _paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), _paint);

    _paint.color = ball.fillStyle;
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    _paint.color = Colors.red;

    canvas.drawLine(center, Offset(ball.x, ball.y), _paint);
    canvas.drawLine(Offset(0, ball.y), Offset(size.width, ball.y), _paint);
    canvas.drawLine(Offset(ball.x, 0), Offset(ball.x, size.height), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
