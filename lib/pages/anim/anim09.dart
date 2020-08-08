import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim09Page extends StatefulWidget {
  final String title;

  Anim09Page({this.title});

  @override
  _Anim09PageState createState() => _Anim09PageState();
}

class _Anim09PageState extends State<Anim09Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Arrow _arrow;
  double speed = 3, dx = 0, dy = 0, angle = 0, vx = 0, vy = 0;
  Offset _pointer = Offset.zero;

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
        if (_arrow == null) {
          _arrow = Arrow(x: _size.width / 2, y: _size.height / 2, w: 60, h: 30);
        }
        if (_pointer != Offset.zero) {
          dx = _pointer.dx - _arrow.x;
          dy = _pointer.dy - _arrow.y;
          angle = math.atan2(dy, dx);

          vx = speed * math.cos(angle);
          vy = speed * math.sin(angle);

          _arrow.x += vx;
          _arrow.y += vy;
        }
      }
    });
    super.initState();
  }

  void _pointerDistance(event) => _pointer = event.localPosition;

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
        child: Listener(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                key: _globalKey,
                size: Size.infinite,
                painter: MyCustomPainter(arrow: _arrow, angle: angle),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          // ignore: deprecated_member_use
          onPointerHover: _pointerDistance,
          onPointerDown: _pointerDistance,
          onPointerMove: _pointerDistance,
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Arrow arrow;
  final double angle;

  MyCustomPainter({this.arrow, this.angle});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  Path _createPath(Canvas canvas, double w, double h, Offset center) {
    //左上第一个点
    double firstX = center.dx - w / 2, firstY = center.dy - h / 2;
    Path path = Path();
    // 左边高 h/2 , 右边宽w/2
    path.moveTo(firstX, firstY);
    path.addPolygon([
      Offset(firstX, firstY + h / 4),
      Offset(firstX + w / 2, firstY + h / 4),
      Offset(firstX + w / 2, firstY),
      Offset(firstX + w, firstY + h / 2),
      Offset(firstX + w / 2, firstY + h),
      Offset(firstX + w / 2, firstY + h * 3 / 4),
      Offset(firstX, firstY + h * 3 / 4),
    ], true);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // 箭头坐标作为参照点
    var path = _createPath(canvas, arrow.w, arrow.h, Offset(arrow.x, arrow.y));
    _paint.color = Colors.blue;
    canvas.drawPath(path, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
