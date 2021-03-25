import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim41Page extends StatefulWidget {
  final String title;

  Anim41Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim41PageState createState() => _Anim41PageState();
}

class _Anim41PageState extends State<Anim41Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball;
  double vr = 0.02; //角速度

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
        if (_ball == null) {
          _ball = Ball(
            x: randomScope([100, _size.width - 100]),
            y: randomScope([100, _size.width - 100]),
            r: 30,
          );
        }

        Offset center = Offset(_size.width / 2, _size.height / 2);

        var rx = _ball!.x - center.dx;
        var ry = _ball!.y - center.dy;

//      推导公式：
//      设置中心点0，0
//      当前坐标 x=r*cos(angle) y=r*sin(angle)
//      下一帧 x1=r*cos(angle + vr) y1=r*sin(angle)
//      cos(a+b)=cos(a)*cos(b)-sin(a)*sin(b)
//      sin(a+b)=sin(a)*cos(b)+cos(a)*sin(b)
//
//      x1=r*cos(angle)*cos(vr)-r*sin(angle)*sin(vr)
//      y1=r*sin(angle)*cos(vr)+r*cos(angle)*sin(vr)
//
//      x1 = x*cos(vr) - y*sin(vr)
//      y1 = y*cos(vr) + x*sin(vr)
        var x = rx * math.cos(vr) + ry * math.sin(vr);
        var y = ry * math.cos(vr) - rx * math.sin(vr);

        _ball!.x = center.dx + x;
        _ball!.y = center.dy + y;
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
              painter: _ball == null ? null : MyCustomPainter(ball: _ball!),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ball = Ball(
            x: randomScope([100, _size.width - 100]),
            y: randomScope([100, _size.width - 100]),
            r: 30,
          );
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;

  MyCustomPainter({required this.ball});

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

    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
