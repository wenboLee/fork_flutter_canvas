import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/line.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim49Page extends StatefulWidget {
  final String title;

  Anim49Page({this.title});

  @override
  _Anim49PageState createState() => _Anim49PageState();
}

class _Anim49PageState extends State<Anim49Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double z = 0, f1 = 200, hx=0, hy=0;

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
          _ball = Ball(r: 80);
        }

        var hx = _size.width/2;
        var hy = _size.height/2;

        var scale = f1 / (f1 + z);
        _ball.scaleX = scale;
        _ball.scaleY = scale;
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    var pointer = event.localPosition;
//    dx = pointer.dx - hx;
//    dy = pointer.dy - hy;
  }

  void _pointerMoveEvent(event) {
    var pointer = event.localPosition;
    _ball.x = pointer.dx - hx;
    _ball.y = pointer.dy - hy;
  }

  void _pointerUpEvent(event) {

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
    drawAuthorText(canvas, size);

    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
