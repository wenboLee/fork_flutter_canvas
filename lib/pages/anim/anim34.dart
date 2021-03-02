import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim34Page extends StatefulWidget {
  final String title;

  Anim34Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim34PageState createState() => _Anim34PageState();
}

class _Anim34PageState extends State<Anim34Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball;
  double easing = 0.05; //缓动系数

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
          _ball = Ball(x: 50, y: 50, r: 30);
        }

        var dx = _size.width / 2 - _ball!.x;
        var dy = _size.height / 2 - _ball!.y;

        _ball!.x += dx * easing;
        _ball!.y += dy * easing;
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
              painter: MyCustomPainter(ball: _ball!),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ball = Ball(x: 50, y: 50, r: 30);
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
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
