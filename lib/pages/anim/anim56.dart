import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

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
  int _resolutionx = 30, _resolutiony = 30;
  bool _isMouseDown = false;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext!.size!;
          _radius = _size.width / 2 - 20;
          // load("assets/logo.png").then((img) {
          //   setState(() {
          //     _resolutionx = img.width;
          //     _resolutiony = img.height;
          //   });
          // });
        }
      }
    });

    super.initState();
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
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
              return CustomPaint(
                key: _globalKey,
                size: Size.infinite,
                painter: MyCustomPainter(
                  rx: _rx,
                  ry: _ry,
                  rz: _rz,
                  radius: _radius,
                  resolutionx: _resolutionx,
                  resolutiony: _resolutiony,
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
          _resolutionx = math.Random().nextInt(100) + 50;
          _resolutiony = _resolutionx;
        });
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double rx, ry, rz, radius;
  final int resolutionx, resolutiony;

  MyCustomPainter({
    required this.rx,
    required this.ry,
    required this.rz,
    required this.radius,
    required this.resolutionx,
    required this.resolutiony,
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

        // final mv = [
        //   [x],
        //   [y],
        //   [z],
        //   [1],
        // ];
        // final mx = [
        //   [1, 0, 0, 0],
        //   [0, cos(rx), sin(rx), 0],
        //   [0, -sin(rx), cos(rx), 0],
        //   [0, 0, 0, 1],
        // ];
        // final my = [
        //   [cos(ry), 0, -sin(ry), 0],
        //   [0, 1, 0, 0],
        //   [sin(ry), 0, cos(ry), 0],
        //   [0, 0, 0, 1],
        // ];
        // final mz = [
        //   [cos(rz), -sin(rz), 0, 0],
        //   [sin(rz), cos(rz), 0, 0],
        //   [0, 0, 1, 0],
        //   [0, 0, 0, 1],
        // ];
        // rotate x = mv * mx
        // rotate y = mv * my
        // rotate z = mv * mz

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
        double rzz = ryz;

        canvas.drawCircle(Offset(rzx, rzy), 1, _paint);
        // _drawText(canvas, size, Offset(rzx, rzy));
      }
    }

    canvas.restore();
  }

  void _drawText(Canvas canvas, Size size, Offset offset) {
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 10),
    );
    paragraphBuilder.pushStyle(ui.TextStyle(
      color: Colors.red,
      fontSize: 10,
    ));
    paragraphBuilder.addText('钱');
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
