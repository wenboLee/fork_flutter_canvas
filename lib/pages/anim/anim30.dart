import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim30Page extends StatefulWidget {
  final String title;

  Anim30Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim30PageState createState() => _Anim30PageState();
}

class _Anim30PageState extends State<Anim30Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball>? _balls;
  double dx = 0,
      dy = 0,
      springLength = 200,
      friction = 0.9,
      spring = 0.03; //弹动系数
  Ball? draggedBall;

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: randomScope([50, _size.width - 50]),
        y: randomScope([50, _size.height - 50]),
        r: 30,
      ),
    );
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
        if (_balls == null) {
          _balls = _initBalls(num: 8);
        }

        _balls!.forEach((ball) {
          if (!ball.dragged) {
            var tmpBalls = _balls!.where((element) => element.id != ball.id);
            tmpBalls.forEach((element) {
              // ball 向其它所有弹动
              _springTo(ball, element);
            });
          }
        });
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    Offset pointer = event.localPosition;
    _balls!.forEach((ball) {
      if (isPoint(ball, pointer)) {
        ball.dragged = true;
        dx = pointer.dx - ball.x;
        dy = pointer.dy - ball.y;
        draggedBall = ball;
      }
    });
  }

  void _pointerMoveEvent(event) {
    Offset pointer = event.localPosition;
    if (draggedBall != null) {
      draggedBall!.x = pointer.dx - dx;
      draggedBall!.y = pointer.dy - dy;
    }
  }

  void _pointerUpEvent(event) {
    draggedBall?.dragged = false;
    draggedBall = null;
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
                painter:
                    _balls == null ? null : MyCustomPainter(balls: _balls!),
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
          _balls = _initBalls(num: 8);
          draggedBall = null;
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
    drawAuthorText(canvas, size);
    Path path = Path();
    if (balls.length > 0) {
      path.moveTo(balls[0].x, balls[0].y);
      path.addPolygon(balls.map((e) => Offset(e.x, e.y)).toList(), false);
      path.close();
    }
    _paint.color = Colors.red;
    _paint.strokeWidth = 4;
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, _paint);

    balls.forEach((ball) {
      _paint.color = ball.fillStyle;
      _paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
