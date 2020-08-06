import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'dart:math' as math;

import 'package:flutter_canvas/widget/utils.dart';

class Anim05Page extends StatefulWidget {
  final String title;

  Anim05Page({this.title});

  @override
  _Anim05PageState createState() => _Anim05PageState();
}

class _Anim05PageState extends State<Anim05Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls = [];

  _move(Ball ball) {
    if (ball.firstMove) {
      ball.vy += ball.g;
    }

    if (ball.vy > 0 && ball.vy - ball.friction > 0) {
      ball.vy -= ball.friction;
    } else if (ball.vy < 0 && ball.vy + ball.friction < 0) {
      ball.vy += ball.friction;
    } else {
      ball.vy = 0;
    }

    ball.y += ball.vy;

    if (ball.y >= _size.height - ball.r) {
      //反弹
      ball.y = _size.height - ball.r;
      ball.vy *= -1;
    }

    ball.firstMove = false;
  }

  _initBalls() {
    _balls = List.generate(
      100,
      (index) => Ball(
        x: math.Random().nextDouble() * _size.width,
        y: math.Random().nextDouble() * _size.height / 2.0,
        g: math.Random().nextDouble() * 0.2 + 0.1,
        r: math.Random().nextDouble() * 2 + 3,
        fillStyle: randomColor(),
      ),
    ).toList();
  }

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        _size = _globalKey.currentContext.size;
        if (_balls.length <= 0) {
          _initBalls();
        }
      }
      _balls.forEach((ball) {
        _move(ball);
        print('=== ${ball.y}');
      });
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: MyCustomPainter(balls: _balls),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Ball> balls;

  MyCustomPainter({this.balls});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
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
