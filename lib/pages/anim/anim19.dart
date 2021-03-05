import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim19Page extends StatefulWidget {
  final String title;

  Anim19Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim19PageState createState() => _Anim19PageState();
}

class _Anim19PageState extends State<Anim19Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball>? _balls;
  double g = 0.05;

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: _size.width / 2,
        y: _size.height,
        r: math.Random().nextDouble() > 0.9
            ? randomScope([25, 40])
            : randomScope([15, 30]),
        fillStyle: randomColor(),
        vx: randomScope([-3, 3]),
        vy: randomScope([0, -10]),
      ),
    );
  }

  _updateBall(ball) {
    ball.x += ball.vx;
    ball.y += ball.vy;
    ball.vy += g;
    if (ball.x - ball.r >= _size.width ||
        ball.x + ball.r <= 0 ||
        ball.y - ball.r >= _size.height ||
        ball.y + ball.r <= 0) {
      // 出去后归位
      ball.x = _size.width / 2;
      ball.y = _size.height;
      ball.vx = randomScope([-3, 3]);
      ball.vy = randomScope([0, -10]);
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
          _size = _globalKey.currentContext!.size!;
        }
        if (_balls == null) {
          _balls = _initBalls(num: 100);
        }
        _balls!.forEach(_updateBall);
      }
    });
    super.initState();
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
              painter: _balls == null ? null : MyCustomPainter(balls: _balls!),
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
