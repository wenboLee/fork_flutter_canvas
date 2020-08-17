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
  double ax = 10, ay = 10, rad3d = 180; // 经纬度, 3d圆弧
  double pointR = 5, r3d = 0; // 点半径、3d球半径
  Map<String, Ball> _ballsMap = Map();
  bool isMouseDown = false;
  double startX = 0, startY = 0, vx = 0, vy = 0, friction = 0.98; // 摩擦力
  Offset _pointer = Offset.zero;

  void _draw3DBall(Offset center) {
    // 经纬线条数
    double xNum = rad3d / ax, yNum = rad3d / ay / 2;
    List.generate(xNum.toInt(), (xIndex) {
      List.generate(yNum.toInt(), (yIndex) {
        // 纬度弧度
        var yRad = toRad(yIndex * ay - 90) + ayRad;
        var y = center.dy + r3d * math.sin(yRad);
        // 经度弧度
        var xRad = toRad(xIndex * ax) + axRad;
        // 纬度半径
        var latitudeR = r3d * math.cos(yRad) * math.cos(xRad);
        // 2-3-4 里-中-外
        var scale = (3 + 1 * math.sin(xRad)) / 9 * 3;
        // 1/3-2/3-1
        var alpha = 255 / 3 * (2 + math.sin(xRad));
        var key = '${xIndex}_$yIndex';
        if (!_ballsMap.containsKey(key)) {
          _ballsMap[key] = Ball(
            x: center.dx + latitudeR,
            y: y,
            r: pointR * scale,
            alpha: math.sin(xRad),
            fillStyle: randomColor(alpha: alpha.toInt()),
            scale: scale,
          );
        } else {
          var ball = _ballsMap[key];
          ball.x = center.dx + latitudeR;
          ball.y = y;
          ball.r = pointR * scale;
          ball.alpha = math.sin(xRad);
          ball.fillStyle = Color.fromARGB(
            alpha.toInt(),
            ball.fillStyle.red,
            ball.fillStyle.green,
            ball.fillStyle.blue,
          );
          ball.scale = scale;
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
          setState(() {});
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
      vx = (_pointer.dx - startX) * -0.004;
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

  Column _buildRow(int type) {
    var textStyle = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (type == 0)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                '经度 ${ax.toInt()}',
                style: textStyle,
              ),
              Slider(
                min: 1,
                max: 180,
                label: '${ax.toInt()}',
                divisions: 179,
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
        if (type == 0)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                '纬度 ${ay.toInt()}',
                style: textStyle,
              ),
              Slider(
                min: 1,
                max: 180,
                label: '${ay.toInt()}',
                divisions: 179,
                onChanged: (value) {
                  setState(() {
                    ay = value.ceilToDouble();
                    _ballsMap.clear();
                  });
                },
                value: ay,
              ),
            ],
          ),
        if (type == 1)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                '小球半径 ${pointR.toInt()}',
                style: textStyle,
              ),
              Slider(
                min: 1,
                max: r3d <= 0 ? pointR : r3d.ceilToDouble(),
                label: '${pointR.toInt()}',
                divisions: 99,
                onChanged: (value) {
                  setState(() {
                    pointR = value.ceilToDouble();
                    _ballsMap.clear();
                  });
                },
                value: pointR,
              ),
            ],
          ),
        if (type == 1)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                '3D圆弧 ${rad3d.toInt()}',
                style: textStyle,
              ),
              Slider(
                min: 1,
                max: 360,
                label: '${rad3d.toInt()}',
                divisions: 359,
                onChanged: (value) {
                  setState(() {
                    rad3d = value.ceilToDouble();
                    _ballsMap.clear();
                  });
                },
                value: rad3d,
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.title),
      body: Container(
        color: Colors.grey[400],
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
                    painter: MyCustomPainter(
                        balls: _ballsMap.values.toList(), r3d: r3d),
                  );
                },
              ),
              behavior: HitTestBehavior.opaque,
              onPointerDown: _pointerDownEvent,
              onPointerMove: _pointerMoveEvent,
              onPointerUp: _pointerUpEvent,
            ),
            Positioned(
              left: 20,
              right: 0,
              bottom: 5,
              child: _buildRow(0),
            ),
            Positioned(
              right: 0,
              top: 10,
              child: _buildRow(1),
            ),
          ],
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _ballsMap.clear();
          axRad = 0;
          ayRad = 0;
          ax = 10;
          ay = 10;
          rad3d = 180;
          pointR = 5;
          r3d = (_size.height > _size.width ? _size.width : _size.height) *
              0.8 /
              2;
          isMouseDown = false;
          startX = 0;
          startY = 0;
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Ball> balls;
  final double r3d;

  MyCustomPainter({this.balls, this.r3d});

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
    //地球仪效果， 性能低
//    var transform = Matrix4.identity()
//      ..setEntry(3, 2, 0.001)
//      ..rotateX(toRad(10))
//      ..rotateY(toRad(10));
//    canvas.transform(transform.storage);
    // 优先渲染远离屏幕面的点
    balls.sort((a, b) => a.scale.compareTo(b.scale));
    balls.forEach((ball) {
      double elevation = ball.r;
      if (elevation > 20) {
        elevation = 20;
      }
      canvas.drawShadow(
        Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(ball.x, ball.y),
              width: ball.r * 2,
              height: ball.r * 2,
            ),
          )
          ..close(),
        ball.fillStyle,
        elevation,
        false,
      );
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
