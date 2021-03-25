import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim44Page extends StatefulWidget {
  final String title;

  Anim44Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim44PageState createState() => _Anim44PageState();
}

class _Anim44PageState extends State<Anim44Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball1, _ball2;
  double _bounce = -1;

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
        if (_ball1 == null) {
          double r = 40;
          _ball1 = Ball(
            x: randomScope([0, _size.width - r]),
            y: randomScope([0, _size.height - r]),
            r: r,
            fillStyle: Colors.red,
            m: 4,
            vx: randomScope([-5, 5]),
            vy: randomScope([-5, 5]),
          );
        }
        if (_ball2 == null) {
          double r = 60;
          _ball2 = Ball(
            x: randomScope([0, _size.width - r]),
            y: randomScope([0, _size.height - r]),
            r: r,
            fillStyle: Colors.blue,
            m: 6,
            vx: randomScope([-5, 5]),
            vy: randomScope([-5, 5]),
          );
        }

        _ball1!.x += _ball1!.vx;
        _ball1!.y += _ball1!.vy;
        _ball2!.x += _ball2!.vx;
        _ball2!.y += _ball2!.vy;

        checkBallHit(_ball1!, _ball2!);

        // 边界检测
        checkBallBounce(_ball1!, _size, _bounce);
        checkBallBounce(_ball2!, _size, _bounce);
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
              painter: _ball1 == null || _ball2 == null
                  ? null
                  : MyCustomPainter(ball1: _ball1!, ball2: _ball2!),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          double r1 = 40;
          _ball1 = Ball(
            x: randomScope([0, _size.width - r1]),
            y: randomScope([0, _size.height - r1]),
            r: r1,
            fillStyle: Colors.red,
            m: 4,
            vx: randomScope([-5, 5]),
            vy: randomScope([-5, 5]),
          );
          double r2 = 60;
          _ball2 = Ball(
            x: randomScope([0, _size.width - r2]),
            y: randomScope([0, _size.height - r2]),
            r: r2,
            fillStyle: Colors.blue,
            m: 6,
            vx: randomScope([-5, 5]),
            vy: randomScope([-5, 5]),
          );
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Ball ball1;
  final Ball ball2;

  MyCustomPainter({required this.ball1, required this.ball2});

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

    _paint.color = ball1.fillStyle;
    canvas.drawCircle(Offset(ball1.x, ball1.y), ball1.r, _paint);

    _paint.color = ball2.fillStyle;
    canvas.drawCircle(Offset(ball2.x, ball2.y), ball2.r, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
