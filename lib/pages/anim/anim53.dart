import 'dart:ui' as ui;
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

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this)
          ..repeat();
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
              painter: CharLinePainter(progress: _controller.value),
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
  final double progress;

  CharLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas);
    final pointMax = 7;
    double radius = 4;
    final paint = Paint();
    final linePath = Path();
    final cubicPath = Path();
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
    linePath.addPolygon(offsetList, true);

    // 添加动画
    ui.PathMetrics lineComputeMetrics =
        linePath.computeMetrics(forceClosed: true);
    lineComputeMetrics.forEach((pathMetric) {
      // 绘制直线
      Path extractPath =
          pathMetric.extractPath(0, pathMetric.length * progress);
      canvas.drawPath(extractPath, paint..color = Colors.blue.withOpacity(0.2));
    });
    ui.PathMetrics computeMetrics = cubicPath.computeMetrics(forceClosed: true);
    computeMetrics.forEach((pathMetric) {
      // 绘制曲线
      Path extractPath =
          pathMetric.extractPath(0, pathMetric.length * progress);
      canvas.drawPath(extractPath, paint..color = Colors.green);
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
          ]).createShader(extractPath.getBounds());

      canvas.drawPath(
        extractPath,
        paint
          ..shader = shader
          ..isAntiAlias = true
          ..style = PaintingStyle.fill,
      );
    });

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
