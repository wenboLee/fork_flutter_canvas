import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim24Page extends StatefulWidget {
  final String title;

  Anim24Page({this.title});

  @override
  _Anim24PageState createState() => _Anim24PageState();
}

class _Anim24PageState extends State<Anim24Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double dx = 0,
      dy = 0,
      vx = randomScope([-10, 10]),
      vy = -10,
      g = 0.2,
      bounce = -0.7;
  Offset _pointer = Offset.zero;
  bool isMouseMove = false;

  void _bounceMove() {
    vy += g;
    _ball.x += vx;
    _ball.y += vy;

    if (_ball.x + _ball.r >= _size.width) {
      _ball.x = _size.width - _ball.r;
      vx *= bounce;
    } else if (_ball.x - _ball.r <= 0) {
      _ball.x = _ball.r;
      vx *= bounce;
    }

    if (_ball.y + _ball.r >= _size.height) {
      _ball.y = _size.height - _ball.r;
      vy *= bounce;
    } else if (_ball.y - _ball.r <= 0) {
      _ball.y = _ball.r;
      vy *= bounce;
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
        if (_ball == null) {
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
        }

        if (!isMouseMove) {
          _bounceMove();
        }
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    _pointer = event.localPosition;
    isMouseMove = false;
    if (isPoint(_ball, _pointer)) {
      isMouseMove = true;
      dx = _pointer.dx - _ball.x;
      dy = _pointer.dy - _ball.y;
    }
  }

  void _pointerMoveEvent(event) {
    if (isMouseMove) {
      _pointer = event.localPosition;
      _ball.x = _pointer.dx - dx;
      _ball.y = _pointer.dy - dy;
    }
  }

  void _pointerUpEvent(event) {
    _pointer = event.localPosition;
    isMouseMove = false;
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
      floatingActionButton: actionButton(() {
        setState(() {
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
          isMouseMove = false;
          vx = randomScope([-10, 10]);
          vy = -10;
        });
      }),
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
