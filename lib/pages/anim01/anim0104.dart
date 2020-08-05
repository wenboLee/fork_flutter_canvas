import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim0104Page extends StatefulWidget {
  final String title;

  Anim0104Page({this.title});

  @override
  _Anim0104PageState createState() => _Anim0104PageState();
}

class _Anim0104PageState extends State<Anim0104Page>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Size size;
  Ball _ball = Ball(x: 0, y: 0, r: 30);
  double angle = 0, speed = 0.01, r = 150;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      _ball.x = size.width / 2.0 + r * math.cos(angle);
      _ball.y = size.height / 2.0 + r * math.sin(angle);
      angle += speed;
      angle %= math.pi * 2;
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
    // 外面传进去size和Canvas接受到的size不一样，iPhone X的height不等812/712
    // size = MediaQuery.of(context).size;
    var w = MediaQuery.of(context).size.width;
    size = Size(w, w);
    return Scaffold(
      appBar: appBar(widget.title),
      body: Container(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: CustomPaint(
                size: size,
                painter: MyCustomPainter(ball: _ball, r: r),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  final double r;

  MyCustomPainter({this.ball, this.r});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _paint.style = PaintingStyle.stroke;
    _paint.color = Colors.black;
    canvas.drawCircle(size.center(Offset.zero), r, _paint);

    canvas.drawLine(Offset(0, size.height / 2.0),
        Offset(size.width, size.height / 2.0), _paint);
    canvas.drawLine(Offset(size.width / 2.0, 0),
        Offset(size.width / 2.0, size.height), _paint);

    _paint.style = PaintingStyle.fill;
    _paint.color = Colors.blue;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);

    _paint.color = Colors.red;
    canvas.drawLine(Offset(ball.x, 0), Offset(ball.x, size.height), _paint);
    canvas.drawLine(Offset(0, ball.y), Offset(size.width, ball.y), _paint);
    canvas.drawLine(size.center(Offset.zero), Offset(ball.x, ball.y), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
