import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

import 'package:flutter_canvas/widget/utils.dart';

class Anim18Page extends StatefulWidget {
  final String title;

  Anim18Page({this.title});

  @override
  _Anim18PageState createState() => _Anim18PageState();
}

class _Anim18PageState extends State<Anim18Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey _scaffoldKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls;

  Color _randomColor() {
    var red = 55 + math.Random().nextInt(200);
    var greed = 55 + math.Random().nextInt(200);
    var blue = 55 + math.Random().nextInt(200);
    if (red > 100 && greed > 100 && blue > 100) {
      return _randomColor();
    } else {
      return Color.fromARGB(255, red, greed, blue);
    }
  }

  void _ballMove(Ball ball) {
    ball.x += ball.vx;
    ball.y += ball.vy;
    if (ball.x - ball.r >= _size.width ||
        ball.x + ball.r <= 0 ||
        ball.y - ball.r >= _size.height ||
        ball.y + ball.r <= 0) {
      _balls.remove(ball);
      String str;
      if (_balls.length > 0) {
        str = 'id:${ball.id} 小球被移除了!';
      } else {
        str = '所有的小球都被移除了!';
      }
      Toast.show(context, str);
    }
  }

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
        if (_balls == null) {
          _balls = List.generate(
            10,
            (index) => Ball(
              id: index,
              x: math.Random().nextDouble() * _size.width,
              y: math.Random().nextDouble() * _size.height,
              r: math.Random().nextDouble() * 10 + 20,
              fillStyle: _randomColor(),
              vx: (math.Random().nextDouble() - 0.5) * 3,
              vy: (math.Random().nextDouble() - 0.5) * 3,
            ),
          );
        }
        var i = _balls.length;
        while(i-- > 0) {
          _ballMove(_balls[i]);
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
      key: _scaffoldKey,
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
    ..strokeWidth = 1
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
