import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'dart:math' as math;

class Anim10Page extends StatefulWidget {
  final String title;

  Anim10Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim10PageState createState() => _Anim10PageState();
}

class _Anim10PageState extends State<Anim10Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball;
  double angle = 0, vx = 0.5, swing = 60; //增幅
  bool directionRight = true; //方向右
  List<Offset> _pointerList = [];

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        _size = _globalKey.currentContext!.size!;
        if (_ball == null) {
          // 原点开始
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
        }
        if (_ball!.x >= _size.width - _ball!.r) {
          directionRight = false;
        } else if (_ball!.x - _ball!.r <= 0) {
          directionRight = true;
        }

        if (directionRight) {
          _ball!.x += vx;
        } else {
          _ball!.x -= vx;
        }

        _ball!.y = _size.height / 2 + math.sin(angle) * swing;
        angle += 0.05;
        angle %= math.pi * 2;
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: _ball == null
                  ? null
                  : MyCustomPainter(ball: _ball!, pointerList: _pointerList),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
          angle = 0;
          directionRight = true;
          _pointerList.clear();
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;
  List<Offset> pointerList;

  MyCustomPainter({required this.ball, required this.pointerList});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas);
    _paint.style = PaintingStyle.stroke;
    _paint.color = Colors.black;
    pointerList.add(Offset(ball.x, ball.y));
    if (pointerList.length >= 1000) {
      pointerList.removeAt(0);
    }
    // 绘制运动三角函数曲线
    Path path = Path();
    path.addPolygon(pointerList, false);
    canvas.drawPath(path, _paint);

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
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
