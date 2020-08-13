import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/box.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class Anim39Page extends StatefulWidget {
  final String title;

  Anim39Page({this.title});

  @override
  _Anim39PageState createState() => _Anim39PageState();
}

class _Anim39PageState extends State<Anim39Page>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  Size _size = Size.zero;
  List<Box> _boxes = [];
  Box _activeBox;
  double g = 2;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
    _controller.addListener(() {
      if (mounted) {
        if (_size == Size.zero) {
          _size = _globalKey.currentContext.size;
        }
        if (_activeBox == null) {
          _activeBox = _createBox();
        }

        _activeBox.vy += g;
        _activeBox.y += _activeBox.vy;

        // 直接落到地板上
        if (_activeBox.y + _activeBox.h >= _size.height) {
          _activeBox.y = _size.height - _activeBox.h;
          _activeBox = _createBox();
        }

        for (var i = 0; i < _boxes.length; i++) {
          Box box = _boxes[i];
          //碰撞
          if (box != _activeBox && rectHit(box, _activeBox)) {
            // 碰到天花板，清屏
            if (box.y <= 0) {
              _boxes.clear();
            }
            _activeBox.y = box.y - _activeBox.h;
            _activeBox = _createBox();
            break;
          }
        }
      }
    });
    super.initState();
  }

  Box _createBox() {
    var w = randomScope([20, 40]);
    Box box = Box(
      x: randomScope([0, _size.width - w]),
      y: 0,
      w: w,
      h: randomScope([20, 40]),
      fillStyle: randomColor(),
    );
    _boxes.add(box);
    return box;
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _globalKey,
              size: Size.infinite,
              painter: MyCustomPainter(boxes: _boxes),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Box> boxes;

  MyCustomPainter({this.boxes});

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.blue
    ..isAntiAlias = true
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    drawAuthorText(canvas, size);

    for (var i = 0; i < boxes.length; i++) {
      Box box = boxes[i];
      _paint.color = box.fillStyle;
      canvas.drawRect(Rect.fromLTWH(box.x, box.y, box.w, box.h), _paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
