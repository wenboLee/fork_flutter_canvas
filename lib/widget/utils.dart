import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/box.dart';

Color randomColor({alpha = 255}) {
  var red = 55 + Random().nextInt(201);
  var greed = 55 + Random().nextInt(201);
  var blue = 55 + Random().nextInt(201);
  if (red > 100 && greed > 100 && blue > 100) {
    return randomColor(alpha: alpha);
  } else {
    return Color.fromARGB(alpha, red, greed, blue);
  }
}

double randomScope(List<double> scope) {
  // 默认从小到大scope.sort()
  scope.sort((a, b) => a.compareTo(b));
  return Random().nextDouble() * (scope[1] - scope[0]) + scope[0];
}

// 角度转弧度
double toRad(angle) {
  return pi / 180 * angle;
}

// 弧度转角度
double toAngle(rad) {
  return rad * 180 / pi;
}

// 点是否在圆内
bool isPoint(Ball ball, Offset point) {
  return ball.r >= sqrt(pow(point.dx - ball.x, 2) + pow(point.dy - ball.y, 2));
}

// 点是否在盒子内
bool isBoxPoint(Box box, Offset point) {
  return point.dx >= box.x &&
      point.dx <= box.x + box.w &&
      point.dy >= box.y &&
      point.dy <= box.y + box.h;
}

// 两点间间距
double getDist(Offset p1, Offset p2) {
  return sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
}

// 矩形之间碰撞检测
bool rectHit(Box box1, Box box2) {
  return (box1.x + box1.w >= box2.x &&
      box1.x <= box2.x + box2.w &&
      box1.y + box1.h >= box2.y &&
      box1.y <= box2.y + box2.h);
}

// 对小球进行边界反弹处理
void checkBallBounce(Ball ball, Size size, double bounce) {
  if (ball.x - ball.r <= 0) {
    ball.x = ball.r;
    ball.vx *= bounce;
  } else if (ball.x + ball.r >= size.width) {
    ball.x = size.width - ball.r;
    ball.vx *= bounce;
  }
  if (ball.y - ball.r <= 0) {
    ball.y = ball.r;
    ball.vy *= bounce;
  } else if (ball.y + ball.r >= size.height) {
    ball.y = size.height - ball.r;
    ball.vy *= bounce;
  }
}

// 计算文本高度
double calculateTextHeight({
  BuildContext context,
  String value,
  TextStyle style,
  double maxWidth,
  int maxLines,
}) {
  TextPainter painter = TextPainter(
    locale: Localizations.localeOf(context, nullOk: true),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: value,
      style: style,
    ),
  )..layout(maxWidth: maxWidth);
  return painter.height;
}

class Toast {
  static OverlayEntry _overlayEntry;
  static bool _showing = false;
  static DateTime _startedTime;
  static int _duration = 3000;
  static String _msg;

  static void show(BuildContext context, String msg, {double top = 0.0}) async {
    assert(msg != null);
    _msg = msg;
    _startedTime = DateTime.now();

    OverlayState overlayState = Overlay.of(context);
    _showing = true;
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
                top: top > 0 ? top : MediaQuery.of(context).size.height * 2 / 3,
                child: Container(
                    padding: EdgeInsets.all(80),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff3470e1),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      child: AnimatedOpacity(
                        opacity: _showing ? 1.0 : 0.0,
                        duration: _showing
                            ? Duration(milliseconds: 100)
                            : Duration(milliseconds: 400),
                        child: Text(
                          _msg,
                          style: TextStyle(
                            fontSize: 12.0,
                            decoration: TextDecoration.none,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
              ));
      overlayState.insert(_overlayEntry);
    } else {
      if (_overlayEntry != null) {
        _overlayEntry.markNeedsBuild();
      }
    }
    await Future.delayed(Duration(milliseconds: _duration)); //等待3秒

    if (DateTime.now().difference(_startedTime).inMilliseconds >= _duration) {
      _showing = false;
      if (_overlayEntry != null) {
        Future.delayed(Duration.zero, () {
          _overlayEntry.markNeedsBuild();
          _overlayEntry.remove();
          _overlayEntry = null;
        });
      }
    }
  }
}
