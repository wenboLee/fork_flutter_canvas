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
  bool _isSort = true;
  List<List<String>> _pathsData = [
    [
      'M759.466667 1024H264.533333C119.466667 1024 0 904.533333 0 759.466667V261.688889C0 116.622222 119.466667 0 264.533333 0h494.933334C904.533333 0 1024 116.622222 1024 261.688889v497.777778c0 145.066667-119.466667 264.533333-264.533333 264.533333zM264.533333 54.044444c-116.622222 0-210.488889 93.866667-210.488889 210.488889v497.777778c0 116.622222 93.866667 210.488889 210.488889 210.488889h494.933334c116.622222 0 210.488889-93.866667 210.488889-210.488889V261.688889c0-116.622222-93.866667-210.488889-210.488889-210.488889H264.533333z',
      'M355.555556 290.133333m-128 0a128 128 0 1 0 256 0 128 128 0 1 0-256 0Z',
      'M355.555556 489.244444c-108.088889 0-199.111111-88.177778-199.111112-199.111111s88.177778-199.111111 199.111112-199.111111 199.111111 88.177778 199.111111 199.111111-88.177778 199.111111-199.111111 199.111111z m0-369.777777c-93.866667 0-170.666667 76.8-170.666667 170.666666s76.8 170.666667 170.666667 170.666667 170.666667-76.8 170.666666-170.666667-76.8-170.666667-170.666666-170.666666z',
      'M355.555556 733.866667m-128 0a128 128 0 1 0 256 0 128 128 0 1 0-256 0Z',
      'M355.555556 932.977778c-108.088889 0-199.111111-88.177778-199.111112-199.111111s88.177778-199.111111 199.111112-199.111111 199.111111 88.177778 199.111111 199.111111-88.177778 199.111111-199.111111 199.111111z m0-369.777778c-93.866667 0-170.666667 76.8-170.666667 170.666667s76.8 170.666667 170.666667 170.666666 170.666667-76.8 170.666666-170.666666-76.8-170.666667-170.666666-170.666667zM779.377778 733.866667c-71.111111 0-128-56.888889-128-128s56.888889-128 128-128 128 56.888889 128 128c2.844444 71.111111-56.888889 128-128 128z m0-230.4c-56.888889 0-102.4 45.511111-102.4 102.4s45.511111 102.4 102.4 102.4 102.4-45.511111 102.4-102.4-45.511111-102.4-102.4-102.4z',
      'M779.377778 352.711111m-45.511111 0a45.511111 45.511111 0 1 0 91.022222 0 45.511111 45.511111 0 1 0-91.022222 0Z',
    ],
    [
      'M702.586 74.472h117.43c70.852 0 128.287 56.07 128.287 125.226V322.03c0 13.824 11.49 25.039 25.661 25.039 14.166 0 25.655-11.215 25.655-25.045V199.698c0-96.823-80.408-175.317-179.602-175.317H702.586c-14.172 0-25.661 11.215-25.661 25.051 0 13.824 11.49 25.04 25.66 25.04z m245.498 628.114v117.43c0 70.852-57.686 128.287-128.835 128.287H702.696c-14.227 0-25.765 11.49-25.765 25.661 0 14.166 11.538 25.655 25.765 25.655h116.553c99.608 0 180.37-80.408 180.37-179.602V702.586c0-14.172-11.538-25.661-25.765-25.661-14.232 0-25.77 11.49-25.77 25.66zM321.524 948.15H203.209c-70.546 0-127.732-57.606-127.732-128.67V702.664c0-14.214-11.44-25.734-25.55-25.734-14.105 0-25.546 11.52-25.546 25.734V819.48c0 99.487 80.067 180.139 178.828 180.139h118.309c14.116 0 25.551-11.52 25.551-25.734 0-14.214-11.435-25.734-25.545-25.734zM75.61 321.688c0 14.02-11.465 25.381-25.612 25.381-14.147 0-25.618-11.362-25.618-25.38v-119.65c0-98.127 80.28-177.658 179.31-177.658h117.76c14.153 0 25.618 11.361 25.618 25.38s-11.465 25.375-25.612 25.375h-117.76c-70.742 0-128.086 56.814-128.086 126.903v119.65z m594.146 62.342c0-16.457 14.446-29.787 32.268-29.787 17.823 0 32.274 13.336 32.274 29.787v69.498c0 16.458-14.445 29.788-32.274 29.788-17.816 0-32.268-13.337-32.268-29.788V384.03z m-380.056 0c0-16.457 14.445-29.787 32.274-29.787 17.816 0 32.268 13.336 32.268 29.787v69.498c0 16.458-14.446 29.788-32.268 29.788-17.823 0-32.274-13.337-32.274-29.788V384.03z m182.308 189.367c19.03 0 25.393-6.21 26.746-29.427V384.494c0-16.707 14.202-30.251 31.72-30.251 17.517 0 31.72 13.544 31.72 30.25v160.275l-0.037 1.524c-2.902 54.698-35.578 87.613-90.149 87.613-17.518 0-31.72-13.544-31.72-30.25 0-16.714 14.202-30.258 31.726-30.258zM341.851 727.87a29.379 29.379 0 0 1-0.633-41.935 30.354 30.354 0 0 1 42.508-0.628c32.768 31.378 74.947 47.043 128.274 47.043s95.506-15.665 128.274-47.043a30.354 30.354 0 0 1 42.508 0.628 29.379 29.379 0 0 1-0.633 41.935c-44.404 42.514-101.7 63.793-170.149 63.793-68.45 0-125.745-21.273-170.149-63.793z'
    ]
  ];

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 3), () {
          _isSort = !_isSort;
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              children: _pathsData.map<Widget>((pathData) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(size.width, size.height / 2),
                      painter: MyPainter(
                        animationController: _animationController,
                        pathData: pathData,
                        isSort: _isSort,
                      ),
                    );
                  },
                );
              }).toList(),
            )),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final AnimationController animationController;
  final bool isSort;
  final List<String> pathData;

  MyPainter({this.animationController, this.isSort, this.pathData});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(size.width / 1024, size.width / 1024);
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
