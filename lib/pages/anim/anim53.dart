import 'dart:ui' as ui;
import 'dart:math';
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
  late Animation<double> _animation;
  int _pointMax = Random.secure().nextInt(10).clamp(3, 10);

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this)
          ..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 1, curve: Curves.ease),
      ),
    );
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
              painter: CharLinePainter(
                  progress: _animation.value, pointMax: _pointMax),
            );
          },
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          _pointMax = Random.secure().nextInt(10).clamp(3, 10);
        });
      }),
    );
  }
}

class CharLinePainter extends CustomPainter {
  final double progress;
  final int pointMax;

  CharLinePainter({required this.progress, required this.pointMax});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas);
    double radius = 3;
    final paint = Paint();
    final cubicPath = Path();
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = 2;
    var steps = size.width / pointMax;
    //??????????????????????????????????????????1/2 * steps
    for (int index = 0; index < pointMax; index++) {
      var currPoint = Offset(steps / 2 + steps * index,
          index % 2 == 0 ? size.height / 2 : (size.height / 2 / 2));
      if (index == 0) {
        cubicPath.moveTo(currPoint.dx, currPoint.dy);
      }
      if (index > 0) {
        var prePoint = Offset(steps / 2 + steps * (index - 1),
            (index - 1) % 2 == 0 ? size.height / 2 : (size.height / 2 / 2));
        // ????????????(2,0),(2,4),??????????????????
        var control1 =
            Offset(prePoint.dx + (currPoint.dx - prePoint.dx) / 2, prePoint.dy);
        var control2 = Offset(
            prePoint.dx + (currPoint.dx - prePoint.dx) / 2, currPoint.dy);
        cubicPath.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy,
            currPoint.dx, currPoint.dy);
        if (index == pointMax - 1 && pointMax % 2 == 0) {
          // ?????????????????????????????????x??????
          Rect bounds = cubicPath.getBounds();
          cubicPath.lineTo(bounds.right, bounds.bottom);
        }
        canvas.drawCircle(control1, radius, paint..color = Colors.deepPurple);
        canvas.drawCircle(control2, radius, paint..color = Colors.deepPurple);
      }
      canvas.drawCircle(currPoint, radius, paint..color = Colors.red);
    }

    // ????????????
    ui.PathMetrics computeMetrics = cubicPath.computeMetrics(forceClosed: true);
    computeMetrics.forEach((pathMetric) {
      // ????????????
      Path extractPath =
          pathMetric.extractPath(0, pathMetric.length * progress);
      // ???????????????x??????
      Rect bounds = extractPath.getBounds();
      extractPath.lineTo(bounds.right, bounds.bottom);
      canvas.drawPath(extractPath, paint..color = Colors.red);
      //??????????????????
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
      fontSize: 18,
    ));
    pb.pushStyle(ui.TextStyle(color: Colors.green));
    pb.addText('1???????????????????????????\n2????????????????????????????????????\n??????????????????????????????????????????');

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
