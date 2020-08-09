import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'dart:math' as math;

class Anim11Page extends StatefulWidget {
  final String title;

  Anim11Page({this.title});

  @override
  _Anim11PageState createState() => _Anim11PageState();
}

class _Anim11PageState extends State<Anim11Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double angle = 0, initScale = 1, swing = 0.5;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        _size = _globalKey.currentContext.size;
        if (_ball == null) {
          // 原点开始
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
        }
        var scale = initScale + math.sin(angle) * swing;
        _ball.scaleX = scale;
        _ball.scaleY = scale;
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
    canvas.translate(-ball.x * ball.scaleX + size.width / 2,
        -ball.y * ball.scaleY + size.height / 2);
    canvas.scale(ball.scaleX, ball.scaleY);
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
