import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim50Page extends StatefulWidget {
  final String title;

  Anim50Page({this.title});

  @override
  _Anim50PageState createState() => _Anim50PageState();
}

class _Anim50PageState extends State<Anim50Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls;
  double g = 0.2, bounce = -0.8, floor = 300, f1 = 250, hx = 0, hy = 0, r = 10;

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

//        var showBalls = _balls.where((ball) => ball.show == true);
//        if (showBalls == null || showBalls.length <= 0) {
//          // 全部离开屏幕了，重置
//          _balls = _initBalls(num: 100);
//        }
        _move();
        _balls.sort((a, b) => a.z3d.compareTo(b.z3d));
      }
    });
    super.initState();
  }

  void _move() {
    for (var i = 0; i < _balls.length; i++) {
      Ball ball = _balls[i];
      ball.vy += g;
      ball.x3d += ball.vx;
      ball.y3d += ball.vy;
      ball.z3d += ball.vz;

      if (ball.y3d > floor) {
        ball.y3d = floor;
        ball.vy *= bounce;
      }

      if (f1 + ball.z3d > 0) {
        ball.show = true;
        var scale = f1 / (f1 + ball.z3d);
        ball.scaleX = scale;
        ball.scaleY = scale;
        // 相对canvas左上点缩放，进行校正在中点缩放
        ball.x = hx + ball.x3d * scale;
        ball.y = hy + ball.y3d * scale;
        ball.r = r * scale;
      } else {
        ball.show = false;
      }
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
        y3d: -200,
        gradientColor: gradientColor,
        vx: randomScope([-6, 6]),
        vy: randomScope([-3, -6]),
        vz: randomScope([-2, 2]),
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
      ),
      floatingActionButton: actionButton(() {
        setState(() {
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
      if (ball.show) {
        _paint.color = ball.fillStyle;
        _paint.shader = ball.gradientColor.createShader(
          Rect.fromCircle(center: Offset(ball.x, ball.y), radius: ball.r),
        );
        canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
      }
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
