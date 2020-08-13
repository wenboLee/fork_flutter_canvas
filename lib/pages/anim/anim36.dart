import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim36Page extends StatefulWidget {
  final String title;

  Anim36Page({this.title});

  @override
  _Anim36PageState createState() => _Anim36PageState();
}

class _Anim36PageState extends State<Anim36Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball1, _ball2, _activeBall;
  double dx = 0, dy = 0;

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
        if (_ball1 == null) {
          _ball1 = Ball(x: 50, y: 50, r: 30);
        }
        if (_ball2 == null) {
          _ball2 = Ball(x: _size.width / 2, y: _size.height / 2, r: 60);
        }

        if (getDist(Offset(_ball1.x, _ball1.y), Offset(_ball2.x, _ball2.y)) <=
            _ball1.r + _ball2.r) {
          Toast.show(context, '小球发生碰撞');
        }
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    Offset point = event.localPosition;
    if (isPoint(_ball1, point)) {
      _activeBall = _ball1;
    }
    if (isPoint(_ball2, point)) {
      _activeBall = _ball2;
    }
    dx = point.dx - _activeBall.x;
    dy = point.dy - _activeBall.y;
  }

  void _pointerMoveEvent(event) {
    Offset point = event.localPosition;
    if (_activeBall != null) {
      _activeBall.x = point.dx - dx;
      _activeBall.y = point.dy - dy;
    }
  }

  void _pointerUpEvent(event) => _activeBall = null;

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
                painter: MyCustomPainter(ball1: _ball1, ball2: _ball2),
              );
            },
          ),
          onPointerDown: _pointerDownEvent,
          onPointerMove: _pointerMoveEvent,
          onPointerUp: _pointerUpEvent,
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball1, ball2;

  MyCustomPainter({this.ball1, this.ball2});

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

    _paint.color = Colors.green;
    canvas.drawCircle(Offset(ball1.x, ball1.y), ball1.r, _paint);

    _paint.color = Colors.red;
    canvas.drawCircle(Offset(ball2.x, ball2.y), ball2.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
