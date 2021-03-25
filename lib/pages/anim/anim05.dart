import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim05Page extends StatefulWidget {
  final String title;

  Anim05Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim05PageState createState() => _Anim05PageState();
}

class _Anim05PageState extends State<Anim05Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls = [];

  _initBalls() {
    _balls = List.generate(
      100,
      (index) => Ball(
        id: index,
        x: math.Random().nextDouble() * _size.width,
        y: math.Random().nextDouble() * _size.height / 4.0,
        g: math.Random().nextDouble() * 0.2 + 0.1,
        r: math.Random().nextDouble() * 4 + 3,
        fillStyle: randomColor(),
        friction: 0.05,
        firstMove: true,
      ),
    ).toList();
  }

  _move(Ball ball, double height) {
    if (!ball.firstMove) {
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

    if (ball.y >= height - ball.r) {
      //反弹
      ball.y = height - ball.r;
      ball.vy *= -1;
    }

    ball.firstMove = false;
  }

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
        if (_balls.length <= 0) {
          _initBalls();
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
            _balls.forEach((ball) {
              _move(ball, _size.height);
            });
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: MyCustomPainter(balls: _balls),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _initBalls();
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
    drawAuthorText(canvas);
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
