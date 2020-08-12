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
  double pointR = 4; // 点半径
  Map<String, Ball> _ballsMap = Map();

  void _draw3DBall(Offset center, Size size) {
    double r = (size.height > size.width ? size.width : size.height) * 0.8 / 2;
    // 经纬线条数
    double xNum = 360 / ax, yNum = 360 / ay;
    List.generate(xNum.toInt(), (xIndex) {
      List.generate(yNum.toInt(), (yIndex) {
        // 纬度弧度
        var yRad = toRad((yIndex + 1) * ay - 90) + ayRad;
        var y = center.dy + r * math.sin(yRad);
        // 经度弧度
        var xRad = toRad((xIndex + 1) * ax) + axRad;
        // 纬度半径
        var latitudeR = r * math.cos(yRad) * math.cos(xRad);
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
        }
        axRad += 0.005;
        ayRad += 0.001;
        axRad %= math.pi * 2;
        ayRad %= math.pi * 2;
        _draw3DBall(_size.center(Offset.zero), _size);
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
              painter: MyCustomPainter(balls: _ballsMap.values.toList()),
            );
          },
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
//    // 文本构造器
//    ui.ParagraphBuilder pb = ui.ParagraphBuilder(
//      ui.ParagraphStyle(
//        textAlign: TextAlign.left,
//        fontWeight: FontWeight.bold,
//        fontStyle: FontStyle.normal,
//        fontSize: 15.0,
//      ),
//    );
//    pb.pushStyle(ui.TextStyle(color: Colors.black87));
//    pb.addText('Flutter Canvas 请叫我code哥');
//    // 文本的宽度约束
//    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: 300);
//    // 这里需要先layout,将宽度约束填入,否则无法绘制
//    ui.Paragraph paragraph = pb.build()..layout(pc);
//    // 文字左上角起始点
//    Offset offset = Offset(50, 50);
//    canvas.drawParagraph(paragraph, offset);
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
