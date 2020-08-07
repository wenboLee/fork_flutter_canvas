import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim09Page extends StatefulWidget {
  final String title;

  Anim09Page({this.title});

  @override
  _Anim09PageState createState() => _Anim09PageState();
}

class _Anim09PageState extends State<Anim09Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double speed = 3, dx = 0, dy = 0, angle = 0, vx = 0, vy = 0;
  Offset _pointer = Offset.zero;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        _size = _globalKey.currentContext.size;
        if (_ball == null) {
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
        }
        if (_pointer != Offset.zero) {
          dx = _pointer.dx - _ball.x;
          dy = _pointer.dy - _ball.y;
          angle = math.atan2(dy, dx);

          vx = speed * math.cos(angle);
          vy = speed * math.sin(angle);

          _ball.x += vx;
          _ball.y += vy;
        }
      }
    });
    super.initState();
  }

  void _pointerDistance(event) => _pointer = event.localPosition;

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
                painter: MyCustomPainter(ball: _ball, angle: angle),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          // ignore: deprecated_member_use
          onPointerHover: _pointerDistance,
          onPointerDown: _pointerDistance,
          onPointerMove: _pointerDistance,
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  final double angle;

  MyCustomPainter({this.ball, this.angle});

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
//    _paint.color = Colors.red;
//    canvas.drawArc(
//        Rect.fromCenter(
//            center: Offset(ball.x, ball.y),
//            height: ball.r * 3,
//            width: ball.r * 3),
//        0,
//        angle,
//        true,
//        _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
