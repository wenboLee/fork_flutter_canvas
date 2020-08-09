import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'dart:math' as math;

class Anim15Page extends StatefulWidget {
  final String title;

  Anim15Page({this.title});

  @override
  _Anim15PageState createState() => _Anim15PageState();
}

class _Anim15PageState extends State<Anim15Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;

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
          _ball = Ball(
              x: _size.width / 2, y: 50, r: 30, friction: 0.05, g: 0.2, vy: 0);
        }

        if (_ball.vy > 0 && _ball.vy - _ball.friction > 0) {
          _ball.vy -= _ball.friction;
        } else if (_ball.vy < 0 && _ball.vy + _ball.friction < 0) {
          _ball.vy += _ball.friction;
        } else {
          _ball.vy = 0;
        }

        _ball.vy += _ball.g;
        _ball.y += _ball.vy;

        if (_ball.y + _ball.r >= _size.height) {
          _ball.y = _size.height - _ball.r;
          _ball.vy *= -0.98;
        }
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
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
