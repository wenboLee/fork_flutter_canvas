import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim27Page extends StatefulWidget {
  final String title;

  Anim27Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim27PageState createState() => _Anim27PageState();
}

class _Anim27PageState extends State<Anim27Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball1, _ball2, _activeBall; // 被拖拽对象

  // 弹动系数, 弹簧长度, 摩擦力
  double spring = 0.03, springLength = 200, friction = 0.9;

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
        if (_ball1 == null) {
          _ball1 = Ball(
            x: randomScope([50, _size.width - 50]),
            y: randomScope([50, _size.height - 50]),
            r: 20,
          );
        }
        if (_ball2 == null) {
          _ball2 = Ball(
            x: randomScope([50, _size.width - 50]),
            y: randomScope([50, _size.height - 50]),
            r: 20,
          );
        }
        // 取反为了初次没有选择的时候弹动
        if (_activeBall == null) {
          // ball1向ball2弹动
          _springTo(_ball1!, _ball2!);
          // ball2向ball1弹动
          _springTo(_ball2!, _ball1!);
        } else {
          if (_activeBall == _ball1) {
            // ball2向ball1弹动
            _springTo(_ball2!, _ball1!);
          } else {
            // ball1向ball2弹动
            _springTo(_ball1!, _ball2!);
          }
        }
      }
    });
    super.initState();
  }

  // ball1向ball2弹动
  void _springTo(Ball ball1, Ball ball2) {
    var dx = ball2.x - ball1.x;
    var dy = ball2.y - ball1.y;
    var angle = math.atan2(dy, dx);
    // 计算被拉伸或压缩和springLength 坐标差值
    var targetX = ball2.x - springLength * math.cos(angle);
    var targetY = ball2.y - springLength * math.sin(angle);

    // 拉伸越远， 速度越大
    // 当vx、vy在临界值加超过进入小于弹簧长度就会形成负值，形成来回弹动，直到摩擦力衰减完速度
    ball1.vx += (targetX - ball1.x) * spring;
    ball1.vy += (targetY - ball1.y) * spring;

    if (ball1.vx.abs() < 0.001 && ball1.vy.abs() < 0.001) {
      ball1.vx = 0;
      ball1.vy = 0;
    } else {
      ball1.vx *= friction;
      ball1.vy *= friction;
    }

    ball1.x += ball1.vx;
    ball1.y += ball1.vy;
  }

  void _pointerDownEvent(event) {
    var pointer = event.localPosition;
    if (isPoint(_ball1!, pointer)) {
      _activeBall = _ball1;
    }
    if (isPoint(_ball2!, pointer)) {
      _activeBall = _ball2;
    }
  }

  void _pointerMoveEvent(event) {
    var pointer = event.localPosition;
    if (_activeBall != null) {
      _activeBall!.x = pointer.dx;
      _activeBall!.y = pointer.dy;
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
                painter: _ball1 == null || _ball2 == null
                    ? null
                    : MyCustomPainter(ball1: _ball1!, ball2: _ball2!),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDownEvent,
          onPointerMove: _pointerMoveEvent,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ball1 = Ball(
            x: randomScope([50, _size.width - 50]),
            y: randomScope([50, _size.height - 50]),
            r: 20,
          );
          _ball2 = Ball(
            x: randomScope([50, _size.width - 50]),
            y: randomScope([50, _size.height - 50]),
            r: 20,
          );
          _activeBall = null;
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball1, ball2;

  MyCustomPainter({required this.ball1, required this.ball2});

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
    _paint.color = Colors.red;
    _paint.strokeWidth = 4;
    canvas.drawLine(Offset(ball1.x, ball1.y), Offset(ball2.x, ball2.y), _paint);

    _paint.color = ball1.fillStyle;
    canvas.drawCircle(Offset(ball1.x, ball1.y), ball1.r, _paint);
    _paint.color = ball2.fillStyle;
    canvas.drawCircle(Offset(ball2.x, ball2.y), ball2.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
