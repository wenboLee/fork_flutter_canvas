import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim49Page extends StatefulWidget {
  final String title;

  Anim49Page({this.title});

  @override
  _Anim49PageState createState() => _Anim49PageState();
}

class _Anim49PageState extends State<Anim49Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  Ball _ball;
  double z = 0, f1 = 200, hx = 0, hy = 0, dx = 0, dy = 0, r = 80;

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
        if (_ball == null) {
          _ball = Ball(r: r);
        }

        hx = _size.width / 2;
        hy = _size.height / 2;

        if (f1 + z > 0) {
          _ball.show = true;
          var scale = f1 / (f1 + z);
          _ball.scaleX = scale;
          _ball.scaleY = scale;
          // 相对canvas左上点缩放，进行校正在中点缩放
          _ball.x = hx + dx * scale;
          _ball.y = hy + dy * scale;
          _ball.r = r * scale;
        } else {
          _ball.show = false;
        }
      }
    });
    super.initState();
  }

  void _pointerEvent(event) {
    var pointer = event.localPosition;
    dx = pointer.dx - hx;
    dy = pointer.dy - hy;
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
        child: Center(
          child: child,
        ),
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
            Listener(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    key: _globalKey,
                    size: Size.infinite,
                    painter: MyCustomPainter(ball: _ball),
                  );
                },
              ),
              behavior: HitTestBehavior.opaque,
              onPointerMove: _pointerEvent,
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildGestureDetector(
                onPanDown: (e) {
                  setState(() {
                    z += 5;
                  });
                },
                child: Text(
                  '进',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildGestureDetector(
                  onPanDown: (e) {
                    setState(() {
                      z -= 5;
                    });
                  },
                  child: Text(
                    '出',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball;

  MyCustomPainter({this.ball});

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

    if (ball.show) {
      _paint.color = ball.fillStyle;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
