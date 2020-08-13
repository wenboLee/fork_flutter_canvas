import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/box.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim35Page extends StatefulWidget {
  final String title;

  Anim35Page({this.title});

  @override
  _Anim35PageState createState() => _Anim35PageState();
}

class _Anim35PageState extends State<Anim35Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  Box _box;
  bool _moving = false;
  double g = 0.2, friction = 0.98, easing = 0.03, lastX = 0, lastY = 0;
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
          _ball = Ball(x: 50, y: _size.height - 30, r: 30);
        }
        if (_box == null) {
          _box = Box(x: _size.width - 100, y: _size.height - 50, w: 100, h: 50);
        }
        if (_moving) {
          _ballMove(context);
        }
      }
    });
    super.initState();
  }

  bool _checkHit(BuildContext context) {
    // 运动圆两点直线一次方程与水平物体平面交点
    var k1 = (_ball.y - lastY) / (_ball.x - lastX);
    var b1 = lastY - k1 * lastX;
    var k2 = 0;
    var b2 = _ball.y;
    // y 相等:  k1*x + b1 = k2*x + b2
    // 求交点坐标
    var cx = (b2 - b1) / (k1 - k2);
//    var cy = k1 * cx + b1;
    if (cx - _ball.r / 2 > _box.x &&
        cx + _ball.r / 2 < _box.x + _box.w &&
        _ball.y - _ball.r > _box.y) {
      Toast.show(context, '小球和盒子发生碰撞');
      return true;
    }
    return false;
  }

  void _ballMove(BuildContext context) {
    _ball.vx *= friction;
    _ball.vy *= friction;
    _ball.vy += g;

    _ball.x += _ball.vx;
    _ball.y += _ball.vy;

    // 边界处理+碰撞检测
    if (_checkHit(context) ||
        _ball.x - _ball.r > _size.width ||
        _ball.x + _ball.r < 0 ||
        _ball.y - _ball.r > _size.height ||
        _ball.y + _ball.r < 0) {
      _moving = false;
      // 复位
      _ball.x = 50;
      _ball.y = _size.height - 30;
    }
    lastX = _ball.x;
    lastY = _ball.y;
  }

  void _pointerDownEvent(event) {
    if (!_moving) {
      _pointer = event.localPosition;
    }
  }

  void _pointerMoveEvent(event) {
    if (!_moving) {
      _pointer = event.localPosition;
    }
  }

  void _pointerUpEvent(event) {
    if (!_moving) {
      _pointer = event.localPosition;
      _moving = true;
      _ball.vx = (_pointer.dx - _ball.x) * easing;
      _ball.vy = (_pointer.dy - _ball.y) * easing;
      lastX = _ball.x;
      lastY = _ball.y;
      _pointer = Offset.zero;
    }
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
                painter: MyCustomPainter(
                    ball: _ball, box: _box, moving: _moving, pointer: _pointer),
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
  final Ball ball;
  final Box box;
  final bool moving;
  final Offset pointer;

  MyCustomPainter({this.ball, this.box, this.moving, this.pointer});

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
    if (!moving && pointer != Offset.zero) {
      _paint.color = Colors.red;
      _paint.strokeWidth = 2;
      canvas.drawLine(Offset(ball.x, ball.y), pointer, _paint);
    }

    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);

    _paint.color = Colors.green;
    canvas.drawRect(Rect.fromLTWH(box.x, box.y, box.w, box.h), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
