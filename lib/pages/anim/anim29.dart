import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim29Page extends StatefulWidget {
  final String title;

  Anim29Page({this.title});

  @override
  _Anim29PageState createState() => _Anim29PageState();
}

class _Anim29PageState extends State<Anim29Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double dx = 0, dy = 0, easing = 0.05; //缓动系数
  bool isMouseDown = false;

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
        }

        if (!isMouseDown) {
          var vx = (_size.width / 2 - _ball.x) * easing;
          var vy = (_size.height / 2 - _ball.y) * easing;

          _ball.x += vx;
          _ball.y += vy;
        }
      }
    });
    super.initState();
  }

  bool _isPoint(Ball ball, Offset point) {
    return ball.r >=
        math.sqrt(
            math.pow(point.dx - ball.x, 2) + math.pow(point.dy - ball.y, 2));
  }

  void _pointerDownEvent(event) {
    Offset pointer = event.localPosition;
    isMouseDown = false;
    if (_isPoint(_ball, pointer)) {
      isMouseDown = true;
      dx = pointer.dx - _ball.x;
      dy = pointer.dy - _ball.y;
    }
  }

  void _pointerMoveEvent(event) {
    Offset pointer = event.localPosition;
    if (isMouseDown) {
      _ball.x = pointer.dx - dx;
      _ball.y = pointer.dy - dy;
    }
  }

  void _pointerUpEvent(event) {
    isMouseDown = false;
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
        child: Listener(
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
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDownEvent,
          onPointerMove: _pointerMoveEvent,
          onPointerUp: _pointerUpEvent,
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
