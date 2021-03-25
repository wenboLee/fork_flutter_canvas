import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim53Page extends StatefulWidget {
  final String title;

  Anim53Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim53PageState createState() => _Anim53PageState();
}

class _Anim53PageState extends State<Anim53Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double angle = 65 * math.pi / 180, a = 0.1;

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
              painter: CharLinePainter(),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {});
      }),
    );
  }
}

class CharLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas);
    final pointMax = 7;
    double radius = 4;
    final path = Path();
    var paint = Paint();
    var cubicPath = Path();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    var steps = size.width / pointMax;
    //默认会少一段，所有点可以平移1/2 * steps
    List<Offset> offsetList = List.generate(pointMax, (index) {
      var currPoint = Offset(steps / 2 + steps * index,
          index % 2 == 0 ? size.height / 2 : (size.height / 2 / 2));
      if (index == 0) {
        cubicPath.moveTo(currPoint.dx, currPoint.dy);
      }
      if (index > 0) {
        var prePoint = Offset(steps / 2 + steps * (index - 1),
            (index - 1) % 2 == 0 ? size.height / 2 : (size.height / 2 / 2));
        // 找控制点(2,0),(2,4),田字上下两点
        var control1 =
            Offset(prePoint.dx + (currPoint.dx - prePoint.dx) / 2, prePoint.dy);
        var control2 = Offset(
            prePoint.dx + (currPoint.dx - prePoint.dx) / 2, currPoint.dy);
        cubicPath.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy,
            currPoint.dx, currPoint.dy);
        canvas.drawCircle(control1, radius, paint..color = Colors.deepPurple);
        canvas.drawCircle(control2, radius, paint..color = Colors.deepPurple);
      }
      canvas.drawCircle(currPoint, radius, paint..color = Colors.red);
      return currPoint;
    });
    // 绘制直线
    path.addPolygon(offsetList, true);
    canvas.drawPath(path, paint..color = Colors.blue.withOpacity(0.2));
    canvas.drawPath(cubicPath, paint..color = Colors.green);
    //绘制渐变阴影
    Shader shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.repeated,
        colors: [
          Colors.deepPurple.withOpacity(0.5),
          Colors.red.withOpacity(0.5),
          Colors.cyan.withOpacity(0.5),
          Colors.deepPurpleAccent.withOpacity(0.5),
        ]).createShader(cubicPath.getBounds());

    canvas.drawPath(
      cubicPath,
      paint
        ..shader = shader
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );

    _drawText(canvas, size);
    canvas.restore();
  }

  void _drawText(Canvas canvas, Size size) {
    ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      fontSize: 20,
    ));
    pb.pushStyle(ui.TextStyle(color: Colors.green));
    pb.addText('1：红色点为数据点；\n2：紫色点为贝塞尔控制点，\n波谷和波峰之间有两个控制点；');

    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: size.width);
    ui.Paragraph paragraph = pb.build()..layout(pc);
    Offset offset = Offset(20, size.center(Offset.zero).dy + 30);
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
