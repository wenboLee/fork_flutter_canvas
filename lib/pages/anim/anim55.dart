import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim55Page extends StatefulWidget {
  final String title;

  Anim55Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim55PageState createState() => _Anim55PageState();
}

class _Anim55PageState extends State<Anim55Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball>? _balls;
  double dx = 0, dy = 0, spring = 0.001; //弹动系数
  double easing = 0.001; //缓动系数
  double friction = 0.95; //摩擦力
  Ball? draggedBall;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      // if (mounted) {
      //   if (_size == Size.zero) {
      //     _size = _globalKey.currentContext!.size!;
      //   }
      //   if (_balls == null) {
      //     _balls = _initBalls(num: 10);
      //   }
      // }
    });
    super.initState();
  }

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: randomScope([50, _size.width - 50]),
        y: randomScope([50, _size.height - 50]),
        fillStyle: randomColor(),
        r: 30,
        m: 1,
      ),
    );
  }

  void _pointerDownEvent(event) {
    Offset pointer = event.localPosition;
    _balls!.forEach((ball) {
      if (isPoint(ball, pointer)) {
        ball.dragged = true;
        dx = pointer.dx - ball.x;
        dy = pointer.dy - ball.y;
        draggedBall = ball;
      }
    });
  }

  void _pointerMoveEvent(event) {
    Offset pointer = event.localPosition;
    if (draggedBall != null) {
      draggedBall!.x = pointer.dx - dx;
      draggedBall!.y = pointer.dy - dy;
    }
  }

  void _pointerUpEvent(event) {
    draggedBall?.dragged = false;
    draggedBall = null;
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
                painter:
                    _balls == null ? null : MyCustomPainter(balls: _balls!),
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
          _balls = _initBalls(num: 10);
          draggedBall = null;
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Ball> balls;

  MyCustomPainter({required this.balls});

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
    balls.forEach((ball) {
      _paint.color = ball.fillStyle;
      _paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
