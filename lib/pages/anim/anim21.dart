import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim21Page extends StatefulWidget {
  final String title;

  Anim21Page({this.title});

  @override
  _Anim21PageState createState() => _Anim21PageState();
}

class _Anim21PageState extends State<Anim21Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Ball> _balls;

  List<Ball> _initBalls({int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: _size.width / 2,
        y: _size.height / 2,
        r: randomScope([30, 50]),
        fillStyle: randomColor(),
        vx: randomScope([-5, 5]),
        vy: randomScope([-6, 7]),
      ),
    );
  }

  _updateBall(Ball ball) {
    ball.x += ball.vx;
    ball.y += ball.vy;
    // 边界处理
    if (ball.x - ball.r <= 0) {
      // 左
      ball.x = ball.r;
      ball.vx *= -1;
    }
    if (ball.x + ball.r >= _size.width) {
      //右
      ball.x = _size.width - ball.r;
      ball.vx *= -1;
    }
    if (ball.y - ball.r <= 0) {
      //上
      ball.y = ball.r;
      ball.vy *= -1;
    }
    if (ball.y + ball.r >= _size.height) {
      //下
      ball.y = _size.height - ball.r;
      ball.vy *= -1;
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
        if (_balls == null) {
          _balls = _initBalls(num: 10);
        }
        _balls.forEach(_updateBall);
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
              painter: MyCustomPainter(balls: _balls),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _balls = _initBalls(num: 10);
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
