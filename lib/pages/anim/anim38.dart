import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/box.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim38Page extends StatefulWidget {
  final String title;

  Anim38Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim38PageState createState() => _Anim38PageState();
}

class _Anim38PageState extends State<Anim38Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Box? _box1, _box2, _activeBox;
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
        if (_box1 == null) {
          _box1 = Box(x: 50, y: 50, w: 30, h: 30);
        }
        if (_box2 == null) {
          _box2 = Box(x: _size.width / 2, y: _size.height / 2, w: 60, h: 60);
        }

        if (rectHit(_box1!, _box2!)) {
          Toast.show(context, '盒子发生碰撞');
        }
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    Offset point = event.localPosition;
    if (isBoxPoint(_box1!, point)) {
      _activeBox = _box1;
    }
    if (isBoxPoint(_box2!, point)) {
      _activeBox = _box2;
    }
    if (_activeBox != null) {
      dx = point.dx - _activeBox!.x;
      dy = point.dy - _activeBox!.y;
    }
  }

  void _pointerMoveEvent(event) {
    Offset point = event.localPosition;
    if (_activeBox != null) {
      _activeBox!.x = point.dx - dx;
      _activeBox!.y = point.dy - dy;
    }
  }

  void _pointerUpEvent(event) => _activeBox = null;

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
                painter: _box1 == null || _box2 == null
                    ? null
                    : MyCustomPainter(box1: _box1!, box2: _box2!),
              );
            },
          ),
          onPointerDown: _pointerDownEvent,
          onPointerMove: _pointerMoveEvent,
          onPointerUp: _pointerUpEvent,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _box1 = Box(x: 50, y: 50, w: 30, h: 30);
          _box2 = Box(x: _size.width / 2, y: _size.height / 2, w: 60, h: 60);
          _activeBox = null;
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Box box1, box2;

  MyCustomPainter({required this.box1, required this.box2});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas, size);

    _paint.color = Colors.green;
    canvas.drawRect(Rect.fromLTWH(box1.x, box1.y, box1.w, box1.h), _paint);

    _paint.color = Colors.red;
    canvas.drawRect(Rect.fromLTWH(box2.x, box2.y, box2.w, box2.h), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
