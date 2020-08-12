import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/arrow.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class Anim20Page extends StatefulWidget {
  final String title;

  Anim20Page({this.title});

  @override
  _Anim20PageState createState() => _Anim20PageState();
}

class _Anim20PageState extends State<Anim20Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Arrow _arrow;
  double vx = 0, vy = 0, vr = 0, a = 0, f = 0.95; //摩擦力

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext.size;
          setState(() {});
        }
        if (_arrow == null) {
          _arrow =
              Arrow(x: _size.width / 2, y: _size.height / 2, w: 100, h: 60);
        }
        _arrow.rotation += toRad(vr);
        var angle = _arrow.rotation;
        var ax = math.cos(angle) * a;
        var ay = math.sin(angle) * a;

        vx += ax;
        vy += ay;
        vx *= f;
        vy *= f;

        _arrow.x += vx;
        _arrow.y += vy;

        // 越界处理
        if (_arrow.x - _arrow.w / 2 >= _size.width) {
          _arrow.x = 0 - _arrow.w / 2;
        } else if (_arrow.x + _arrow.w / 2 <= 0) {
          _arrow.x = _size.width + _arrow.w / 2;
        }
        if (_arrow.y - _arrow.h / 2 >= _size.height) {
          _arrow.y = 0 - _arrow.h / 2;
        } else if (_arrow.y + _arrow.h / 2 <= 0) {
          _arrow.y = _size.height + _arrow.h / 2;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GestureDetector _buildGestureDetector(
      {Function(DragDownDetails) onPanDown,
      Function(DragEndDetails) onPanEnd,
      Widget child,
      EdgeInsetsGeometry margin = EdgeInsets.zero}) {
    return GestureDetector(
      onPanDown: onPanDown,
      onPanEnd: onPanEnd,
      child: Container(
        width: 50,
        height: 50,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.green[200],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.title),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  key: _globalKey,
                  size: Size.infinite,
                  painter: MyCustomPainter(arrow: _arrow),
                );
              },
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 40,
              child: SizedBox(
                width: _size?.width ?? 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGestureDetector(
                      onPanDown: (e) => vr = -5,
                      onPanEnd: (e) => vr = 0,
                      child: Icon(Icons.keyboard_arrow_left),
                    ),
                    _buildGestureDetector(
                      onPanDown: (e) => vr = 5,
                      onPanEnd: (e) => vr = 0,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                    Expanded(child: Container()),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGestureDetector(
                          onPanDown: (e) => a = 0.5,
                          onPanEnd: (e) => a = 0,
                          margin: EdgeInsets.only(bottom: 20),
                          child: Icon(Icons.keyboard_arrow_up),
                        ),
                        _buildGestureDetector(
                          onPanDown: (e) => a = -0.5,
                          onPanEnd: (e) => a = 0,
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
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
