import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim22Page extends StatefulWidget {
  final String title;

  Anim22Page({this.title});

  @override
  _Anim22PageState createState() => _Anim22PageState();
}

class _Anim22PageState extends State<Anim22Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double angle = toRad(60), speed = randomScope([30, 50]), friction = 2.5;

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
          _ball = Ball(x: 50, y: 50, r: 30, firstMove: true);
        }

        if (speed > friction) {
          speed -= friction;
        } else {
          speed = 0;
        }
        var vx = math.cos(angle) * speed;
        var vy = math.sin(angle) * speed;

        _ball.x += vx;
        _ball.y += vy;

        if (speed == 0 && _ball.firstMove) {
          _ball.firstMove = false;
          Future.delayed(Duration(milliseconds: 500)).whenComplete(() {
            //复原
            _ball.x = 50;
            _ball.y = 50;
            speed = randomScope([30, 50]);
            _ball.firstMove = true;
          });
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
    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
