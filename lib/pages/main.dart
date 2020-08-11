import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'dart:math' as math;

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

  void _draw3DBall(Canvas canvas, Size size) {
    double r = 300;
    canvas.drawArc(
      Rect.fromCenter(center: size.center(Offset.zero), width: r, height: r),
      -math.pi / 2,
      math.pi,
      true,
      _paint,
    );
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
    _draw3DBall(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
