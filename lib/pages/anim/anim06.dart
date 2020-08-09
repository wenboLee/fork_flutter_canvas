import 'package:flutter/material.dart';
import 'package:flutter_canvas/main.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'dart:math' as math;

class Anim06Page extends StatefulWidget {
  final String title;

  Anim06Page({this.title});

  @override
  _Anim06PageState createState() => _Anim06PageState();
}

class _Anim06PageState extends State<Anim06Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double angle = 0, swing = 0; // 振幅

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
          swing = _size.width / 2 - _ball.r;
        }
        _ball.x = _size.width / 2 + math.sin(angle) * swing;
        // 扇形弧度半个
        var ay = math.atan2(_size.width / 2 - _ball.x, _ball.y);
        // 扇形半径
        var r = math
            .sqrt(math.pow(_size.width / 2, 2) + math.pow(_size.height / 2, 2));

        _ball.y = r * math.cos(ay);
        angle += 0.05;
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
              painter: MyCustomPainter(ball: _ball),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;

  MyCustomPainter({this.ball});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    _paint.color = Colors.red;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(ball.x, ball.y), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
