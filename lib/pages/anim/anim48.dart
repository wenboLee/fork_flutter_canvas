import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/line.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim48Page extends StatefulWidget {
  final String title;

  Anim48Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim48PageState createState() => _Anim48PageState();
}

class _Anim48PageState extends State<Anim48Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball>? _balls;
  List<Line> _lines = [];
  double spring = 0.0001;

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
          _balls = _initBalls(num: 50);
        }

        _move();
      }
    });
    super.initState();
  }

  void _move() {
    // 每次渲染清空之前连线
    _lines.clear();
    for (var i = 0; i < _balls!.length; i++) {
      Ball ball = _balls![i];
      ball.x += ball.vx;
      ball.y += ball.vy;

      for (var j = i + 1; j < _balls!.length; j++) {
        Ball target = _balls![j];
        _checkSpring(ball, target);
        checkBallHit(ball, target);
      }

      // 边界处理,从另一边出来
      if (ball.x - ball.r > _size.width) {
        ball.x = -ball.r;
      } else if (ball.x + ball.r < 0) {
        ball.x = _size.width + ball.r;
      }
      if (ball.y - ball.r > _size.height) {
        ball.y = -ball.r;
      } else if (ball.y + ball.r < 0) {
        ball.y = _size.height + ball.r;
      }
    }
  }

  void _checkSpring(Ball ball, Ball target) {
    double dx = target.x - ball.x;
    double dy = target.y - ball.y;
    double dist = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2));
    // 最小线长
    double minDist =
        _size.width > _size.height ? _size.width / 5 : _size.height / 5;
    if (dist < minDist) {
      _drawLine(ball, target, dist, minDist);

      var ax = dx * spring;
      var ay = dy * spring;
      ball.vx += ax / ball.m;
      ball.vy += ay / ball.m;
      target.vx -= ax / target.m;
      target.vy -= ay / target.m;
    }
  }

  void _drawLine(Ball ball, Ball target, double dist, double minDist) {
    num scale = math.max(0, (1 - dist / minDist));
    var color = Colors.green;
    var line = Line(
      lineWidth: 2 * scale.toDouble(),
      alpha: scale.toDouble(),
      fillStyle: Color.fromARGB(
          (scale * 255).toInt(), color.red, color.green, color.blue),
      p1: Offset(ball.x, ball.y),
      p2: Offset(target.x, target.y),
    );
    // 设置显示阈值
    if (line.alpha > 0.3 && line.lineWidth > 0.3) {
      _lines.add(line);
    }
  }

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) {
        var r = randomScope([3, 6]);
        return Ball(
          id: index,
          x: randomScope([0, _size.width]),
          y: randomScope([0, _size.height]),
          fillStyle: randomColor(),
          vx: randomScope([-2, 2]),
          vy: randomScope([-2, 2]),
          r: r,
          m: r,
        );
      },
    );
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: _balls == null
                  ? null
                  : MyCustomPainter(balls: _balls!, lines: _lines),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _balls = _initBalls(num: 50);
          _lines.clear();
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Ball> balls;
  final List<Line> lines;

  MyCustomPainter({required this.balls, required this.lines});

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

    lines.forEach((line) {
      _paint.color = line.fillStyle;
      _paint.strokeWidth = line.lineWidth;
      canvas.drawLine(line.p1, line.p2, _paint);
    });

    balls.forEach((ball) {
      _paint.color = ball.fillStyle;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
