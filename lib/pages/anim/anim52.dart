import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'package:path_parsing/path_parsing.dart';

class Anim52Page extends StatefulWidget {
  Anim52Page({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _Anim52PageState createState() => _Anim52PageState();
}

class _Anim52PageState extends State<Anim52Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) _animationController.forward(from: 0);
        });
      }
    });
    _pageController.addListener(() {
      double page = _pageController.page!;
      if (page != page.toInt()) {
        _animationController.stop();
      } else {
        _animationController.forward(from: _animationController.value);
      }
    });
    _animationController.forward();
    super.initState();
  }

  Future<List<ParsPathModel>> _mockIconfontData() async {
    return IconFontUtil.read('//at.alicdn.com/t/font_1950593_g48kd9v3h54.js');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.title),
      body: FutureBuilder<List<ParsPathModel>>(
        future: _mockIconfontData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("error: ${snapshot.error}"));
            } else {
              return PageView.builder(
                controller: _pageController,
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final pathDataMap = snapshot.data![index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(flex: 1),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '${index + 1}/${snapshot.data!.length}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(flex: 1),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Center(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                size: Size(
                                  MediaQuery.of(context).size.width - 40,
                                  MediaQuery.of(context).size.width - 40,
                                ),
                                painter: MyPainter(
                                  animationController: _animationController,
                                  pathDataMap: pathDataMap,
                                  paintingStyle: PaintingStyle.fill,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Spacer(flex: 3),
                    ],
                  );
                },
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final AnimationController animationController;
  final Curve curve;
  final ParsPathModel pathDataMap;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  MyPainter({
    required this.animationController,
    this.curve = Curves.ease,
    required this.pathDataMap,
    this.paintingStyle = PaintingStyle.fill,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width == size.height);
    canvas.save();

    ViewBoxModel viewBox = pathDataMap.viewBox;
    List<PathInfoModel> pathData = pathDataMap.pathList;
    final canvasMin = size.width;
    final viewBoxMax = max(viewBox.width, viewBox.height);
    final scale = canvasMin / viewBox.width;
    // 渲染宽高
    final translateY =
        (canvasMin - viewBox.height * canvasMin / viewBoxMax) / 2;
    // 先平移再缩放，不然translateY要除缩放比
    canvas.translate(0, translateY);
    canvas.scale(scale, scale);
    _drawPath(pathData, canvas, scale);

    canvas.restore();
  }

  void _drawPath(List<PathInfoModel> pathsData, Canvas canvas, double scale) {
    List<ExtractPathModel> extractPathList = [];
    List<CanvasPathModel> canvasPathMap = [];
    List.generate(pathsData.length, (index) {
      String pathData = pathsData[index].path;
      Color fillColor = pathsData[index].fillColor;
      Path path = Path();
      writeSvgPathDataToPath(pathData, PathPrinter(path: path));
      List<PathMetric> listData = path.computeMetrics().toList();
      extractPathList.addAll(listData.map((e) {
        return ExtractPathModel(
            fillColor: fillColor,
            pathMetric: e,
            pathIndex: index,
            pathTotalNumber: listData.length);
      }));
      canvasPathMap.add(CanvasPathModel(path: path, fillColor: fillColor));
    });
    final extractPathLen = extractPathList.length;
    // 记录每组完成进度
    Map<int, int> progress = {};
    List.generate(extractPathLen, (index) {
      ExtractPathModel item = extractPathList[index];
      PathMetric pathMetric = item.pathMetric;
      Color fillColor = item.fillColor;
      int pathIndex = item.pathIndex;
      int pathTotalNumber = item.pathTotalNumber;
      if (progress.containsKey(pathIndex)) {
        var tmp = progress[pathIndex] as int;
        tmp += 1;
        progress[pathIndex] = tmp;
      } else {
        progress[pathIndex] = 1;
      }
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
        // 不依赖animationController value
        Animation<double> animationFill = Tween<double>(begin: 0, end: 1.0)
            .animate(CurvedAnimation(
                parent: animationController,
                curve: Interval(0, 1.0, curve: curve)));
        if (animation.value == 1.0 &&
            paintingStyle == PaintingStyle.fill &&
            progress[pathIndex] == pathTotalNumber) {
          Paint paintPath = Paint();
          paintPath.strokeWidth = 0;
          paintPath.strokeCap = StrokeCap.round;
          paintPath.style = PaintingStyle.fill;
          paintPath.color = canvasPathMap[pathIndex].fillColor;
          canvas.drawPath(canvasPathMap[pathIndex].path, paintPath);
        } else if (animationFill.value == 1.0 &&
            paintingStyle == PaintingStyle.stroke) {
          canvasPathMap.forEach((element) {
            Paint paintFill = Paint();
            paintFill.strokeCap = StrokeCap.round;
            paintFill.style = PaintingStyle.fill;
            paintFill.color = element.fillColor;
            canvas.drawPath(element.path, paintFill);
          });
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class ExtractPathModel {
  final Color fillColor;
  final PathMetric pathMetric;
  final int pathIndex;
  final int pathTotalNumber;

  const ExtractPathModel(
      {required this.fillColor,
      required this.pathMetric,
      required this.pathIndex,
      required this.pathTotalNumber});
}

class CanvasPathModel {
  final Path path;
  final Color fillColor;

  const CanvasPathModel({required this.path, required this.fillColor});
}

class PathPrinter extends PathProxy {
  final Path path;

  PathPrinter({required this.path});

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
