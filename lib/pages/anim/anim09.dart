import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim09Page extends StatefulWidget {
  final String title;

  Anim09Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim09PageState createState() => _Anim09PageState();
}

class _Anim09PageState extends State<Anim09Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Arrow? _arrow;
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
          _size = _globalKey.currentContext!.size!;
        }
        if (_arrow == null) {
          _arrow =
              Arrow(x: _size.width / 2, y: _size.height / 2, w: 100, h: 60);
        }
        if (_pointer != Offset.zero) {
          dx = _pointer.dx - _arrow!.x;
          dy = _pointer.dy - _arrow!.y;

          var dr = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2));
          if (dr < speed) {
            return;
          }

          angle = math.atan2(dy, dx);

          vx = speed * math.cos(angle);
          vy = speed * math.sin(angle);

          _arrow!.x += vx;
          _arrow!.y += vy;
          _arrow!.rotation = angle;
        }
      }
    });
    super.initState();
  }

  void _pointerEvent(event) => _pointer = event.localPosition;

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
                painter: MyCustomPainter(arrow: _arrow!),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          // ignore: deprecated_member_use
          onPointerHover: _pointerEvent,
          onPointerDown: _pointerEvent,
          onPointerMove: _pointerEvent,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _arrow =
              Arrow(x: _size.width / 2, y: _size.height / 2, w: 100, h: 60);
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Arrow arrow;

  MyCustomPainter({required this.arrow});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  Path _createPath(double w, double h, Offset center, double rotation) {
    //正方形左上第一个点,虚点
    double firstX = center.dx - w / 2, firstY = center.dy - h / 2;
    Path path = Path();
    // 左边高 h/2 , 右边宽w/2
    path.moveTo(firstX, firstY);
    List<Offset> list = [
      Offset(firstX, firstY + h / 4),
      Offset(firstX + w / 2, firstY + h / 4),
      Offset(firstX + w / 2, firstY),
      Offset(firstX + w, firstY + h / 2),
      Offset(firstX + w / 2, firstY + h),
      Offset(firstX + w / 2, firstY + h * 3 / 4),
      Offset(firstX, firstY + h * 3 / 4),
    ];
    // 计算旋转后的点
    var newList = list.map((e) {
      var dy = center.dy - e.dy;
      var dx = center.dx - e.dx;
      var da = math.atan2(dy, dx);
      var r = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2));
      // 正负决定箭头方向
      return Offset(arrow.x - r * math.cos(arrow.rotation + da),
          arrow.y - r * math.sin(arrow.rotation + da));
    }).toList();

    path.addPolygon(newList, true);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas, size);
    // 箭头坐标作为参照点
    var path =
        _createPath(arrow.w, arrow.h, Offset(arrow.x, arrow.y), arrow.rotation);
    _paint.color = Colors.blue;
    canvas.drawPath(path, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
