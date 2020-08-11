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

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {});
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
              painter: MyCustomPainter(),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter();

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  void _draw3DBall(Canvas canvas, Size size, Offset center) {
    double r = 150;
    List.generate(36, (xIndex) {
      List.generate(18, (yIndex) {
        var rad = toRad((yIndex + 1) * 10 - 90);
        var y = center.dy + r * math.sin(rad);
        // 经度弧度
        var xRad = toRad((xIndex + 1) * 10);
        // 纬度半径
        var latitudeR = r * math.cos(rad) * math.cos(xRad);
        var scale = 2 + 1 * math.sin(xRad);
        if (xIndex + 1 > 18) {
          _paint.color = Colors.pink;
        } else {
          _paint.color = Colors.green;
        }
        _paint.style = PaintingStyle.fill;
        _paint.strokeWidth = 1;
        canvas.drawCircle(Offset(center.dx + latitudeR, y), 2 * scale, _paint);
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

    _paint.strokeWidth = 1;
    _paint.color = Colors.red;
    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), _paint);
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
