import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:math' as math;

class MainPage extends StatefulWidget {
  final String title;

  MainPage({this.title});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  double axRad = 0, ayRad = 0; // 经纬度旋转弧度
  double ax = 10, ay = 10; // 经纬度
  double pointR = 4, r3d = 0; // 点半径、3d球半径
  Map<String, Ball> _ballsMap = Map();
  bool isMouseDown = false;
  double startX = 0, startY = 0, vx = 0, vy = 0, friction = 0.98; // 摩擦力
  Offset _pointer = Offset.zero;

  void _draw3DBall(Offset center) {
    // 经纬线条数
    double xNum = 360 / ax, yNum = 360 / ay;
    List.generate(xNum.toInt(), (xIndex) {
      List.generate(yNum.toInt(), (yIndex) {
        // 纬度弧度
        var yRad = toRad((yIndex + 1) * ay - 90) + ayRad;
        var y = center.dy + r3d * math.sin(yRad);
        // 经度弧度
        var xRad = toRad((xIndex + 1) * ax) + axRad;
        // 纬度半径
        var latitudeR = r3d * math.cos(yRad) * math.cos(xRad);
        // 2-0.5-2
        var scale = 0.5 + 1.5 * math.sin(xRad).abs();
        // 0.4-0.7-1.0
        var alpha = (0.7 + 0.3 * math.sin(xRad)) * 255;
        var key = '${xIndex}_$yIndex';
        if (!_ballsMap.containsKey(key)) {
          _ballsMap[key] = Ball(
            x: center.dx + latitudeR,
            y: y,
            r: pointR * scale,
            fillStyle: randomColor(alpha: alpha.toInt()),
          );
        } else {
          var ball = _ballsMap[key];
          ball.x = center.dx + latitudeR;
          ball.y = y;
          ball.r = pointR * scale;
          ball.fillStyle = Color.fromARGB(
            alpha.toInt(),
            ball.fillStyle.red,
            ball.fillStyle.green,
            ball.fillStyle.blue,
          );
          _ballsMap[key] = ball;
        }
      });
    });
  }

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext.size;
          r3d = (_size.height > _size.width ? _size.width : _size.height) *
              0.8 /
              2;
        }

        _draw3DBall(_size.center(Offset.zero));
        _setSpeed();

        axRad += vx;
        vx *= friction;
        ayRad += vy;
        vy *= friction;
        axRad %= math.pi * 2;
        ayRad %= math.pi * 2;
      }
    });
    super.initState();
  }

  void _setSpeed() {
    // 比较最后一帧和前一帧
    // 先比较，再赋值
    if (isMouseDown) {
      vx = (_pointer.dx - startX) * 0.004;
      vy = (_pointer.dy - startY) * 0.004;
      startX = _pointer.dx;
      startY = _pointer.dy;
    }
  }

  bool _isPoint(double r3d, Offset center, Offset point) {
    return r3d >=
        math.sqrt(math.pow(point.dx - center.dx, 2) +
            math.pow(point.dy - center.dy, 2));
  }

  void _pointerDownEvent(event) {
    _pointer = event.localPosition;
    isMouseDown = false;
    if (_isPoint(r3d, _size.center(Offset.zero), _pointer)) {
      isMouseDown = true;
      startX = _pointer.dx;
      startY = _pointer.dy;
    }
  }

  void _pointerMoveEvent(event) {
    _pointer = event.localPosition;
  }

  void _pointerUpEvent(event) {
    _pointer = event.localPosition;
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
                    painter: MyCustomPainter(balls: _ballsMap.values.toList()),
                  );
                },
              ),
              behavior: HitTestBehavior.opaque,
              onPointerDown: _pointerDownEvent,
              onPointerMove: _pointerMoveEvent,
              onPointerUp: _pointerUpEvent,
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 40,
              child: SizedBox(
                width: _size?.width ?? 0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('经度 $ax'),
                        Slider(
                          min: 10,
                          max: 180,
                          label: '${ax.toInt()}',
                          divisions: 17,
                          onChanged: (value) {
                            setState(() {
                              ax = value.ceilToDouble();
                              _ballsMap.clear();
                            });
                          },
                          value: ax,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('纬度 $ay'),
                        Slider(
                          min: 10,
                          max: 180,
                          label: '${ay.toInt()}',
                          divisions: 17,
                          onChanged: (value) {
                            setState(() {
                              ay = value.ceilToDouble();
                              _ballsMap.clear();
                            });
                          },
                          value: ay,
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
  final List<Ball> balls;

  MyCustomPainter({this.balls});

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
