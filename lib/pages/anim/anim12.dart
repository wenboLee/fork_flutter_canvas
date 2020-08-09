import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim12Page extends StatefulWidget {
  final String title;

  Anim12Page({this.title});

  @override
  _Anim12PageState createState() => _Anim12PageState();
}

class _Anim12PageState extends State<Anim12Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Arrow _arrow;
  Offset _pointer = Offset.zero;
  double dx = 0, dy = 0;

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
          _arrow =
              Arrow(x: _size.width / 2, y: _size.height / 2, w: 100, h: 60);
        }
        dx = _pointer.dx - _arrow.x;
        dy = _pointer.dy - _arrow.y;
        _arrow.rotation = math.atan2(dy, dx);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pointerDistance(event) => _pointer = event.localPosition;

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
                painter: MyCustomPainter(arrow: _arrow),
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

  MyCustomPainter({this.arrow});

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
    var center = Offset(arrow.x, arrow.y);
    // 画布左上角离画布中心点距离， 即为旋转半径
    var r =
        math.sqrt(math.pow(size.width / 2, 2) + math.pow(size.height / 2, 2));
    // 计算画布中心点初始弧度
    double startAngle = math.atan2(center.dy,  center.dx);
    // 计算旋转后的画布中心点
    final newX = r * math.cos(arrow.rotation + startAngle);
    final newY = r * math.sin(arrow.rotation + startAngle);
    // 平移画布， 画布正方形才能居中旋转
    canvas.translate(center.dx - newX, center.dy - newY);
    canvas.rotate(arrow.rotation);

    var path = _createPath(canvas, arrow.w, arrow.h, center);
    _paint.color = Colors.blue;
    canvas.drawPath(path, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
