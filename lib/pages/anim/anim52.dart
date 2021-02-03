import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

class Anim52Page extends StatefulWidget {
  Anim52Page({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _Anim52PageState createState() => _Anim52PageState();
}

class _Anim52PageState extends State<Anim52Page>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  int _seconds = 10;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: _seconds), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 2), () {
          _animationController.forward(from: 0);
        });
      }
    });
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: MyPainter(
                    animationController: _animationController,
                    seconds: _seconds),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final AnimationController animationController;
  final int seconds;

  MyPainter({this.animationController, this.seconds});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(size.width / 1024, size.width / 1024);
    List<String> pathsData = [
      'M759.466667 1024H264.533333C119.466667 1024 0 904.533333 0 759.466667V261.688889C0 116.622222 119.466667 0 264.533333 0h494.933334C904.533333 0 1024 116.622222 1024 261.688889v497.777778c0 145.066667-119.466667 264.533333-264.533333 264.533333zM264.533333 54.044444c-116.622222 0-210.488889 93.866667-210.488889 210.488889v497.777778c0 116.622222 93.866667 210.488889 210.488889 210.488889h494.933334c116.622222 0 210.488889-93.866667 210.488889-210.488889V261.688889c0-116.622222-93.866667-210.488889-210.488889-210.488889H264.533333z',
      'M355.555556 290.133333m-128 0a128 128 0 1 0 256 0 128 128 0 1 0-256 0Z',
      'M355.555556 489.244444c-108.088889 0-199.111111-88.177778-199.111112-199.111111s88.177778-199.111111 199.111112-199.111111 199.111111 88.177778 199.111111 199.111111-88.177778 199.111111-199.111111 199.111111z m0-369.777777c-93.866667 0-170.666667 76.8-170.666667 170.666666s76.8 170.666667 170.666667 170.666667 170.666667-76.8 170.666666-170.666667-76.8-170.666667-170.666666-170.666666z',
      'M355.555556 733.866667m-128 0a128 128 0 1 0 256 0 128 128 0 1 0-256 0Z',
      'M355.555556 932.977778c-108.088889 0-199.111111-88.177778-199.111112-199.111111s88.177778-199.111111 199.111112-199.111111 199.111111 88.177778 199.111111 199.111111-88.177778 199.111111-199.111111 199.111111z m0-369.777778c-93.866667 0-170.666667 76.8-170.666667 170.666667s76.8 170.666667 170.666667 170.666666 170.666667-76.8 170.666666-170.666666-76.8-170.666667-170.666666-170.666667zM779.377778 733.866667c-71.111111 0-128-56.888889-128-128s56.888889-128 128-128 128 56.888889 128 128c2.844444 71.111111-56.888889 128-128 128z m0-230.4c-56.888889 0-102.4 45.511111-102.4 102.4s45.511111 102.4 102.4 102.4 102.4-45.511111 102.4-102.4-45.511111-102.4-102.4-102.4z',
      'M779.377778 352.711111m-45.511111 0a45.511111 45.511111 0 1 0 91.022222 0 45.511111 45.511111 0 1 0-91.022222 0Z',
    ];

    if (animationController.value > 0.9) {
      _drawPath(pathsData, canvas);
    } else {
      _drawPath2(pathsData, canvas);
    }

    canvas.restore();
  }

  void _drawPath(List<String> pathsData, Canvas canvas) {
    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index];
      Path path = Path();
      Paint paint = Paint();
      paint.color = Colors.primaries[index];
      writeSvgPathDataToPath(pathData, PathPrinter(path: path));
      canvas.drawPath(path, paint);
    });
  }

  void _drawPath2(List<String> pathsData, Canvas canvas) {
    List<PathMetric> extractPathList = [];
    Function func = (Path path, Paint paint) {
      canvas.drawPath(path, paint);
    };

    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index];
      Path path = Path();
      writeSvgPathDataToPath(pathData, PathPrinter(path: path));
      List<PathMetric> pathMetrics = path.computeMetrics().toList();
      extractPathList.addAll(pathMetrics);
    });
    double unitTime = seconds / extractPathList.length;
    extractPathList.sort((a, b) => a.length.compareTo(b.length));
    List.generate(extractPathList.length, (index) async {
      PathMetric item = extractPathList[index];
      Animation<double> animation =
          Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
              parent: animationController,
              curve: Interval(
                ((index + 1) - 1) / extractPathList.length * unitTime,
                (index + 1) / extractPathList.length * unitTime,
                curve: Curves.ease,
              )));
      Paint paint = Paint();
      paint.strokeWidth = 10;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;
      if (animation.value > 0) {
        Path extractPath = item.extractPath(0, item.length * animation.value);
        paint.color = Colors.primaries[index % Colors.primaries.length];
        func(extractPath, paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class PathPrinter extends PathProxy {
  final Path path;

  PathPrinter({this.path});

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}
