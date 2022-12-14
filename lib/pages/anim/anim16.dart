import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

class Anim16Page extends StatefulWidget {
  final String title;

  Anim16Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim16PageState createState() => _Anim16PageState();
}

class _Anim16PageState extends State<Anim16Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Arrow? _arrow;
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
          _size = _globalKey.currentContext!.size!;
        }
        if (_arrow == null) {
          _arrow =
              Arrow(x: _size.width / 2, y: _size.height / 2, w: 100, h: 60);
        }
        dx = _pointer.dx - _arrow!.x;
        dy = _pointer.dy - _arrow!.y;
        _arrow!.rotation = math.atan2(dy, dx);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pointerEvent(event) => _pointer = event.localPosition;

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
                painter:
                    _arrow == null ? null : MyCustomPainter(arrow: _arrow!),
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

  Path _createPath(Canvas canvas, double w, double h, Offset center) {
    //??????????????????
    double firstX = center.dx - w / 2, firstY = center.dy - h / 2;
    Path path = Path();
    // ????????? h/2 , ?????????w/2
    path.moveTo(firstX, firstY);
    var points = [
      Offset(firstX, firstY + h / 4),
      Offset(firstX + w / 2, firstY + h / 4),
      Offset(firstX + w / 2, firstY),
      Offset(firstX + w, firstY + h / 2),
      Offset(firstX + w / 2, firstY + h),
      Offset(firstX + w / 2, firstY + h * 3 / 4),
      Offset(firstX, firstY + h * 3 / 4),
    ];
    // ?????????????????????
    var newList = points.map((e) {
      var dy = center.dy - e.dy;
      var dx = center.dx - e.dx;
      var da = math.atan2(dy, dx);
      var r = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2));
      // ????????????????????????
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
    drawAuthorText(canvas);
    Offset center = Offset(arrow.x, arrow.y);

    // ???????????? ?????????????????????
    _paint.color = Colors.red[100]!;
    canvas.drawRect(
        Rect.fromCenter(center: center, width: size.width, height: size.width),
        _paint);

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
