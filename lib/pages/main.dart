import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

import 'package:flutter_canvas/widget/utils.dart';

class MainPage extends StatefulWidget {
  final String title;

  MainPage({this.title});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double axRad = 0;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      axRad += 0.2;
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: MyCustomPainter(axRad: axRad),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double axRad;
  MyCustomPainter({this.axRad});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  void _draw3DBall(Canvas canvas, Size size, Offset center) {
    // 水平方向旋转10弧度
    var dRad = toRad(axRad);
    double r = 150;
    double ax = 30 , ay = 20;
    double xNum = 360 / ax, yNum = 360 / ay;
    List.generate(xNum.toInt(), (xIndex) {
      List.generate(yNum.toInt(), (yIndex) {
        // 纬度弧度
        var yRad = toRad((yIndex + 1) * ay - 90) + dRad;
        var y = center.dy + r * math.sin(yRad);
        // 经度弧度
        var xRad = toRad((xIndex + 1) * ax) + dRad;
        // 纬度半径
        var latitudeR = r * math.cos(yRad) * math.cos(xRad);
        // 1.5-1-1.5
        var scale = 1 + 0.5 * math.sin(xRad).abs();
        // 0.6-0.8-1.0
        var alpha = (0.8 + 0.2 * math.sin(xRad)) * 255;
        _paint.color = Color.fromARGB(alpha.toInt(), 0, 255, 0);
        _paint.style = PaintingStyle.fill;
        _paint.strokeWidth = 1;
        canvas.drawCircle(Offset(center.dx + latitudeR, y), 3 * scale, _paint);
      });
    });
  }

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
    Offset center = size.center(Offset.zero);
    _draw3DBall(canvas, size, center);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
