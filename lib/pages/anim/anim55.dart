import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/comm.dart';

class Anim55Page extends StatefulWidget {
  final String title;

  Anim55Page({Key? key, required this.title}) : super(key: key);

  @override
  _Anim55PageState createState() => _Anim55PageState();
}

class _Anim55PageState extends State<Anim55Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {}
    });
    super.initState();
  }

  void _pointerMoveEvent(PointerMoveEvent event) {
    _offset += event.delta;
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
                size: Size.infinite,
                painter: MyCustomPainter(
                    rx: _offset.dy * 0.005, ry: _offset.dx * 0.005, rz: 0),
              );
            },
          ),
          behavior: HitTestBehavior.opaque,
          onPointerMove: _pointerMoveEvent,
        ),
      ),
      floatingActionButton: actionButton(() {
        setState(() {});
      }),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double rx, ry, rz;

  MyCustomPainter({required this.rx, required this.ry, required this.rz});

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

    const double radius = 180;
    const int resolution = 180;

    for (var i = 0; i < resolution; i++) {
      final theta = pi * i / resolution;
      for (var j = 0; j < resolution; j++) {
        final phi = 2 * pi * j / resolution;

        final x = radius * cos(phi) * sin(theta);
        final y = radius * sin(phi) * sin(theta);
        final z = radius * cos(theta);

        //  final mv = Matrix4.columns(
        //   vector.Vector(x),
        //   vector.Vector(y),
        //   vector.Vector(z),
        //   vector.Vector(1),
        // );
        // final mx = Matrix4.columns(
        //   vector.Vector4(1, 0, 0, 0),
        //   vector.Vector4(0, cos(…), sin(…), 0),
        //   vector.Vector4(0, -sin(…), cos(…), 0),
        //   vector.Vector4(0, 0, 0, 1),
        // );
        // final my = Matrix4.columns(
        //   vector.Vector4(cos(…), 0, -sin(…), 0),
        //   vector.Vector4(0, 1, 0, 0),
        //   vector.Vector4(sin(…), 0, cos(…), 0),
        //   vector.Vector4(0, 0, 0, 1),
        // );
        // final mz = Matrix4.columns(
        //   vector.Vector4(cos(…), -sin(…), 0, 0),
        //   vector.Vector4(sin(…), cos(…), 0, 0),
        //   vector.Vector4(0, 0, 1, 0),
        //   vector.Vector4(0, 0, 0, 1),
        // );
        // rotate x = mv * mx
        // rotate y = mv * my
        // rotate z = mv * mz

        // rotate x
        double rxx = x;
        double rxy = cos(rx) * y + sin(rx) * z;
        double rxz = -sin(rx) * y + cos(rx) * z;

        // rotate y
        double ryx = cos(ry) * rxx - sin(ry) * rxz;
        double ryy = rxy;
        double ryz = sin(ry) * rxx + cos(ry) * rxz;

        // rotate z
        double rzx = cos(rz) * ryx - sin(rz) * ryy;
        double rzy = sin(rz) * ryx + cos(rz) * ryy;
        double rzz = ryz;

        canvas.drawCircle(Offset(rzx, rzy), 1, _paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
