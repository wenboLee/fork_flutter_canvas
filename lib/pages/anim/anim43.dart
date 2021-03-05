import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim43Page extends StatefulWidget {
  final String title;

  Anim43Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim43PageState createState() => _Anim43PageState();
}

class _Anim43PageState extends State<Anim43Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _controller;
  Size _size = Size.zero;
  Ball? _ball1, _ball2;

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
          _ball1 = Ball(
            x: 30,
            y: _size.height / 2,
            r: 30,
            fillStyle: Colors.red,
            m: 1,
            vx: 3,
          );
        }
        if (_ball2 == null) {
          _ball2 = Ball(
            x: _size.width - 60,
            y: _size.height / 2,
            r: 60,
            fillStyle: Colors.blue,
            m: 2,
            vx: -2,
          );
        }

        _ball1!.x += _ball1!.vx;
        _ball2!.x += _ball2!.vx;

        var dist =
            getDist(Offset(_ball1!.x, _ball1!.y), Offset(_ball2!.x, _ball2!.y));
        if (dist < _ball1!.r + _ball2!.r) {
          var lep = _ball1!.r + _ball2!.r - dist;
          _ball1!.x = _ball1!.x - lep / 2;
          _ball2!.x = _ball2!.x + lep / 2;

//        如果一个系统不受外力或所受外力的矢量和为零
//        那么这个系统的总动能保持不变
//        m1 * v1 + m2 * v2 = m1 * v1Final + m2 * v2Final
//        由于动能 e = 1/2 * m*v*v
//        所以 1/2 * m1 * v1*v1 + 1/2 * m2 * v2*v2 = 1/2 * m1 * v1Final*v1Final + 1/2 * m2 * v2Final*v2Final
          var v1Final = ((_ball1!.m - _ball2!.m) * _ball1!.vx +
                  2 * _ball2!.m * _ball2!.vx) /
              (_ball1!.m + _ball2!.m);
          var v2Final = ((_ball2!.m - _ball1!.m) * _ball2!.vx +
                  2 * _ball1!.m * _ball1!.vx) /
              (_ball1!.m + _ball2!.m);

          _ball1!.vx = v1Final;
          _ball2!.vx = v2Final;
        }

        // 边界检测, 弹性系数-1只改变方向
        checkBallBounce(_ball1!, _size, -1);
        checkBallBounce(_ball2!, _size, -1);
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
          _ball1 = Ball(
            x: 30,
            y: _size.height / 2,
            r: 30,
            fillStyle: Colors.red,
            m: 1,
            vx: 3,
          );
          _ball2 = Ball(
            x: _size.width - 60,
            y: _size.height / 2,
            r: 60,
            fillStyle: Colors.blue,
            m: 2,
            vx: -2,
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
    drawAuthorText(canvas, size);

    _paint.color = Colors.green;
    _paint.strokeWidth = 2;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), _paint);

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
