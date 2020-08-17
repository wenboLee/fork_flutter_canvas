import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim51Page extends StatefulWidget {
  final String title;

  Anim51Page({this.title});

  @override
  _Anim51PageState createState() => _Anim51PageState();
}

class _Anim51PageState extends State<Anim51Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls;
  double maxZ = 1200, f = 0.8, f1 = 250, hx = 0, hy = 0, r = 10;
  bool out = false;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext.size;
          hx = _size.width / 2;
          hy = _size.height / 2;
        }
        if (_balls == null) {
          _balls = _initBalls(num: 100);
        }

        _move();
        _balls.sort((a, b) => a.z3d.compareTo(b.z3d));
      }
    });
    super.initState();
  }

  void _move() {
    for (var i = 0; i < _balls.length; i++) {
      Ball ball = _balls[i];
      ball.vz += ball.az;
      ball.vz *= f;
      ball.z3d += ball.vz;

      if (ball.z3d + f1 < 0 && out) {
        // 进
        ball.z3d = maxZ;
      } else if (ball.z3d + f1 > maxZ && !out) {
        // 出
        ball.z3d -= maxZ;
      }

      var scale = f1 / (f1 + ball.z3d);
      ball.scaleX = scale;
      ball.scaleY = scale;
      // 相对canvas左上点缩放，进行校正在中点缩放
      ball.x = hx + ball.x3d * scale;
      ball.y = hy + ball.y3d * scale;
      ball.r = r * scale;
      ball.alpha = math.min(scale.abs() * 1.5, 1) * 255.toDouble();
    }
  }

  List<Ball> _initBalls({int num}) {
    RadialGradient gradientColor = RadialGradient(
      colors: [
        Colors.white,
        Colors.blue[200],
        Colors.blue[500],
        Colors.blue[800].withOpacity(0.8),
        Colors.black.withOpacity(0.2),
      ],
      stops: [
        0,
        0.3,
        0.5,
        0.8,
        1,
      ],
      radius: 1,
    );
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        r: r,
        gradientColor: gradientColor,
        x3d: randomScope([-1.5 * _size.width, 2 * _size.width]),
        y3d: randomScope([-1.5 * _size.height, 2 * _size.height]),
        z3d: randomScope([0, maxZ]),
        vz: randomScope(out ? [-5, -0.5] : [0.5, 5]),
        az: randomScope(out ? [-2, -0.5] : [0.5, 2]),
      ),
    );
  }

  GestureDetector _buildGestureDetector(
      {Function(DragDownDetails) onPanDown,
      Function(DragEndDetails) onPanEnd,
      Widget child,
      EdgeInsetsGeometry margin = EdgeInsets.zero}) {
    return GestureDetector(
      onPanDown: onPanDown,
      onPanEnd: onPanEnd,
      child: Container(
        width: 50,
        height: 50,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.green[200],
        ),
        child: Center(
          child: child,
        ),
      ),
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
        color: Colors.black87,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  key: _globalKey,
                  size: Size.infinite,
                  painter: MyCustomPainter(balls: _balls),
                );
              },
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildGestureDetector(
                margin: EdgeInsets.only(left: 20),
                onPanDown: (e) {
                  setState(() {
                    out = !out;
                    _balls = _initBalls(num: 100);
                  });
                },
                child: Text(
                  out ? '前' : '后',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          out = false;
          _balls = _initBalls(num: 100);
        });
      }),
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

    balls.forEach((ball) {
      _paint.color = ball.fillStyle.withAlpha(ball.alpha.toInt());
      _paint.shader = ball.gradientColor.createShader(
        Rect.fromCircle(center: Offset(ball.x, ball.y), radius: ball.r),
      );
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
