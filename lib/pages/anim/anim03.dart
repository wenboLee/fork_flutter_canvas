import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';

class Anim03Page extends StatefulWidget {
  final String title;

  Anim03Page({this.title});

  @override
  _Anim03PageState createState() => _Anim03PageState();
}

class _Anim03PageState extends State<Anim03Page>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Ball _ball = Ball(x: 50, y: 50, r: 30);
  double vy = 0.5;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      _ball.y += vy;
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
    canvas.save();
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
