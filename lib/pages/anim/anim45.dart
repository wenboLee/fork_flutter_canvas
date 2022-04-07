import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim45Page extends StatefulWidget {
  final String title;

  Anim45Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim45PageState createState() => _Anim45PageState();
}

class _Anim45PageState extends State<Anim45Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  List<Ball>? _balls;

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
        if (_balls == null) {
          _balls = _initBalls(num: 50);
        }

        _drawBallMove();
      }
    });
    super.initState();
  }

  void _drawBallMove() {
    for (var i = 0; i < _balls!.length; i++) {
      var ball = _balls![i];
      ball.x += ball.vx;
      ball.y += ball.vy;

      for (var j = i + 1; j < _balls!.length; j++) {
        checkBallHit(ball, _balls![j]);
      }

      checkBallBounce(ball, _size);
    }
  }

  List<Ball> _initBalls({required int num}) {
    return List.generate(
      num,
      (index) {
        var r = randomScope([10, 20]);
        return Ball(
          id: index,
          x: randomScope([0, _size.width]),
          y: randomScope([0, _size.height]),
          r: r,
          fillStyle: randomColor(),
          vx: randomScope([-2, 2]),
          vy: randomScope([-2, 2]),
          m: r,
        );
      },
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: _balls == null ? null : MyCustomPainter(balls: _balls!),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _balls = _initBalls(num: 50);
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
      canvas.drawCircle(Offset(ball.x, ball.y), ball.r, _paint);
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
