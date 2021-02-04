import 'dart:math';
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
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            _isSort = !_isSort;
            _animationController.forward(from: 0);
          }
        });
      }
    });
    _animationController.forward();
    IconFontUtil.read('//at.alicdn.com/t/font_1950593_g48kd9v3h54.js')
        .then((values) {
      if (mounted) {
        setState(() {
          _pathsData = values;
        });
      }
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
                    curve: Curves.ease,
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
  final Curve curve;
  final Map<String, dynamic> pathDataMap;

  MyPainter(
      {this.animationController, this.isSort, this.curve, this.pathDataMap});

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width == size.height);
    canvas.save();

    List<double> viewBoxList = pathDataMap['viewBoxList'];
    List<Map<String, dynamic>> pathData = pathDataMap['pathData'];
    // 自身宽高比
    final pathDataScale = viewBoxList[2] / viewBoxList[3];
    final canvasMin = size.width;
    final viewBoxMax = max(viewBoxList[2], viewBoxList[3]);
    final scaleX = canvasMin / viewBoxList[2];
    final scaleY = canvasMin / viewBoxList[3] / pathDataScale;
    // 渲染宽高
    final translateY =
        (canvasMin - viewBoxList[3] * canvasMin / viewBoxMax) / 2;
    // 先平移再缩放，不然translateY要除缩放比
    canvas.translate(0, translateY);
    canvas.scale(scaleX, scaleY);
    if (animationController.value == 1.0) {
      _drawPathFill(pathData, canvas);
    } else {
      _drawPathStroke(pathData, canvas);
    }

    canvas.restore();
  }

  void _drawPathFill(List<Map<String, dynamic>> pathsData, Canvas canvas) {
    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index]['path'];
      Color fillColor = pathsData[index]['fillColor'] ?? Colors.black54;
      Path path = Path();
      Paint paint = Paint();
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.fill;
      paint.color = fillColor;
      writeSvgPathDataToPath(pathData, PathPrinter(path: path));
      canvas.drawPath(path, paint);
    });
  }

  void _drawPathStroke(List<Map<String, dynamic>> pathsData, Canvas canvas) {
    List<Map<String, dynamic>> extractPathList = [];
    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index]['path'];
      Color fillColor = pathsData[index]['fillColor'] ?? Colors.black54;
      Path path = Path();
      writeSvgPathDataToPath(pathData, PathPrinter(path: path));
      extractPathList.addAll(path.computeMetrics().toList().map((e) {
        return {'fillColor': fillColor, 'pathMetric': e};
      }));
    });
    if (isSort) {
      extractPathList.sort(
          (a, b) => a['pathMetric'].length.compareTo(b['pathMetric'].length));
    } else {
      extractPathList.sort(
          (a, b) => b['pathMetric'].length.compareTo(a['pathMetric'].length));
    }
    final extractPathLen = extractPathList.length;
    List.generate(extractPathLen, (index) async {
      Map<String, dynamic> item = extractPathList[index];
      PathMetric pathMetric = item['pathMetric'];
      Color fillColor = item['fillColor'] ?? Colors.black54;
      var begin = index / extractPathLen;
      var end = (index + 1) / extractPathLen;
      Animation<double> animation = Tween<double>(begin: 0, end: 1.0).animate(
          CurvedAnimation(
              parent: animationController,
              curve: Interval(begin, end, curve: curve)));
      Paint paint = Paint();
      paint.strokeWidth = 10;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;
      if (animation.value > 0) {
        Path extractPath =
            pathMetric.extractPath(0, pathMetric.length * animation.value);
        paint.color = fillColor;
        canvas.drawPath(extractPath, paint);
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
