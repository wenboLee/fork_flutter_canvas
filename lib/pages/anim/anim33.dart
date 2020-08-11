import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim33Page extends StatefulWidget {
  final String title;

  Anim33Page({this.title});

  @override
  _Anim33PageState createState() => _Anim33PageState();
}

class _Anim33PageState extends State<Anim33Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double friction = 0.95, g = 3, spring = 0.03; //弹动系数
  Offset _pointer = Offset.zero;

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
        var dx = _pointer.dx - _ball.x;
        var dy = _pointer.dy - _ball.y;

        var ax = dx * spring;
        var ay = dy * spring;

        _ball.vx += ax;
        _ball.vy += ay;
        _ball.vy += g;

        _ball.vx *= friction;
        _ball.vy *= friction;

        _ball.x += _ball.vx;
        _ball.y += _ball.vy;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pointerEvent(event) => _pointer = event.localPosition;

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
                painter: MyCustomPainter(ball: _ball, pointer: _pointer),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          // ignore: deprecated_member_use
          onPointerHover: _pointerEvent,
          onPointerDown: _pointerEvent,
          onPointerMove: _pointerEvent,
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  final Offset pointer;

  MyCustomPainter({this.ball, this.pointer});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _paint.color = Colors.red;
    _paint.strokeWidth = 4;
    canvas.drawLine(pointer, Offset(ball.x, ball.y), _paint);

    _paint.color = ball.fillStyle;
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
