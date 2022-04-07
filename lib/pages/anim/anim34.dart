import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

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
  List<Ball>? _ballList;
  double dx = 0, dy = 0, easing = 0.05; //缓动系数

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
        if (_ballList == null) {
          _ballList = _initBalls(num: 20);
        }

        _drawBallMove();
      }
    });
    super.initState();
  }

  void _drawBallMove() {
    for (var i = 0; i < _ballList!.length; i++) {
      var ball = _ballList![i];

      var vx = (_size.width / 2 - ball.x) * easing;
      var vy = (_size.height / 2 - ball.y) * easing;

      ball.x += vx;
      ball.y += vy;
    }
  }

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) => Ball(
        id: index,
        x: randomScope([0, _size.width]),
        y: randomScope([0, _size.height]),
        r: 30,
        fillStyle: randomColor(),
        m: 1,
      ),
    );
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
                painter: _ballList == null
                    ? null
                    : MyCustomPainter(ballList: _ballList!),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ballList = _initBalls(num: 20);
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Ball> ballList;

  MyCustomPainter({required this.ballList});

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
    ballList.forEach((ball) {
      _paint.color = ball.fillStyle;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
