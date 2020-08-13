import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim37Page extends StatefulWidget {
  final String title;

  Anim37Page({this.title});

  @override
  _Anim37PageState createState() => _Anim37PageState();
}

class _Anim37PageState extends State<Anim37Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls;
  double bounce = -0.5, spring = 0.02, firstBallR = 50;
  bool _bigBall = false;

  List<Ball> _initBalls({int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: randomScope([0, _size.width]),
        y: randomScope([0, _size.height]),
        r: index == 0 ? firstBallR : randomScope([10, 20]),
        fillStyle: randomColor(),
        vx: randomScope([-3, 3]),
        vy: randomScope([-3, 3]),
      ),
    );
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
        if (_balls == null) {
          _balls = _initBalls(num: 100);
        }
        _checkHit();
        _moveBall();
        if (_bigBall) {
          if (firstBallR > _size.width / 2) {
            firstBallR = 50;
          } else {
            firstBallR += 2;
          }
          _balls.first.r = firstBallR;
        }
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    Offset point = event.localPosition;
    _bigBall = true;
    firstBallR = 50;
    _balls.first.r = firstBallR;
    _balls.first.x = point.dx;
    _balls.first.y = point.dy;
  }

  void _pointerMoveEvent(event) {
    Offset point = event.localPosition;
    _bigBall = true;
    _balls.first.x = point.dx;
    _balls.first.y = point.dy;
  }

  void _pointerUpEvent(event) {
    _bigBall = false;
    firstBallR = 50;
    _balls.first.r = firstBallR;
  }

  // 小球之间的碰撞
  void _checkHit() {
    for (var i = 0; i < _balls.length; i++) {
      Ball ball1 = _balls[i];
      // 第一个小球在非点击时候，不和其他小球产生碰撞
      if (i == 0 && !_bigBall) {
        continue;
      }
      // 比较过的不再比较，排除自己
      for (var j = i + 1; j < _balls.length; j++) {
        Ball ball2 = _balls[j];
        var dist = getDist(Offset(ball2.x, ball2.y), Offset(ball1.x, ball1.y));
        var minDist = ball1.r + ball2.r;
        if (dist < minDist) {
          double dx = ball2.x - ball1.x;
          double dy = ball2.y - ball1.y;
          // 计算理论碰撞ball2坐标
          double tx = ball1.x + dx / dist * minDist; // ball1.x + sin * minDist
          double ty = ball1.y + dy / dist * minDist; // ball1.y + cos * minDist
          // 计算理论坐标和实际坐标差值
          double ax = (tx - ball2.x) * spring;
          double ay = (ty - ball2.y) * spring;

          ball1.vx -= ax;
          ball1.vy -= ay;

          ball2.vx += ax;
          ball2.vy += ay;
        }
      }
    }
  }

  void _moveBall() {
    for (var i = 0; i < _balls.length; i++) {
      Ball ball = _balls[i];
      // 第一个小球, 不处理边界反弹问题
      if (i == 0) {
        continue;
      }
      // 边界处理
      checkBallBounce(ball, _size, bounce);
      ball.x += ball.vx;
      ball.y += ball.vy;
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
                painter: MyCustomPainter(balls: _balls),
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
  final List<Ball> balls;

  MyCustomPainter({this.balls});

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

    for (var i = 0; i < balls.length; i++) {
      // 第一个不绘制
      if (i > 0) {
        Ball ball = balls[i];
        _paint.color = ball.fillStyle;
        canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
