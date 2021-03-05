import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim26Page extends StatefulWidget {
  final String title;

  Anim26Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim26PageState createState() => _Anim26PageState();
}

class _Anim26PageState extends State<Anim26Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball;
  double dx = 0, dy = 0;
  bool isMouseDown = false;

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
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
        }
      }
    });
    super.initState();
  }

  void _pointerDownEvent(event) {
    var pointer = event.localPosition;
    isMouseDown = false;
    if (isPoint(_ball!, pointer)) {
      isMouseDown = true;
      dx = pointer.dx - _ball!.x;
      dy = pointer.dy - _ball!.y;
    }
  }

  void _pointerMoveEvent(event) {
    var pointer = event.localPosition;
    if (isMouseDown) {
      _ball!.x = pointer.dx - dx;
      _ball!.y = pointer.dy - dy;
    }
  }

  void _pointerUpEvent(event) {
    isMouseDown = false;
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
        child: Listener(
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
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDownEvent,
          onPointerMove: _pointerMoveEvent,
          onPointerUp: _pointerUpEvent,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ball = Ball(x: _size.width / 2, y: _size.height / 2, r: 30);
          isMouseDown = false;
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
    drawAuthorText(canvas, size);
    _paint.color = ball.fillStyle;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
