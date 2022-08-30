import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'package:image/image.dart' as img;

class Anim56Page extends StatefulWidget {
  final String title;

  Anim56Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim56PageState createState() => _Anim56PageState();
}

class _Anim56PageState extends State<Anim56Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey _globalKey = GlobalKey();
  Offset _offset = Offset.zero;
  Size _size = Size.zero;
  double _rx = 0, _ry = 0, _rz = 0, _radius = 0;
  int _resolutionx = 0, _resolutiony = 0;
  bool _isMouseDown = false;
  List<List<PixelColor>> _rgbList = [];
  bool _showLogo1 = true;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext!.size!;
        }
      }
    });
    decodeRGB("assets/logo1.png");

    super.initState();
  }

  Future<void> decodeRGB(String asset) async {
    final Uint8List inputImg =
        (await rootBundle.load(asset)).buffer.asUint8List();
    final decoder = img.PngDecoder();
    final decodedImg = decoder.decodeImage(inputImg);
    if (decodedImg != null) {
      _resolutionx = decodedImg.width;
      _resolutiony = decodedImg.height;

      final max = math.max(_resolutionx, _resolutiony);
      _radius = max / 2;

      final decodedBytes = decodedImg.getBytes(format: img.Format.rgb);
      List<List<PixelColor>> rgbList = [];
      for (int y = 0; y < decodedImg.height; y++) {
        rgbList.add(<PixelColor>[]);
        for (int x = 0; x < decodedImg.width; x++) {
          int red = decodedBytes[y * decodedImg.width * 3 + x * 3];
          int green = decodedBytes[y * decodedImg.width * 3 + x * 3 + 1];
          int blue = decodedBytes[y * decodedImg.width * 3 + x * 3 + 2];
          rgbList[y].add(PixelColor(red: red, green: green, blue: blue));
        }
      }
      _rgbList = rgbList;
      setState(() {});
    }
  }

  void _pointerDownEvent(event) {
    _isMouseDown = false;
    if (isPointCircle(
        _radius, _size.center(Offset.zero), event.localPosition)) {
      _isMouseDown = true;
    }
  }

  void _pointerMoveEvent(PointerMoveEvent event) {
    if (_isMouseDown) {
      _offset += event.delta;
      _rx = _offset.dy * 0.005 * -1; // 调整手势方向
      _ry = _offset.dx * 0.005;
      _rz = 0;
    }
  }

  void _pointerUpEvent(event) {
    _isMouseDown = false;
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
        width: double.infinity,
        height: double.infinity,
        child: Listener(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final max = math.max(_resolutionx, _resolutiony).toDouble();
              return CustomPaint(
                key: _globalKey,
                size: Size(max, max),
                painter: MyCustomPainter(
                  rx: _rx,
                  ry: _ry,
                  rz: _rz,
                  radius: _radius,
                  resolutionx: _resolutionx,
                  resolutiony: _resolutiony,
                  rgbList: _rgbList,
                ),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDownEvent,
          onPointerMove: _pointerMoveEvent,
          onPointerUp: _pointerUpEvent,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {
          if (_showLogo1) {
            _showLogo1 = !_showLogo1;
            decodeRGB("assets/logo2.png");
          } else {
            _showLogo1 = !_showLogo1;
            decodeRGB("assets/logo1.png");
          }
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double rx, ry, rz, radius;
  final int resolutionx, resolutiony;
  final List<List<PixelColor?>?> rgbList;

  MyCustomPainter({
    required this.rx,
    required this.ry,
    required this.rz,
    required this.radius,
    required this.resolutionx,
    required this.resolutiony,
    required this.rgbList,
  });

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas);

    canvas.translate(size.width / 2, size.height / 2);

    for (var i = 0; i < resolutionx; i++) {
      final theta = math.pi * i / resolutionx;
      for (var j = 0; j < resolutiony; j++) {
        final phi = 2 * math.pi * j / resolutiony;

        final x = radius * math.cos(phi) * math.sin(theta);
        final y = radius * math.sin(phi) * math.sin(theta);
        final z = radius * math.cos(theta);

        // rotate x
        double rxx = x;
        double rxy = math.cos(rx) * y + math.sin(rx) * z;
        double rxz = -math.sin(rx) * y + math.cos(rx) * z;

        // rotate y
        double ryx = math.cos(ry) * rxx - math.sin(ry) * rxz;
        double ryy = rxy;
        double ryz = math.sin(ry) * rxx + math.cos(ry) * rxz;

        // rotate z
        double rzx = math.cos(rz) * ryx - math.sin(rz) * ryy;
        double rzy = math.sin(rz) * ryx + math.cos(rz) * ryy;
        // ignore: unused_local_variable
        double rzz = ryz;

        PixelColor pixelColor;
        if (rgbList[j] != null && rgbList[j]![i] != null) {
          pixelColor = rgbList[j]![i]!;
        } else {
          pixelColor = PixelColor(red: 0, green: 0, blue: 0);
        }
        _paint.color = Color.fromRGBO(
            pixelColor.red!, pixelColor.green!, pixelColor.blue!, 1);
        canvas.drawRect(
            Rect.fromCenter(
              center: Offset(rzx, rzy),
              width: 1 * window.devicePixelRatio,
              height: 1 * window.devicePixelRatio,
            ),
            _paint);
      }
    }

    canvas.restore();
  }

  // 绘制到rect中，再将rect转换到圆
  // ignore: unused_element
  void _drawText(Canvas canvas, Size size, Offset offset) {
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 10),
    );
    paragraphBuilder.pushStyle(ui.TextStyle(
      color: Colors.red,
      fontSize: 10,
    ));
    paragraphBuilder.addText('文字');
    ui.ParagraphConstraints paragraphConstraints =
        ui.ParagraphConstraints(width: 10);
    ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(paragraphConstraints);
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PixelColor {
  final int? blue, green, red;

  PixelColor({this.red, this.green, this.blue});

  @override
  String toString() {
    return 'R: $red, G: $green, B: $blue';
  }
}
