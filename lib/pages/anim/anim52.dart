import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/utils.dart';
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
  bool _isSort = true;
  List<Map<String, dynamic>> _pathsData = [];

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _isSort = !_isSort;
            _animationController.forward(from: 0);
          }
        });
      }
    });
    _animationController.forward();
    IconFontUtil.read('//at.alicdn.com/t/font_1950593_6ak8py93msm.js')
        .then((values) {
      setState(() {
        _pathsData = values;
      });
    });
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
      body: GridView.builder(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemCount: _pathsData.length,
          itemBuilder: (context, index) {
            final pathDataMap = _pathsData[index];
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: MyPainter(
                    animationController: _animationController,
                    pathDataMap: pathDataMap,
                    isSort: _isSort,
                  ),
                );
              },
            );
          }),
    );
  }
}

class MyPainter extends CustomPainter {
  final AnimationController animationController;
  final bool isSort;
  final Map<String, dynamic> pathDataMap;

  MyPainter({this.animationController, this.isSort, this.pathDataMap});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final viewBoxList = pathDataMap['viewBoxList'];
    final pathData = pathDataMap['pathData'];
    canvas.scale(size.width / viewBoxList[2], size.width / viewBoxList[3]);
    if (animationController.value == 1.0) {
      _drawPath(pathData, canvas);
    } else {
      _drawPath2(pathData, canvas);
    }

    canvas.restore();
  }

  void _drawPath(List<String> pathsData, Canvas canvas) {
    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index];
      Path path = Path();
      Paint paint = Paint();
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.fill;
      paint.color = Colors.primaries[index % Colors.primaries.length];
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
    if (isSort) {
      extractPathList.sort((a, b) => a.length.compareTo(b.length));
    } else {
      extractPathList.sort((a, b) => b.length.compareTo(a.length));
    }
    final extractPathLen = extractPathList.length;
    List.generate(extractPathLen, (index) async {
      PathMetric item = extractPathList[index];
      var begin = index / extractPathLen;
      var end = (index + 1) / extractPathLen;
      Animation<double> animation = Tween<double>(begin: 0, end: 1.0).animate(
          CurvedAnimation(
              parent: animationController,
              curve: Interval(begin, end, curve: Curves.ease)));
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
