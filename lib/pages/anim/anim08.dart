import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim08Page extends StatefulWidget {
  final String title;

  Anim08Page({this.title});

  @override
  _Anim08PageState createState() => _Anim08PageState();
}

class _Anim08PageState extends State<Anim08Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Arrow _arrow;
  double vr = 2 * math.pi / 180; //角速度

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        _size = _globalKey.currentContext.size;
        if (_arrow == null) {
          _arrow = Arrow(x: _size.width / 2, y: _size.height / 2, w: 140, h: 60);
        }
        _arrow.rotation += vr;
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
              painter: MyCustomPainter(arrow: _arrow),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Arrow arrow;

  MyCustomPainter({this.arrow});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  _createPath(Canvas canvas, double w, double h) {
    Path path = Path();
    path.moveTo(-w/2, -h/2);
    path.lineTo(w/10, -h/2);
    path.lineTo(w/10, -h);
    path.lineTo(w/2, 0);
    path.lineTo(w/10, h);
    path.lineTo(w/10, h/2);
    path.lineTo(-w/2, h/2);
    path.close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
