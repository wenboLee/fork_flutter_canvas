import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';

class Anim02Page extends StatefulWidget {
  final String title;

  Anim02Page({this.title});

  @override
  _Anim02PageState createState() => _Anim02PageState();
}

class _Anim02PageState extends State<Anim02Page>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Ball _ball = Ball(x: 50, y: 50, r: 30);
  double vy = 0, ay = 0.1;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      _ball.y += vy;
      vy += ay;
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: MyCustomPainter(ball: _ball),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;

  MyCustomPainter({this.ball});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.restore();
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.save();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
