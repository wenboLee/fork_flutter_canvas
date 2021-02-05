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

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            _animationController.forward(from: 0);
          }
        });
      }
    });
    _animationController.forward();
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _mockIconfontData() async {
    return IconFontUtil.read('//at.alicdn.com/t/font_1950593_g48kd9v3h54.js');
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
      body: FutureBuilder(
        future: _mockIconfontData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("error: ${snapshot.error}"));
            } else {
              List<Map<String, dynamic>> pathsData = snapshot.data;
              return GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: pathsData.length,
                  itemBuilder: (context, index) {
                    final pathDataMap = pathsData[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: MyPainter(
                            animationController: _animationController,
                            pathDataMap: pathDataMap,
                            paintingStyle: PaintingStyle.fill,
                          ),
                        );
                      },
                    );
                  });
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final AnimationController animationController;
  final Curve curve;
  final Map<String, dynamic> pathDataMap;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  MyPainter({
    this.animationController,
    this.curve = Curves.ease,
    this.pathDataMap,
    this.paintingStyle = PaintingStyle.fill,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width == size.height);
    canvas.save();

    List<double> viewBoxList = pathDataMap['viewBoxList'];
    List<Map<String, dynamic>> pathData = pathDataMap['pathList'];
    final canvasMin = size.width;
    final viewBoxMax = max(viewBoxList[2], viewBoxList[3]);
    final scale = canvasMin / viewBoxList[2];
    // 渲染宽高
    final translateY =
        (canvasMin - viewBoxList[3] * canvasMin / viewBoxMax) / 2;
    // 先平移再缩放，不然translateY要除缩放比
    canvas.translate(0, translateY);
    canvas.scale(scale, scale);
    _drawPath(pathData, canvas, scale);

    canvas.restore();
  }

  void _drawPath(
      List<Map<String, dynamic>> pathsData, Canvas canvas, double scale) {
    List<Map<String, dynamic>> extractPathList = [];
    List<Path> canvasPaths = [];
    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index]['path'];
      Color fillColor = pathsData[index]['fillColor'];
      Path path = Path();
      writeSvgPathDataToPath(pathData, PathPrinter(path: path));
      extractPathList.addAll(path.computeMetrics().toList().map((e) {
        return {'fillColor': fillColor, 'pathMetric': e, 'pathIndex': index};
      }));
      canvasPaths.add(path);
    });
    final extractPathLen = extractPathList.length;
    List.generate(extractPathLen, (index) async {
      Map<String, dynamic> item = extractPathList[index];
      PathMetric pathMetric = item['pathMetric'];
      Color fillColor = item['fillColor'];
      int pathIndex = item['pathIndex'];
      var begin = index / extractPathLen;
      var end = (index + 1) / extractPathLen;
      Animation<double> animation = Tween<double>(begin: 0, end: 1.0).animate(
          CurvedAnimation(
              parent: animationController,
              curve: Interval(begin, end, curve: curve)));
      Paint paint = Paint();
      // 还原strokeWidth
      paint.strokeWidth = strokeWidth / scale;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;
      if (animation.value > 0) {
        Path extractPath =
            pathMetric.extractPath(0, pathMetric.length * animation.value);
        paint.color = fillColor;
        canvas.drawPath(extractPath, paint);
        if (animation.value == 1.0 && paintingStyle != PaintingStyle.stroke) {
          Paint paintPath = Paint();
          paintPath.strokeCap = StrokeCap.round;
          paintPath.style = PaintingStyle.fill;
          paintPath.color = fillColor;
          canvas.drawPath(canvasPaths[pathIndex], paintPath);
        }
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
